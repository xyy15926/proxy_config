-- ==========================================================================
-- File    : init.lua
-- Author  : xyy15926
-- Created : 2026-08-27 22:28:31
-- Updated : 2026-08-28 19:33:36
-- Desc    : Init user mods.
-- ==========================================================================

require("users.rooter").setup({
  root_flags = { ".root", ".svn", ".git", ".hg", ".project", "Makefile" },
  file_ptns = "*",
})
require("users.daily_todo").setup({
  todo_base = vim.fn.expand("~/files.md/gtd"),
})
require("users.heading_file").setup({
  auto_file_ptns = {
    "*.py",
    "*.rs",
    "*.lua",
    "*.md",
    "*.c", "*.cpp", "*.h",
    "*.sh",
  },
})
require("users.pyenv").setup()
require("users.markdown_todo").setup({
  set_keymap = true,
  auto_file_ptns = { "*.md", },
})
require("users.yank2gclip").setup({
  win32yank = "/mnt/d/win32yank/win32yank.exe",
})
require("users.mark_jump").setup({ set_keymap = true })
require("users.alignment").setup({
  min_spaces = 2,      -- 代码与注释之间至少保留的空格数
  search_range = 10,   -- 上下搜索的行数范围
  auto_align = false,  -- 退出 Insert 自动对齐
  auto_file_ptns = {
    "*.py",
    "*.rs",
    "*.lua",
    "*.c", "*.cpp", "*.h",
    "*.sh",
  }
})
require("users.colorscheme_switch").setup({
  transparent_enabled = true,
})
