-- =========================================================
-- File    : mark_jump.lua
-- Author  : xyy15926
-- Created : 2026-08-25 22:04:08
-- Updated : 2026-08-26 15:17:30
-- Desc    : Jump to the line with mark string.
-- =========================================================

local M = {}
M.defaults = {
  -- 自动配置键盘映射
  set_keymap = true,

  -- 自动退出高亮
  auto_clear = true,                 -- 跳转后自动清除高亮
  auto_clear_delay = 800,            -- 自动清除延迟（毫秒）

  -- 行为
  wrap = true,                       -- 到达末尾是否循环到开头
  show_sign = true,                  -- 是否在标记行显示侧边符号
  sign_text = "▶",                   -- 侧边符号
  sign_group = "MarkJumpSign",
  sign_priority = 100,

  -- 按文件类型定义标记正则
  marks = {
    python = { "# %%%%" },
    markdown = { "^## ", "^### ", "^#### ", "^##### " },
    lua = { "^%-%- %=%=", "^%-%- %-%- " },
    javascript = { "^// %=%=", "^// MARK:" },
    typescript = { "^// %=%=", "^// MARK:" },
    javascriptreact = { "^// %=%=", "^// MARK:" },
    typescriptreact = { "^// %=%=", "^// MARK:" },
    sh = { "^# %=%=", "^# MARK:" },
    bash = { "^# %=%=", "^# MARK:" },
    zsh = { "^# %=%=", "^# MARK:" },
    vim = { '^"%=%=', '" MARK:' },
    yaml = { "^# %=%=", "^# MARK:" },
    toml = { "^# %=%=", "^# MARK:" },
    rust = { "^// %=%=", "^// MARK:" },
    go = { "^// %=%=", "^// MARK:" },
    c = { "^// %=%=", "^// MARK:" },
    cpp = { "^// %=%=", "^// MARK:" },
    java = { "^// %=%=", "^// MARK:" },
  },

  -- 高亮配置
  highlight = {
    group = "MarkJumpHighlight",  -- 高亮组名
    fg = "#1a1a1a",               -- 前景色
    bg = "#654300",               -- 背景色（醒目黄色）
    bold = true,
    -- 或直接用 link = "IncSearch" 链接到现有高亮组
  },
}
M.opts = vim.deepcopy(M.defaults)

-- -------------------- 内部状态 --------------------
local ns_id = vim.api.nvim_create_namespace("mark-jump")
local timer = nil
local current_marks = {}  -- 缓存当前缓冲区的标记位置

-- -------------------- 初始化高亮组 --------------------
local function setup_highlight()
  local hl = M.opts.highlight
  if hl.link then
    vim.api.nvim_set_hl(0, hl.group, { link = hl.link })
  else
    vim.api.nvim_set_hl(0, hl.group, {
      fg = hl.fg,
      bg = hl.bg,
      bold = hl.bold,
      default = false,
    })
  end
end

-- -------------------- 定义侧边符号 --------------------
local function setup_sign()
  if not M.opts.show_sign then return end
  vim.fn.sign_define(M.opts.sign_group, {
    text = M.opts.sign_text,
    texthl = "Special",
    numhl = "",
  })
end

-- -------------------- 获取当前文件类型的标记模式 --------------------
local function get_patterns()
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

-- -------------------- 扫描缓冲区中的所有标记 --------------------
local function scan_marks()
  local patterns = get_patterns()
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

-- -------------------- 高亮指定行 --------------------
local function highlight_line(lnum)
  -- 清除之前的高亮
  M.clear_highlight()

  -- 设置行高亮
  vim.api.nvim_buf_set_extmark(0, ns_id, lnum - 1, 0, {
    end_line = lnum,
    hl_group = M.opts.highlight.group,
    hl_eol = true,
    priority = 200,
  })

  -- 设置侧边符号
  if M.opts.show_sign then
    vim.fn.sign_place(0, M.opts.sign_group, M.opts.sign_group, vim.api.nvim_get_current_buf(), {
      lnum = lnum,
      priority = M.opts.sign_priority,
    })
  end

  -- 自动清除
  if M.opts.auto_clear then
    if timer then
      timer:stop()
      timer:close()
    end
    timer = vim.loop.new_timer()
    timer:start(M.opts.auto_clear_delay, 0, vim.schedule_wrap(function()
      M.clear_highlight()
    end))
  end
end

-- -------------------- 清除高亮 --------------------
function M.clear_highlight()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  if M.opts.show_sign then
    -- 用实际 bufnr 代替 0，修复 E158 错误
    vim.fn.sign_unplace(M.opts.sign_group, { buffer = vim.api.nvim_get_current_buf() })
  end
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

-- -------------------- 跳转到下一个标记 --------------------
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
    highlight_line(target.lnum)
  else
    vim.notify("已到最后一个标记", vim.log.levels.INFO)
  end
end

-- -------------------- 跳转到上一个标记 --------------------
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
    highlight_line(target.lnum)
  else
    vim.notify("已到第一个标记", vim.log.levels.INFO)
  end
end

-- -------------------- 列出所有标记并选择跳转 --------------------
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
      highlight_line(target.lnum)
    end
  end)
end

-- -------------------- 添加/配置用户自定义标记 --------------------
-- 在 init.lua 中调用: require("mark-jump").add_mark("myfiletype", {"^pattern1", "^pattern2"})
function M.add_mark(filetype, patterns)
  M.opts.marks[filetype] = patterns
end

-- -------------------- 设置/更新配置 --------------------
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  setup_highlight()
  setup_sign()

  -- 创建用户命令
  vim.api.nvim_create_user_command("MarkJumpNext", M.next_mark, { desc = "Next Mark" })
  vim.api.nvim_create_user_command("MarkJumpPrev", M.prev_mark, { desc = "Prev Mark" })
  vim.api.nvim_create_user_command("MarkJumpList", M.list_marks, { desc = "List Marks" })
  vim.api.nvim_create_user_command("MarkJumpClear", M.clear_highlight, { desc = "Clear Highlight" })

  -- 自动命令：缓冲区切换/内容改变时刷新标记缓存
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
    group = vim.api.nvim_create_augroup("MarkJumpRefresh", { clear = true }),
    callback = function()
      scan_marks()
    end,
  })

  if M.opts.set_keymap then
    vim.keymap.set("n", "<leader>mn", M.next_mark, { desc = "Next Mark"})
    vim.keymap.set("n", "<leader>mp", M.prev_mark, { desc = "Prev Mark"})
  end
end

return M
