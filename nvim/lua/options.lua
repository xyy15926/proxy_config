-- ============================================================
-- options.lua
-- ============================================================

-- Appearance -----------------------------------------------
vim.opt.number = true
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

-- Line display
vim.opt.breakindent = true
vim.opt.showbreak = "››››"
vim.opt.wrap = true
vim.opt.colorcolumn = "80"

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

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo//"

vim.opt.swapfile = true
vim.opt.directory = vim.fn.stdpath("state") .. "/swap//"

vim.opt.updatetime = 50000
vim.opt.updatecount = 400

vim.opt.viewdir = vim.fn.stdpath("state") .. "/views"
vim.opt.viewoptions = { "folds", "options", "cursor", "curdir" }

vim.opt.history = 200

-- Yank & Paste with win32 ----------------------------------
-- Ref:
-- - https://github.com/equalsraf/win32yank/releases/
-- 1. 需要 win32yank.exe 位于 `PATH` 可被找到
-- 2. WSL 可与 Win 正常通信
vim.g.clipboard = {
  name = 'win32yank',
  copy = {
    ['+'] = 'win32yank.exe -i --crlf',
    ['*'] = 'win32yank.exe -i --crlf',
  },
  paste = {
    ['+'] = 'win32yank.exe -o --lf',
    ['*'] = 'win32yank.exe -o --lf',
  },
  cache_enabled = 0,
}
