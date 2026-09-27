-- ==========================================================================
-- File    : markdown_heading_numbers.lua
-- Author  : xyy15926
-- Created : 2026-09-24 14:13:45
-- Updated : 2026-09-24 14:13:45
-- Desc    : Add numbers to markdown headings.
--
-- Markdown 标题编号(virtual text / extmark 版)
--
-- 功能: 用 Tree-sitter 解析 Markdown 标题(atx / setext),
--       按文档顺序做层级计数,把编号以 virtual text 形式渲染到标题旁。
--       编号不写入 buffer 原文,对 git diff 友好,编辑时由 extmark 自动跟随。
--
-- 依赖: Neovim >= 0.9(position = "inline" 需要 0.10,0.9 自动回退 "eol")
--       treesitter 的 markdown parser,建议同时安装 markdown_inline
--       (只影响标题正文高亮,不影响编号)
--
-- 用法:
--   require("heading_numbers").setup({
--     position = "inline",       -- "1.1 章节名" 插在标题文字前
--     separator = ".",
--     zero_pad = true,
--   })
--   -- 命令: :HeadingNumbers [toggle|on|off|refresh]
--
-- 设计取舍:
--   * 代码块里的 "# " 行不是标题节点,Tree-sitter 天然排除(优于正则)。
--   * 层级缺环时(如 # 直接跳到 ###)默认补零成 1.0.1,避免与真实 1.1 撞号;
--     zero_pad = false 则紧凑编号 1.1。
--   * extmark 会随文本编辑自动挪位,但改层级会影响后续所有编号,
--     故监听 TextChanged(I) 并防抖(debounce)后整篇重算。
-- ============================================================================

local api = vim.api
local ts = vim.treesitter
local utils = require("users.utils")
local bufau = require("users.bufau")
local hlmark = require("users.hlmark")

--- 默认配置,setup() 会以 force 策略与用户配置合并
--- @class MdHeadingNumbersOptions
--- @field separator string           编号分隔符,如 "." -> 1.2.3
--- @field zero_pad boolean           层级缺环时是否补零: 1.0.1(否则紧凑 1.1)
--- @field min_level integer          参与编号的最小层级(1 = h1)
--- @field max_level integer          参与编号的最大层级(6 = h6)
--- @field setext boolean             是否统计 Setext 风格标题(=== / ---)

--- 单个标题的解析结果
--- @class MdHeading
--- @field row integer       编号插入行(0-based,正文起始行)
--- @field col integer       编号插入列(0-based,正文起始列;setext 取标题首列)
--- @field start_row integer 标题语法起始行(0-based;含 "#" 标记)
--- @field level integer     标题层级 1..6
--- @field number string|nil 计算出的编号文本,如 "1.2.1";超出 [min,max] 时为 nil

local M = {}

M.defaults = {
  enabled_filetypes = {
    "markdown", "quarto", "pandoc", "rmd", "markdown.mdx",
  },
  separator = ".",  -- 各层级编号分隔符
  zero_pad = true,  -- 层级缺环时是否补零: 1.0.1(否则紧凑 1.1)
  min_level = 2,    -- 参与编号的最小层级
  max_level = 6,    -- 参与编号的最大层级
  setext = true,    -- 是否统计 Setext 风格标题 `=== / ---`
  format = function(mdh)    -- 虚拟文本格式化函数
    if mdh.number then
      return mdh.number .. " "
    end
    return nil
  end
}
M.opts = vim.deepcopy(M.defaults)

--- 维护各 buffer 的开启状态
--- @type table<integer, boolean>
M._enabled = {}

--- 各 buffer 的解析缓存,供 aerial / statusline 等外部复用
--- @type table<integer, MdHeading[]>
M._cache = {}

--- @alias TSQuery vim.treesitter.Query
--- 缓存的 treesitter query;false = 构建失败,避免反复重试报错;nil = 未构建
--- @type TSQuery | false |nil
M._query = nil


-- %% =======================================================================
--  文档解析：获取 heading、计算层级、渲染位置
-- ==========================================================================

--- 取(缓存的)markdown 标题 query
---
--- 优先解析 "(atx_heading) (setext_heading) @heading";若 grammar 版本不支持
--- setext_heading 节点则回退为仅 atx_heading。任何失败都缓存为 false。
--- @return TSQuery | false |nil query 可用的 query；不可用时返回 nil
local function get_query()
  if M._query ~= nil then
    return M._query or nil
  end
  -- 是否统计 Setext 风格标题 `=== / ---`
  local src = M.opts.setext
      and "[(atx_heading) (setext_heading)] @heading"
      or  "(atx_heading) @heading"
  local ok, q = pcall(ts.query.parse, "markdown", src)
  if not ok then
    -- 旧版 markdown grammar 可能没有 setext_heading 节点,退化到只认 atx
    ok, q = pcall(ts.query.parse, "markdown", "(atx_heading) @heading")
  end
  M._query = ok and q or false
  return M._query or nil
end


--- 取 buffer 某行的文本
--- @param bufnr integer buffer 句柄
--- @param row integer   行号(0-based)
--- @return string       行文本;越界返回 ""
local function line_of(bufnr, row)
  return api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
end


--- 根据标题节点确定层级、虚拟编号插入位置
---
--- 层级来源优先级: atx_hN_marker / setext_hN_underline 子节点 > 数行首 # 个数。
--- 插入位置取正文节点(heading_content 或旧版 inline)起点;找不到时跳过
--- "# " 前缀后的位置。Setext 标题的插入位置退化到节点首列。
--- @param bufnr integer buffer 句柄(用于取行文本兜底)
--- @param node TSNode   atx_heading 或 setext_heading 节点
--- @return MdHeading   仅填充 row/col/start_row/level,number 由后续计算
local function heading_from_node(bufnr, node)
  local ntype = node:type()
  local srow, scol = node:start()
  local level, crow, ccol

  for child in node:iter_children() do
    local ctype = child:type()
    if not level then
      -- atx_h1_marker .. atx_h6_marker / setext_h1_underline .. setext_h6_underline
      level = tonumber(ctype:match("^atx_h([1-6])_marker$"))
           or tonumber(ctype:match("^setext_h([1-6])_underline$"))
    end
    -- 新版 grammar 是 heading_content,旧版正文直接是 inline 节点
    if not crow and (ctype == "heading_content" or ctype == "inline") then
      crow, ccol = child:start()
    end
  end

  if ntype == "setext_heading" then
    level = level or 1
    crow, ccol = crow or srow, ccol or scol
  end

  -- 兜底: 数行首 # 的个数
  if not level then
    local hashes = line_of(bufnr, srow):match("^%s*(#+)")
    level = math.min(math.max(hashes and #hashes or 1, 1), 6)
  end

  -- 兜底: 跳过 "# " 前缀算正文列
  -- 注意 string.find 返回含尾 1-based 下标,恰好等于"匹配之后"的 0-based 列
  if not crow then
    crow, ccol = srow, scol
    local _, e = line_of(bufnr, srow):find("^%s*#+%s*")
    if e then
      ccol = e
    end
  end

  return { row = crow, col = ccol, start_row = srow, level = level }
end


--- 解析 buffer，获取所有标题，按文档顺序排序
---
--- 排序按 (row, col) 升序,保证嵌套标题(如 block quote 内)也按出现顺序计数。
--- 解析失败(parser 缺失等)时返回空表，不报错。
--- @param bufnr integer|nil 目标 buffer/nil/0 表示当前 buffer
--- @return MdHeading[]      标题列表(number 字段尚未计算)
function M.parse(bufnr)
  bufnr = utils.bufnr(bufnr)
  local headings = {}
  local query = get_query()
  if not query then
    return headings
  end

  local ok, parser = pcall(ts.get_parser, bufnr, "markdown")
  if not ok or not parser then
    return headings
  end

  -- parse() 不带参数只解析第一棵树;markdown 的标题都挂在 root tree 上,
  -- 嵌在代码块里的内容由 injection 分离到独立 tree,不会被 query 命中
  local trees = parser:parse()
  if not trees or not trees[1] then
    return headings
  end

  for _, node in query:iter_captures(trees[1]:root(), bufnr, 0, -1) do
    headings[#headings + 1] = heading_from_node(bufnr, node)
  end

  table.sort(headings, function(a, b)
    if a.row == b.row then
      return a.col < b.col
    end
    return a.row < b.row
  end)
  return headings
end


-- %% =======================================================================
--  编号计算
-- ==========================================================================

--- 按文档顺序给标题列表编号(原地写入 h.number)
---
--- 计数规则: counters[level] 自增,更深层级清零(标准大纲计数)。
--- 层级缺环且 zero_pad 时补 "0"(如 h1 直接跳 h3 -> "1.0.1")。
--- 超出 [min_level, max_level] 的标题 number 置 nil,但仍会打断层级
--- (即它不显示编号、也不参与自己的计数,后续标题从该层级重新累加)。
--- @param headings MdHeading[] M.parse() 的输出
--- @param opts MdHeadingNumbersOptions 配置(取 separator/zero_pad/min/max)
--- @return nil 原地修改 headings
local function compute_numbers(headings, opts)
  local counters = { 0, 0, 0, 0, 0, 0 }

  for _, h in ipairs(headings) do
    if h.level >= opts.min_level and h.level <= opts.max_level then
      counters[h.level] = counters[h.level] + 1
      for i = h.level + 1, 6 do
        counters[i] = 0
      end

      local parts = {}
      for i = opts.min_level, h.level do
        local n = counters[i]
        -- 缺环补零: 中间层为 0 且 zero_pad 时写 "0";末段必写(即 0 级也要显示)
        if opts.zero_pad or n > 0 or i == h.level then
          parts[#parts + 1] = tostring(n)
        end
      end
      h.number = table.concat(parts, opts.separator)
    else
      h.number = nil
    end
  end
end


-- %% =======================================================================
--  渲染: extmark + virtual text
-- ==========================================================================

--- 把标题列表渲染为 extmark virtual text(先清后画,幂等)
--- @param bufnr integer    目标 buffer
--- @param headings MdHeading[] 已计算编号的标题列表
local function render_heading(bufnr, headings)
  hlmark.clear_virt(bufnr)
  for _, h in ipairs(headings) do
    local text = M.opts.format(h)
    if text then
      local pos = { 0, h.row + 1, h.col + 1, 0 }
      hlmark.virt_line(bufnr, { text = text, pos = pos })
    end
  end
end


-- %% =======================================================================
--  文档处理 API 暴露
-- ==========================================================================

--- 解析 + 编号 + 渲染(若该 buffer 已开启)
---
--- 幂等: 重复调用只是刷新缓存与 decoration。buffer 未加载时保持缓存不动。
--- @param bufnr integer|nil 目标 buffer，nil/0 表示当前 buffer
--- @return MdHeading[]|nil heading 最新的标题列表，buffer 不可用时返回 nil
function M.update(bufnr)
  bufnr = utils.bufnr(bufnr)

  -- 即使未 enabled，依然重新编号，以供外部获取是保持准确
  local headings = M.parse(bufnr)
  compute_numbers(headings, M.opts)
  M._cache[bufnr] = headings

  -- 是否 enabled 仅影响渲染
  if M._enabled[bufnr] then
    render_heading(bufnr, headings)
  end
  return headings
end


--- 取 buffer 的带编号标题列表(供 aerial / statusline 等外部复用)
---
--- 缓存未命中时同步算一次。返回的表由本模块持有,调用方不要修改。
--- @param bufnr integer|nil 目标 buffer,nil/0 表示当前 buffer
--- @return MdHeading[]|nil { {row, col, start_row, level, number}, ... }
function M.get(bufnr)
  bufnr = utils.bufnr(bufnr)
  return M._cache[bufnr] or M.update(bufnr)
end


--- 取某一行(lnum, 1-based)所属章节的编号
---
--- "所属"定义为: 最近的、位于该行之前(含该行)的标题。
--- 例: statusline 里显示当前小节号,或给 aerial 条目打前缀。
--- @param bufnr integer|nil 目标 buffer,nil/0 表示当前 buffer
--- @param lnum integer      行号(1-based,与 getpos() 一致)
--- @return string|nil       编号文本;该行不在任何编号标题范围内返回 nil
function M.number_at(bufnr, lnum)
  local cur = M.get(bufnr)
  if not cur then
    return nil
  end
  local found
  for _, h in ipairs(cur) do
    if h.row + 1 <= lnum then
      found = h
    else
      break
    end
  end
  return found and found.number or nil
end


-- %% =======================================================================
--  模块初始化：合并配置、注册 autocmd 与命令
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  M._query = nil  -- setext 开关可能变化,重建 query

  M.enable, M.disable, M.toggle = bufau.toggle_debounce_au_on_filetypes(
    "users.md_heading_no",
    M.update,
    hlmark.clear_virt,
    M._enabled,
    M.opts.enabled_filetypes,
    { "BufEnter", "TextChanged", "InsertLeave", "BufWritePost" },
    300
  )

  utils.register_select_command("HeadingNo", {
    { subcmd = "", func = M.toggle },
    { subcmd = "toggle", func = M.toggle },
    { subcmd = "on", func = M.enable },
    { subcmd = "off", func = M.disable },
  }, "Markdown 标题序号")

end

return M
