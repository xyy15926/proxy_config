-- ==========================================================================
-- File    : heading_numbers.lua
-- Author  : xyy15926
-- Created : 2026-09-26 19:14:14
-- Updated : 2026-09-27 21:57:21
-- Desc    : Aerial source module for heading numbers.
--
-- Ref:
-- - lazy/aerial.nvim/lua/aerial/backends/markdown.lua
--
-- --------------------------------------------------------------------------
-- aerial 后端: markdown 标题大纲,条目名自带 heading_numbers 编号
--
-- 定位: 完全对齐 aerial 内置 markdown 后端的模块形状
--       (is_supported / fetch_symbols_sync / fetch_symbols / attach / detach),
--       放进任意 runtimepath 的 lua/aerial/backends/ 目录即可按名字使用:
--
--         require("aerial").setup {
--           backends = { "heading_numbers", "treesitter", "lsp" },
--         }
--
-- 与内置后端的差异:
--   1. 解析交给 heading_numbers(treesitter),不再逐行扫 "#+";
--      编号只有一份计算结果,正文 virtual text 与侧边栏必然一致。
--   2. item.name 拼上编号前缀。
--   3. 行号换算: heading_numbers 是 0-based,aerial 的 lnum 是 1-based。
--
-- 为什么不能把 hn.get() 的结果直接交给 aerial:
--   * 形状不同: hn.get() 是扁平标题列表,aerial 要嵌套 symbol 树,必须重建;
--   * name 是 aerial 唯一的渲染文本,编号必须拼进 name 才可见,而拼接
--     不能改在 hn 的缓存表上(重复 fetch 会叠前缀、且污染 hn 的对外数据);
--   * hn.get() 只读缓存、可能滞后于 buffer(其重算有防抖),所以 fetch 时
--     先 hn.update() 强制同步重算,保证编号与内容同批。
--
-- 变化链路: 文本变化 -> attach 注册的 change watcher -> fetch_symbols
--           -> hn.update 重算 -> 建 items -> set_symbols,无需自建 timer。
-- ============================================================================

local backend_util = require("aerial.backends.util")
local backends = require("aerial.backends")
local config = require("aerial.config")
local hn = require("users.markdown_heading_numbers")

local M = {}
M._name = "heading_numbers"

--- aerial symbol 条目形状(仅列出本模块会写的字段,其余由 aerial 补齐)
--- @class AerialItem
--- @field kind string             符号种类,影响侧边栏图标
--- @field name string             条目渲染文本(icon 之外的全部文字)
--- @field level integer           层级,建树与缩进用
--- @field parent AerialItem|nil   父条目;顶层为 nil
--- @field children AerialItem[]|nil 子条目
--- @field lnum integer            起始行(1-based,侧边栏跳转落点)
--- @field col integer             起始列(0-based)
--- @field end_lnum integer|nil    结束行,由 postprocess_symbols 补(折叠区间)
--- @field end_col integer|nil


-- %% =======================================================================
--  aerial 后端协议
-- ==========================================================================

--- 判断该 buffer 是否由本后端负责
---
--- aerial 按 backends 顺序取第一个 is_supported 为真的后端;
--- 这里复用 heading_numbers 的 filetype 白名单,两边口径永远一致,
--- 非 markdown buffer 在此就被拒绝,不会走到 hn,也就不会误解析。
--- @param bufnr integer
--- @return boolean supported
--- @return string|nil reason 不支持原因(仅诊断用)
M.is_supported = function(bufnr)
  if not vim.tbl_contains(hn.opts.enabled_filetypes, vim.bo[bufnr].filetype) then
    return false, "Filetype is not supported by heading_numbers"
  end
  return true, nil
end


--- 同步解析标题并把 symbol 树交给 aerial
---
--- 流程: 重算编号 -> 逐条转成 item 并按层级建树 -> 补 end_lnum -> set_symbols。
--- 编号只从 hn 读取(单向: hn 缓存 -> 新建 item),不在 hn 的表上做任何修改。
--- @param bufnr integer|nil 目标 buffer,nil/0 表示当前 buffer
--- @return nil 结果经 backends.set_symbols() 回传给 aerial,无返回值
M.fetch_symbols_sync = function(bufnr)
  bufnr = bufnr or 0
  local extensions = require("aerial.backends.treesitter.extensions")

  -- fetch 前强制同步重算: hn.get() 只读缓存,可能落后于 buffer 现状
  -- 效率可能比较差？
  hn.update(bufnr)

  local items = {}  -- 顶层条目列表,交给 set_symbols
  local stack = {}  -- 当前祖先链(stack 内 level 严格递增),用于找 parent

  for _, h in ipairs(hn.get(bufnr) or {}) do
    -- 维护祖先链: 弹出 level >= 自己的,剩下的栈顶就是 parent
    while #stack > 0 and stack[#stack].level >= h.level do
      table.remove(stack, #stack)
    end

    -- 条目文本 = 标题正文(截掉行首 "# "),再拼编号前缀
    -- h.col 是正文起点(0-based);setext 标题取段首行,截取结果就是首行文字
    local line = vim.api.nvim_buf_get_lines(bufnr, h.row, h.row + 1, true)[1] or ""
    local name = vim.trim(line:sub(h.col + 1))
    if h.number then
      name = h.number .. " " .. name  -- 无编号的标题(超 min/max 范围)保留原文
    end

    local parent = stack[#stack]
    local item = {
      kind = "Interface",           -- 沿用内置后端的取值,图标表现一致
      name = name,
      level = h.level,
      parent = parent,
      lnum = h.start_row + 1,       -- hn 的行号 0-based -> aerial 的 1-based
      col = 0,
    }

    if parent then
      parent.children = parent.children or {}
      table.insert(parent.children, item)
    else
      -- 顶层条目要过 post_parse_symbol 钩子(用户可在 aerial 配置里过滤)
      if
        not config.post_parse_symbol
        or config.post_parse_symbol(bufnr, item, { backend_name = M._name, lang = "markdown" }) ~= false
      then
        table.insert(items, item)
      end
    end
    table.insert(stack, item)  -- 挂载后再入栈,自己成为后续低层级标题的候选 parent
  end

  -- This sets the proper end_lnum and end_col
  -- 补每条 item 的结束行,折叠区间 / 作用域显示都靠它
  extensions.markdown.postprocess_symbols(bufnr, items)
  backends.set_symbols(bufnr, items, { backend_name = M._name, lang = "markdown" })
end


--- aerial 协议: 异步后端的 fetch 入口;本后端纯同步,直接指向 sync 版
M.fetch_symbols = M.fetch_symbols_sync


--- 挂载到 buffer: 注册 change watcher,文本变化后 aerial 自动重查
--- (这就是"随内容变化"的来源,不需要自己写防抖 timer)
--- @param bufnr integer
--- @return nil
M.attach = function(bufnr)
  backend_util.add_change_watcher(bufnr, M._name)
end


--- 从 buffer 卸载: 移除 change watcher
--- @param bufnr integer
--- @return nil
M.detach = function(bufnr)
  backend_util.remove_change_watcher(bufnr, M._name)
end


return M
