-- ============================================================
-- init.lua
-- ============================================================

vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("_utils").setup({
  todo_base = vim.fn.expand("~/files.md/gtd"),
})
require("options")
require("keymaps")
require("autocmds")
require("globals")
require("users.markdown_todo")
require("users.heading_file")
require("users.yank2gclip").setup({
  -- win32yank = "/mnt/d/win32/win32yank.exe",
  win32yank = nil,
})
require("users.daily_todo").setup({
  todo_base = vim.fn.expand("~/files.md/gtd"),
})

-- 此处设置 `plugins` 将扫描、导入 `plugins/*.lua` 模块
-- 即，`plugins/init.lua` 中无需 `import` lua 文件模块，仅需 `import` 文件夹
require("lazy").setup("plugins", {
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "catppuccin-mocha" } },    -- 仅用于制定首次安装插件时的配色
  checker = { enabled = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

require("users.colorscheme_switch").setup({
  transparent_enabled = true,
})
