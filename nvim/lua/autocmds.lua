-- ============================================================
-- autocmds.lua
-- ============================================================

local au = vim.api.nvim_create_autocmd
local aug = vim.api.nvim_create_augroup

-- Terminal 打开时显示特殊字符
au("TermOpen", {
  group = aug("term_settings", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- 以目录打开时自动开启 nvim-tree
au("VimEnter", {
  group = aug("nvimtree_open_dir", { clear = true }),
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)
      require("nvim-tree.api").tree.open()
    end
  end,
})

-- nvim-tree 是唯一窗口时自动退出
au("BufEnter", {
  group = aug("nvimtree_quit", { clear = true }),
  nested = true,
  callback = function()
    local wins = vim.api.nvim_list_wins()
    if #wins == 1 and vim.bo.filetype == "NvimTree" then
      vim.cmd("quit")
    end
  end,
})
