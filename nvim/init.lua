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

require("options")
require("keymaps")
require("autocmds")
require("globals")

require("lazy").setup("plugins", {
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "gruvbox" } },    -- 仅用于制定首次安装插件时的配色
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

require("colorscheme_options")
vim.g.transparent_enabled = true
