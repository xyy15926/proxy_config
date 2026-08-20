-- ============================================================
-- keymaps.lua
-- ============================================================

vim.keymap.set("",  "<Esc>", "<Esc>:silent! nohls<CR>", { silent = true })
vim.keymap.set("i", "KK", "<Esc>")
vim.keymap.set("n", "K", "<Nop>")

vim.cmd([[iabbrev xtime <C-r>=strftime("%Y-%m-%d %H:%M:%S")<CR>]])

-- 窗口导航 Alt+HJKL
vim.keymap.set("",  "<M-H>", "<C-w>h")
vim.keymap.set("",  "<M-L>", "<C-w>l")
vim.keymap.set("",  "<M-J>", "<C-w>j")
vim.keymap.set("",  "<M-K>", "<C-w>k")
vim.keymap.set("i", "<M-H>", "<Esc><C-w>h")
vim.keymap.set("i", "<M-L>", "<Esc><C-w>l")
vim.keymap.set("i", "<M-J>", "<Esc><C-w>j")
vim.keymap.set("i", "<M-K>", "<Esc><C-w>k")

-- Terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

