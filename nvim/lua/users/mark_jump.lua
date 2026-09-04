-- ==========================================================================
-- File    : mark_jump.lua
-- Author  : xyy15926
-- Created : 2026-08-25 22:04:08
-- Updated : 2026-09-04 09:22:15
-- Desc    : Jump to the line with mark string.
-- ==========================================================================

local M = {}
M.defaults = {
  set_keymap = true,
  hl_group    = "MarkUnderline",
  priority    = 50,
  hl_opts = {
    sp        = "#E8A043",
    underline = true,
  },
}
M.opts = vim.deepcopy(M.defaults)

local utils = require("users.utils")

-- %% =======================================================================
--  标记模式设置
--  可用以下 Ex 命令将 `-- ====` 替换为 `-- %% =`
--  :let i=0 | g/^-- ====$/let i+=1 | if i%2==1 && i > 2 | s/^-- ====$/-- %% =/ | endif
-- ==========================================================================
-- 按文件类型默认标记正则
local ft_marks = {
  python = { "^%s*# %%%%", "^%s*# MARK:" },
  markdown = { "^## ", "^### ", "^#### ", "^##### " },
  lua = { "^%s*%-%- %%%%", "^%s*%-%- MARK:" },
  javascript = { "^%s*// %%%%", "^%s*// MARK:" },
  typescript = { "^%s*// %%%%", "^%s*// MARK:" },
  javascriptreact = { "^%s*// %%%%", "^%s*// MARK:" },
  typescriptreact = { "^%s*// %%%%", "^%s*// MARK:" },
  sh = { "^%s*# %%%%", "^%s*# MARK:" },
  bash = { "^%s*# %%%%", "^%s*# MARK:" },
  zsh = { "^%s*# %%%%", "^%s*# MARK:" },
  vim = { '^%s*"%%%%', '" MARK:' },
  yaml = { "^%s*# %%%%", "^%s*# MARK:" },
  toml = { "^%s*# %%%%", "^%s*# MARK:" },
  rust = { "^%s*// %%%%", "^%s*// MARK:" },
  go = { "^%s*// %%%%", "^%s*// MARK:" },
  c = { "^%s*// %%%%", "^%s*// MARK:" },
  cpp = { "^%s*// %%%%", "^%s*// MARK:" },
  java = { "^%s*// %%%%", "^%s*// MARK:" },
}
local current_marks = {}  -- 缓存当前缓冲区的标记位置

--- 更新文件类型对应标记模式
local function update_marks()
  if M.opts.marks then
    for ft, ptn in pairs(ft_marks) do
      if M.opts.marks[ft] ~= nil then
        M.opts.marks[ft] = ptn
      end
    end
  else
    M.opts.marks = ft_marks
  end
end

--- 获取当前文件类型的标记模式
function M.get_patterns()
  local ft = vim.bo.filetype
  local patterns = M.opts.marks[ft]
  if not patterns then
    -- 尝试从文件名匹配
    local name = vim.fn.expand("%:t")
    if name:match("%.py$") then
      patterns = M.opts.marks.python
    elseif name:match("%.md$") then
      patterns = M.opts.marks.markdown
    end
  end
  return patterns or {}
end


-- %% =======================================================================
--  高亮
-- ==========================================================================
function M.setup_highlight()
  if M.opts.hl_opts.link then
    vim.api.nvim_set_hl(0, M.opts.hl_group, { link = M.otps.hl_opts.link })
  else
    vim.api.nvim_set_hl(0, M.opts.hl_group, M.opts.hl_opts)
  end
end

--- 对已扫描出的标记行应用高亮
local function apply_highlights()
  local ns_id = vim.api.nvim_create_namespace("mark_underline")
  local buf = vim.api.nvim_get_current_buf() or 0
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  for _, mark in ipairs(current_marks) do
    vim.api.nvim_buf_set_extmark(buf, ns_id, mark.lnum - 1, 0, {
      end_line   = mark.lnum,
      hl_group   = M.opts.hl_group,
      hl_eol     = true,
      priority   = M.opts.priority,
    })
  end
end


-- %% =======================================================================
--  扫描缓冲区标记
-- ==========================================================================
-- 扫描缓冲区中的所有标记
local function scan_marks()
  local patterns = M.get_patterns()
  if #patterns == 0 then
    current_marks = {}
    return current_marks
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local marks = {}

  for lnum, line in ipairs(lines) do
    for _, pat in ipairs(patterns) do
      if line:match(pat) then
        table.insert(marks, {
          lnum = lnum,
          line = line,
          col = 0,
        })
        break
      end
    end
  end

  current_marks = marks
  return marks
end


-- %% =======================================================================
--  标记跳转
-- ==========================================================================
--- 跳转到下一个标记
function M.next_mark()
  local marks = scan_marks()
  if #marks == 0 then
    vim.notify("未找到标记", vim.log.levels.WARN)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_lnum = cursor[1]

  local target = nil
  for _, mark in ipairs(marks) do
    if mark.lnum > current_lnum then
      target = mark
      break
    end
  end

  -- 循环到第一个
  if not target and M.opts.wrap then
    target = marks[1]
  end

  if target then
    vim.api.nvim_win_set_cursor(0, { target.lnum, 0 })
    utils.flash_line(0, target.lnum)
  else
    vim.notify("已到最后一个标记", vim.log.levels.INFO)
  end
end

--- 跳转到上一个标记
function M.prev_mark()
  local marks = scan_marks()
  if #marks == 0 then
    vim.notify("未找到标记", vim.log.levels.WARN)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_lnum = cursor[1]

  local target = nil
  for i = #marks, 1, -1 do
    if marks[i].lnum < current_lnum then
      target = marks[i]
      break
    end
  end

  -- 循环到最后一个
  if not target and M.opts.wrap then
    target = marks[#marks]
  end

  if target then
    vim.api.nvim_win_set_cursor(0, { target.lnum, 0 })
    utils.flash_line(0, target.lnum)
  else
    vim.notify("已到第一个标记", vim.log.levels.INFO)
  end
end

--- 列出所有标记并选择跳转
function M.list_marks()
  local marks = scan_marks()
  if #marks == 0 then
    vim.notify("未找到标记", vim.log.levels.WARN)
    return
  end

  local items = {}
  for i, mark in ipairs(marks) do
    local text = mark.line:gsub("^%s*", ""):sub(1, 60)
    table.insert(items, string.format("%3d: %s", mark.lnum, text))
  end

  vim.ui.select(items, {
    prompt = "选择标记跳转:",
    format_item = function(item) return item end,
  }, function(choice, idx)
    if choice and idx then
      local target = marks[idx]
      vim.api.nvim_win_set_cursor(0, { target.lnum, 0 })
      utils.flash_line(0, target.lnum)
    end
  end)
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  M.setup_highlight()
  update_marks()

  -- 创建用户命令
  vim.api.nvim_create_user_command("MarkJumpNext", M.next_mark, { desc = "Next Mark" })
  vim.api.nvim_create_user_command("MarkJumpPrev", M.prev_mark, { desc = "Prev Mark" })
  vim.api.nvim_create_user_command("MarkJumpList", M.list_marks, { desc = "List Marks" })

  -- 缓冲区切换/内容改变时刷新标记缓存
  -- 1. `current_marks` 只存储单个 buffer 中标记
  -- 2. 但每次切换 buffer 都会执行 `scan_marks` 更新
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
    group = vim.api.nvim_create_augroup("MarkJumpRefresh", { clear = true }),
    callback = function()
      scan_marks()
      apply_highlights()
    end,
  })

  if M.opts.set_keymap then
    vim.keymap.set("n", "<leader>mn", M.next_mark, { desc = "Next Mark"})
    vim.keymap.set("n", "<leader>mp", M.prev_mark, { desc = "Prev Mark"})
  end
end

return M
