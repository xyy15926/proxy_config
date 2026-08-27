-- ============================================================
-- navigation.lua
--   which-key          替代 vim-which-key
-- ============================================================

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 2,
      align = "center",
    },
    spec = {
      -- 分组定义（目录）
      { "<leader>w", group = "windows", icon = " " },
      { "<leader>b", group = "buffer", icon = " " },

      { "<leader>n", group = "tree-content", icon = " " },
      { "<leader>s", group = "source-fix-lint", icon = " " },
      { "<leader>f", group = "find-file", icon = " " },
      { "g",         group = "navtive-goto", icon = "󰋱 " },
      { "<leader>g", group = "goto-jump", icon = "󱋿 " },
      { "<leader>m", group = "move",      icon = " " },
      { "<leader>x", group = "build-run", icon = " " },
      { "<leader>a", group = "ai-avante", icon = " " },
      { "<leader>h", group = "git-hunk",  icon = " " },
      { "<leader>u", group = "tiny-func", icon = "󰊕 " },
      { "<leader>c", group = "colorscheme", icon = " " },

      -- 原生 Window 操作（无插件依赖，留在这里）
      { "<leader>ww", "<C-w>w", desc = "other-window" },
      { "<leader>wd", "<C-w>c", desc = "delete-window" },
      { "<leader>w-", "<C-w>s", desc = "split-below" },
      { "<leader>w|", "<C-w>v", desc = "split-right" },
      { "<leader>w2", "<C-w>v", desc = "double-columns" },
      { "<leader>wh", "<C-w>h", desc = "window-left" },
      { "<leader>wj", "<C-w>j", desc = "window-below" },
      { "<leader>wl", "<C-w>l", desc = "window-right" },
      { "<leader>wk", "<C-w>k", desc = "window-up" },
      { "<leader>wH", "<C-w>5<", desc = "expand-left" },
      { "<leader>wJ", ":resize +5<cr>", desc = "expand-below" },
      { "<leader>wL", "<C-w>5>", desc = "expand-right" },
      { "<leader>wK", ":resize -5<cr>", desc = "expand-up" },
      { "<leader>w=", "<C-w>=", desc = "balance" },
      { "<leader>ws", "<C-w>s", desc = "split-below" },
      { "<leader>wv", "<C-w>v", desc = "split-right" },
      { "<leader>wm", "<C-w>m", desc = "zoom" },

      -- 原生 Buffer 操作
      { "<leader>b1", ":b1<cr>", desc = "buffer 1" },
      { "<leader>b2", ":b2<cr>", desc = "buffer 2" },
      -- { "<leader>bd", ":bd<cr>", desc = "delete-buffer" },   -- 使用 snacks.bufdelete 替代，更安全
      { "<leader>bf", ":bfirst<cr>", desc = "first-buffer" },
      { "<leader>bl", ":blast<cr>", desc = "last-buffer" },
      { "<leader>bn", ":bnext<cr>", desc = "next-buffer" },
      { "<leader>bp", ":bprevious<cr>", desc = "previous-buffer" },

      -- 杂项（tiny-func）
      { "<leader>us", ":source $MYVIMRC<cr>", desc = "reload-config" },
      { "<leader>uq", function() vim.fn.setqflist({}) end, desc = "clean-qf" },
      { "<leader>up", "\"+p", desc = "paste from +" },
      { "<leader>uo", "o<esc>\"+p", desc = "newline paate" },
      -- { "<leader>uy", "\"+y", desc = "copy into +", mode = "x" },
      { "<leader>uyy", "\"+yy", desc = "copy curline into +" },
    },
  },
}
