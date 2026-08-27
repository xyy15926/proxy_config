-- ================================================
-- 快速切换 markdown 待办、切换待办
-- ================================================

local M = {}

M.defaults = {
  set_keymap = true,
}

M.opts = vim.deepcopy(M.defaults)
local utils = require("users.utils")

-- ===========================================================================
--    ToDo 项转换、状态切换
-- ===========================================================================
-- 将行文本转换为 `[]` todo 项
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

-- Toggle todo 项状态
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

-- ===========================================================================
--   配置、初始化
-- ===========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  utils.register_range_command(
    M.toggle_line_todo,
    "ToggleTodo",
    "Toggle Todo Item",
    "toggled"
  )
  utils.register_range_command(
    M.convert_line_todo,
    "Convert2Todo",
    "Convert to Todo Item",
    "converted to todo items"
  )
  -- vim.api.nvim_create_user_command("ToggleTodo", function(args)
  --   utils.apply_on_1range_lines(args.line1, args.line2, M.toggle_line_todo)
  -- end, { range = true, nargs = 0, desc = "Range 操作 Toggle" })

  if M.opts.set_keymap then
    vim.keymap.set("n", "<leader>ud", ":ToggleTodo<cr>", { buffer = true, silent = true, desc = "Toggle Markdown Todo" })
    vim.keymap.set("v", "<leader>ud", ":ToggleTodo<cr>", { buffer = true, silent = true, desc = "Toggle Markdown Todo" })
  end
end

return M
