-- ==========================================================================
-- File    : markdown_todo.lua
-- Author  : xyy15926
-- Created : 2026-08-28 10:42:21
-- Updated : 2026-08-28 17:28:10
-- Desc    : Convert and toggle todo items.
-- ==========================================================================

local M = {}

M.defaults = {
  set_keymap = true,
}
M.opts = vim.deepcopy(M.defaults)
local utils = require("users.utils")


-- ==========================================================================
--  Todo 项转换、状态切换
-- ==========================================================================
---将行文本转换为 `[]` todo 项
---@param line string Line to be converted into todo items.
---@return string new_Line Line converted into todo items.
function M.convert_line_todo(line)
  local new_line = line

  -- 1. 普通列表项转 todo：- item -> - [ ] item
  if new_line == line then
    new_line = line:gsub("^([%s]*[-*+][%s]+)([^%[].*)$", function(prefix, content)
      return prefix .. "[ ] " .. content
    end)
  end

  -- 2. 有序列表转 todo：1. item -> 1. [ ] item
  if new_line == line then
    new_line = line:gsub("^([%s]*%d+%.[%s]+)([^%[].*)$", function(prefix, content)
      return prefix .. "[ ] " .. content
    end)
  end

  -- 3. 纯文本转 todo：item -> - [ ] item
  if new_line == line then
    local indent = line:match("^%s*") or ""
    local content = line:sub(#indent + 1)
    if content ~= "" then
      new_line = indent .. "- [ ] " .. content
    end
  end
  return new_line

end

---Toggle todo 项状态
---@param line string Todo items to be toggled the status.
---@return string line
function M.toggle_line_todo(line)
  local new_line = line

  -- 1. 已有 checkbox 则切换：- [ ] <-> - [x]
  new_line = line:gsub("^([%s]*[-*+][%s]+)%[([ xX])%]", function(prefix, status)
    return prefix .. "[" .. (status == " " and "x" or " ") .. "]"
  end)

  -- 2. 有序列表 checkbox 切换：1. [ ] <-> 1. [x]
  if new_line == line then
    new_line = line:gsub("^([%s]*%d+%.[%s]+)%[([ xX])%]", function(prefix, status)
      return prefix .. "[" .. (status == " " and "x" or " ") .. "]"
    end)
  end

  return new_line
end


-- ==========================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  utils.register_range_apply_command(
    M.toggle_line_todo,
    "ToggleTodo",
    "Toggle Todo Item",
    "toggled"
  )
  utils.register_range_apply_command(
    M.convert_line_todo,
    "Convert2Todo",
    "Convert to Todo Item",
    "converted to todo items"
  )

  if M.opts.set_keymap then
    vim.keymap.set( { "n", "v" }, "<leader>cd", ":ToggleTodo<cr>", { silent = true, desc = "Toggle Markdown Todo" })
  end
end

return M
