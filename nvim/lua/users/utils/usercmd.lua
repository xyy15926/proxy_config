-- ==========================================================================
-- File    : usercmd.lua
-- Author  : xyy15926
-- Created : 2026-08-28 14:56:19
-- Updated : 2026-08-28 18:38:11
-- Desc    : Register user command helper.
-- ==========================================================================

local M = {}

M.defaults = { }
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  逐行修改内容
-- ==========================================================================
--- 此函数接受索引从 0 开始的行范围，逐行应用函数 `func` 修改行内容
--- 若行内容改变，则整体写回，否则保持不变
--- @param start_line number 起始行号，索引从 0 开始
--- @param end_line number 终止行号，索引从 0 开始
--- @param func function 将被逐行应用的函数
--- @param msg? string 执行完成后的提示信息
function M.apply_on_0range_lines(start_line, end_line, func, msg)
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)
  local changed = 0

  for i, line in ipairs(lines) do
    local new_line = func(line)
    if new_line ~= line then
      lines[i] = new_line
      changed = changed + 1
    end
  end

  msg = msg or "updated"
  if changed > 0 then
    vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, lines)
    vim.notify(changed .. " lines hased been " .. msg .. ".")
  end
end

--- 此函数接受索引从 1 开始的行范围，逐行应用函数 `func` 修改行内容
--- `vim.fn` 接口返回行索引从 1 开始计数
--- @param start_line number 起始行号，索引从 1 开始
--- @param end_line number 终止行号，索引从 1 开始
--- @param func function 将被逐行应用的函数
--- @param msg? string 执行完成后的提示信息
function M.apply_on_1range_lines(start_line, end_line, func, msg)
  -- Range 范围是 1-based，内部手动处理
  return M.apply_on_0range_lines(start_line - 1, end_line - 1, func, msg)
end


-- %% =======================================================================
--  命令注册
-- ==========================================================================
--- 将针对单行应用、修改的函数注册为用户命令
--- @param func function 将被逐行应用的函数
--- @param cmd string 命令名称
--- @param desc? string 命令描述
--- @param msg? string 命令执行完成后的提示信息
function M.register_range_apply_command(func, cmd, desc, msg)
  vim.api.nvim_create_user_command(cmd, function(args)
    M.apply_on_1range_lines(args.line1, args.line2, func, desc or msg)
  end, { range = true, nargs = 0, desc = desc })
end


-- %% =======================================================================
--  对可视选区、当前行应用函数
-- ==========================================================================
--- 对可视选区内文本逐行应用 `func`、修改内容
--- 若行内容改变，则整体写回，否则保持不变
--- @deprecated Use apply_on_1range_lines or register_range_command instead
--- @param func function 将被逐行应用的函数
--- @param msg? string 执行完成后的提示信息
function M.apply_on_visual_range_lines(func, msg)
  -- 获取可视选区范围（0-indexed）
  local start_line = vim.fn.line("v") - 1
  local end_line   = vim.fn.line(".") - 1
  -- local region = vim.fn.getregionpos(
  --   vim.fn.getpos("v"), vim.fn.getpos("."), { type = "V", inclusive = true }
  -- )
  -- local start_line = region[1][1][2]        -- 第一个位置的行号
  -- local end_line   = region[#region][2][2]  -- 最后一个位置的行号
  M.apply_on_0range_lines(start_line, end_line, func, msg)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false
  )
end

--- 对当前行应用 `func`、修改内容
--- 若行内容发生改变，则写回，否则保持不变
--- @deprecated Use apply_on_1range_lines or register_range_command instead
--- @param func function 将被逐行应用的函数
function M.apply_on_current_line(func)
  local line = vim.api.nvim_get_current_line()
  local new_line = func(line)
  vim.notify(line, new_line)
  if new_line ~= line then
    vim.api.nvim_set_current_line(new_line)
  end
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  return M
end

return M
