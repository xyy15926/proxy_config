-- ==========================================================================
-- File    : mark_jump.lua
-- Author  : xyy15926
-- Created : 2026-08-25 22:04:08
-- Updated : 2026-09-27 14:32:35
-- Desc    : Jump to the line with mark string.
-- ==========================================================================

local utils = require("users.utils")
local hlmark = require("users.hlmark")
local bufau = require("users.bufau")

local M = {}

M.defaults = {
  wrap = true,
  set_keymap = true,
  enabled_filetypes = {
    "python", "rust", "cpp", "c",
    "markdown",
    "lua", "shell",
  },
}

-- 1. 按文件类型默认标记正则
-- 2. 可用以下 Ex 命令将 `-- ====` 替换为 `-- %% =`
--  `:let i=0 | g/^-- ====$/let i+=1 | if i%2==1 && i > 2 | s/^-- ====$/-- %% =/ | endif`
M.defaults.marks = {
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
  codecompanion = { "^## ", "^### ", "^#### ", "^##### " },
}

M.opts = vim.deepcopy(M.defaults)

--- @class MarkLine
--- @field lnum integer
--- @field line string
---
--- 缓存 buffer 结果
--- @type table<integer, MarkLine[]>
M._cache = {}


--- 维护是否对 buffer 生效标志
--- @type table<integer, boolean>
M._enabled = {}


-- %% =======================================================================
--  标记 pattern 设置、获取
-- ==========================================================================

--- 获取 buffer 对应文件类型的标记模式
--- @param bufnr integer?
--- @return string[] patterns
function M.get_patterns(bufnr)
  bufnr = utils.bufnr(bufnr)
  local ft = vim.bo[bufnr].filetype
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
--  扫描缓冲区标记
-- ==========================================================================

--- 扫描缓冲区中的所有标记并记录
--- @param bufnr integer?
--- @return table<{lnum: integer, line: string}>
local function scan_marks(bufnr)
  bufnr = utils.bufnr(bufnr)
  local marks = {}

  -- 获取标记 patterns
  local patterns = M.get_patterns(bufnr)
  if #patterns == 0 then
    return marks
  end

  -- 逐行扫描获取标记行
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for lnum, line in ipairs(lines) do
    for _, pat in ipairs(patterns) do
      if line:match(pat) then
        table.insert(marks, {
          lnum = lnum,
          line = line,
        })
        -- 高亮标记行
        hlmark.mark_line(bufnr, lnum)
        break
      end
    end
  end

  M._cache[bufnr] = marks
  return marks
end


-- %% =======================================================================
--  标记跳转
-- ==========================================================================

--- 跳转到下一个标记
--- @param bufnr integer?
function M.next_mark(bufnr)
  bufnr = utils.bufnr(bufnr)
  local marks = M._cache[bufnr]
  if marks == nil or #marks == 0 then
    vim.notify("未找到标记", vim.log.levels.INFO)
    return
  end

  -- 定位当前光标位置
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
    hlmark.flash_line(0, target.lnum)
  else
    vim.notify("已到最后一个标记", vim.log.levels.INFO)
  end
end


--- 跳转到上一个标记
--- @param bufnr integer?
function M.prev_mark(bufnr)
  bufnr = utils.bufnr(bufnr)
  local marks = M._cache[bufnr]
  if marks == nil or #marks == 0 then
    vim.notify("未找到标记", vim.log.levels.INFO)
    return
  end

  -- 定位当前光标位置
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
    hlmark.flash_line(0, target.lnum)
  else
    vim.notify("已到第一个标记", vim.log.levels.INFO)
  end
end


--- 列出所有标记并选择跳转
--- @param bufnr integer?
function M.list_marks(bufnr)
  bufnr = utils.bufnr(bufnr)
  local marks = M._cache[bufnr]
  if marks == nil or #marks == 0 then
    vim.notify("未找到标记", vim.log.levels.INFO)
    return
  end

  local items = {}
  for _, mark in ipairs(marks) do
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
      hlmark.flash_line(0, target.lnum)
    end
  end)
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- 注册自动命令：自动命令将在符合条件 buffer 上注册自动命令，自动更新 marks
  M.enable, M.disable, M.toggle = bufau.toggle_debounce_au_on_filetypes(
    "users.mark_line",
    scan_marks,
    hlmark.clear_mark,
    M._enabled,
    M.opts.enabled_filetypes,
    { "BufEnter", "TextChanged", "InsertLeave" },
    1000
  )

  -- 创建用户自定义命令
  utils.register_select_command(
    "MarkJump",
    {
      { subcmd = "enable", func = M.enable },
      { subcmd = "disable", func = M.disable },
      { subcmd = "toggle", func = M.toggle },
      { subcmd = "next", func = M.next_mark },
      { subcmd = "prev", func = M.prev_mark },
      { subcmd = "list", func = M.list_marks },
    },
    "高亮标记行、跳转"
  )

  if M.opts.set_keymap then
    vim.keymap.set("n", "<leader>jj", M.next_mark, { desc = "Mark: Next Mark"})
    vim.keymap.set("n", "<leader>ju", M.prev_mark, { desc = "Mark: Prev Mark"})
  end
end

return M
