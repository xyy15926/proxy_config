-- ==========================================================================
-- File    : markdown.lua
-- Author  : xyy15926
-- Created : 2026-09-08 16:41:13
-- Updated : 2026-09-08 16:41:13
-- Desc    : Dev tools for markdown.
--
-- --------------------------------------------------------------------------
-- TODO:
-- 1. 尝试用 vim.treesitter 写基于语法解析树的版本，但是
--   `vim.treesitter.get_node()` 获取的节点不一定是叶子节点
-- 1.1. 即直接通过 `get_node()` 的节点可能不是类似 `inline` 的链接类型、或其
--   子节点，反而可能是 `inline` 的父节点
--   （`get_node():type()` 获取节点类型）
-- 1.2. 则无法通过向上查找父节点获取所需的节点、节点内容
-- 1.3. 因为 vim.treesitter 的默认接口都倾向 named node，拿到真正的叶子节点
--   比较麻烦
-- ==========================================================================

local M = {}

M.defaults = { }
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  查找 markdown 中 ref 对应链接
--  正则版
-- ==========================================================================
--- 在全文中查找引用式链接的定义
--- 搜索形如 [ref]: url 的行，返回 url
---@param ref string 小写的引用标签，如 "guide"
---@return string|nil 目标地址，未找到返回 nil
local function find_ref_def(ref)
  for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    -- 匹配 [ref]: url，vim.pesc 转义 ref 中的特殊字符
    local dest = l:match("^%[" .. vim.pesc(ref) .. "%]:%s+(.+)")
    if dest then return dest end
  end
end


--- 获取光标所在 markdown 链接的目标地址（纯正则版）
--- 支持四种链接格式：
---   行内链接：     [text](url)       → 直接返回 url
---   引用式链接：   [text][ref]       → 查找 [ref]: url 定义
---   隐式引用：     [text][]          → 用 text 作为 ref 查找定义
---   快捷引用：     [text]            → 用 text 作为 ref 查找定义
--- @return string|nil 链接地址，未找到返回 nil
function M.get_markdown_link_regex()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  local start

  -- 1. [text](url) 行内链接：直接提取括号中的 url
  start = 1
  while true do
    local s, e, link = line:find("%[.-%]%(([^)]+)%)", start)
    if not s then break end
    if col >= s and col <= e then return link end
    start = e + 1
  end

  -- 2. [text][ref] 引用式链接：用 ref 去全文查找定义
  start = 1
  while true do
    local s, e, _, ref = line:find("%[.-%]%[([^%]]+)%]", start)
    if not s then break end
    if col >= s and col <= e then
      return find_ref_def(ref:lower())
    end
    start = e + 1
  end

  -- 3. [text][] 隐式引用：用 text 本身作为 ref 去查找定义
  start = 1
  while true do
    local s, e, text = line:find("%[(.-)%]%[%]", start)
    if not s then break end
    if col >= s and col <= e then
      return find_ref_def(text:lower())
    end
    start = e + 1
  end

  -- 4. [text] 快捷引用：用 text 本身作为 ref 去查找定义
  start = 1
  while true do
    local s, e, text = line:find("%[([^%]]+)%]", start)
    if not s then break end
    if col >= s and col <= e then
      return find_ref_def(text:lower())
    end
    start = e + 1
  end

  return nil
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  return M
end

return M
