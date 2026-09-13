-- ==========================================================================
-- File    : vimpath.lua
-- Author  : xyy15926
-- Created : 2026-09-12 22:24:29
-- Updated : 2026-09-13 22:08:27
-- Desc    : Path compeletion sources for path with only ASCII chars.
--
-- Ref:
-- - lazy/blink.cmp/doc/configuration/sources.md
-- - lazy/blink.cmp/doc/development/source-boilerplate.md
-- ==========================================================================

---@class vimpath.Options
---@field max_items? integer
---@field find_path? string[]

---@class vimpath.Source
---@field opts vimpath.Options

---@class vimpath.CompletionResponse
---@field items blink.cmp.CompletionItem[]
---@field is_incomplete_forward boolean
---@field is_incomplete_backward boolean

local M = {}
M.defaults = {
  max_items = 200,
  find_path = {
    "",
    "."
  }
}
local PATH_CHAR = "[%w_%-%.%/~]"
local scan_directories = require("users.utils").scan_directories
local ItemKind = require('blink.cmp.types').CompletionItemKind

-- %% =======================================================================
--  功能函数
-- ==========================================================================
--- 从光标位置向左扫描，提取完整的路径 token
--- 允许的字符：字母数字、_ - . ~ /
---@param line string  当前行文本
---@param col number  光标 0-indexed 字节偏移
---@return string prefix  已输入的路径文本
---@return number start_col  路径起始的 0-indexed 列号
local function extract_prefix(line, col)
  local before = line:sub(1, col)
  local pos = #before
  while pos >= 1 do
    if before:sub(pos, pos):match(PATH_CHAR) then
      pos = pos - 1
    else
      break
    end
  end
  return before:sub(pos + 1), pos
end


--- 将前缀拆为目录部分和文件名部分。
--- "lib/uti" → dir_part="lib", name_part="uti"
--- "foo"     → dir_part="",    name_part="foo"
--- "lib/"    → dir_part="lib", name_part=""
---@param prefix string   原始前缀
---@return string dir_part   目录部分
---@return string name_part  待匹配的文件名部分
local function split_prefix(prefix)
  local dir_part  = prefix:match('^(.+)/') or ''
  local name_part = prefix:match('([^/]+)$') or ''
  return dir_part, name_part
end


-- %% =======================================================================
--  唯二必须函数
-- ==========================================================================
--- @param opts? vimpath.Options
--- @return vimpath.Source
function M.new(opts)
  local self = setmetatable({}, { __index = M })
  self.opts = vim.tbl_deep_extend("force", {}, M.defaults, opts)
  return self
end


--- 核心补全函数
--- @param context blink.cmp.Context
--- @param callback fun(response: vimpath.CompletionResponse): nil
function M:get_completions(context, callback)
  local line  = context.line
  local col   = context.cursor[2]       -- 0-indexed 字节偏移
  local row_0 = context.cursor[1] - 1   -- 0-indexed 行号

  local prefix, start_col = extract_prefix(line, col)
  local dir_part, name_part = split_prefix(prefix)

  local path_dirs = self.opts.find_path
  if #path_dirs == 0 then
    callback({
      items = {},
      is_incomplete_forward = false,
      is_incomplete_backward = false,
    })
    return
  end
  local matches = scan_directories(path_dirs, dir_part, name_part)
  local items = {}
  for _, mat in ipairs(matches) do
    table.insert(items, {
      label = mat.name,
      insertText = mat.name,
      detail = mat.scan_dir .. "/" .. mat.name,
      -- 排序：目录优先
      sortText   = (mat.is_dir and "0" or "1") .. mat.name:lower(),
      -- 控制替换范围，不定义默认效果也还好？
      textEdit   = {
        newText = mat.name,
        range   = {
          -- 只替换 name_part，即未完整输入部分
          start = { line = row_0, character = col - #name_part },
          -- `end` 是关键字，必须使用完整语法
          ["end"] = { line = row_0, character = col },
        },
      },
      -- 用自定义 icon, name
      -- kind = mat.is_dir and ItemKind.Folder or ItemKind.File,
      kind_icon = "󰷋",
      kind_name = mat.is_dir and "Folder" or "File",
    })
  end

  -- 必须调用回调函数
  callback({
    items = items,
    is_incomplete_forward = true,
    is_incomplete_backward = false,
  })
end


-- %% =======================================================================
--  可选方法
-- ==========================================================================
--- @return boolean
function M:enabled()
  return vim.o.path ~= nil and vim.o.path ~= ""
end


--- 补充除默认 blink.cmp 关键词外的触发字符
--- @return string[]
function M:get_trigger_characters()
  return { "/", "." }
end


--- 选中选项后执行，用于执行大开销动作
--- @param item blink.cmp.CompletionItem
--- @param callback fun(item: blink.cmp.CompletionItem): nil
function M:resolve(item, callback)
  callback(item)
end

return M
