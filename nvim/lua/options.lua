-- ==========================================================================
-- File    : options.lua
-- Author  : xyy1926
-- Created : 2026-08-28 19:35:09
-- Updated : 2026-09-19 22:39:24
-- Desc    : Options
-- ==========================================================================

-- Appearance -----------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.showcmd = true
vim.opt.wildmenu = true
vim.opt.wildmode = { "list", "longest", "full" }
vim.opt.timeout = true
vim.opt.ttimeout = true
vim.opt.timeoutlen = 300
vim.opt.display = { "truncate", "lastline", "uhex" }
vim.opt.hlsearch = true

vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.api.nvim_set_hl(0, "CursorLine",   { ctermbg = 237, bg = "#3a3a3a" })
vim.api.nvim_set_hl(0, "CursorColumn", { ctermbg = 237, bg = "#3a3a3a" })

-- 光标形状：普通=block，插入=beam，替换=underline
vim.opt.guicursor = table.concat({
  "n-v-c-sm:block",
  "i-ci-ve:ver25-blinkwait700-blinkoff400-blinkon250",
  "r-cr-o:hor20-blinkwait700-blinkoff400-blinkon250",
}, ",")

-- Fold
vim.opt.foldenable = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldcolumn = "0"

-- Tab & Indent
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
-- 针对少数语言特殊设置
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "json", "yaml", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Line display
vim.opt.breakindent = true
vim.opt.showbreak = "››››"
vim.opt.wrap = true
vim.opt.colorcolumn = "80"
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("options.softjk", { clear = true }),
  pattern = "markdown",
  callback = function(args)
    local buf = args.buf
    vim.keymap.set("n", "j", "gj", { buffer = buf })
    vim.keymap.set("n", "k", "gk", { buffer = buf })
  end,
})

-- Character display
vim.opt.list = true
vim.opt.listchars = {
  tab = "»-", precedes = "?", extends = "?",
  eol = "«", multispace = "⋅⋅⋅⋅", trail = "‹",
}

-- Scroll
vim.opt.scrolloff = 5
vim.opt.scrollbind = false

-- Status bar
vim.opt.laststatus = 2
vim.opt.completeopt = { "menu", "preview", "popup" }

-- Usage ----------------------------------------------------
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.nrformats = { "bin", "hex" }
vim.opt.mouse = "a"

-- Pattern matching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.cmd([[set matchpairs={:},(:),[:],（:）,"："]])

-- File format & encoding
vim.opt.fileformat = "unix"
vim.opt.fileformats = "unix,dos,mac"
vim.opt.fileencodings = "ucs-bom,utf-8,gbk,utf-16,latin1"
vim.opt.fileencoding = "utf-8"

vim.opt.shell = "/usr/bin/bash"

-- Backup & Recovery ----------------------------------------
vim.opt.backup = true
vim.opt.backupext = ".bak"
vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup//"

vim.opt.undofile = false  -- 禁止 undo 持久化
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo//"

vim.opt.swapfile = true
vim.opt.directory = vim.fn.stdpath("state") .. "/swap//"

vim.opt.updatetime = 50000
vim.opt.updatecount = 400

vim.opt.viewdir = vim.fn.stdpath("state") .. "/views"
vim.opt.viewoptions = { "folds", "options", "cursor", "curdir" }

vim.opt.history = 200

-- nvim 0.11+ 恢复 E325，禁止 W325 静默忽略交换文件、直接打开
vim.cmd("autocmd! nvim.swapfile")

-- Important key mappings!!!
vim.g.mapleader = ";"
vim.g.maplocalleader = ","
vim.keymap.set("",  "<Esc>", "<Esc>:silent! nohls<CR>", { silent = true })
vim.keymap.set("i", "KK", "<Esc>", { desc = "to-normal" })
vim.keymap.set("n", "K", "<Nop>", { desc = "mask-K" })
vim.keymap.set("i", "uu", "<Esc>A", { silent = true })
-- 终端模式无法通过 `<Esc>` 返回 normal 模式
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "to-normal" })
-- `q` 的宏录制容易误触，绑定给 `Q`，顺便把 `Q` 进入 Ex 模式也禁用
vim.keymap.set({ "n", "v"}, "q", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v"}, "Q", "q", { noremap = true, silent = true })
