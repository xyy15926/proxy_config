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
      { "<leader>ww", "<C-W>w", desc = "other-window" },
      { "<leader>wd", "<C-W>c", desc = "delete-window" },
      { "<leader>w-", "<C-W>s", desc = "split-below" },
      { "<leader>w|", "<C-W>v", desc = "split-right" },
      { "<leader>w2", "<C-W>v", desc = "double-columns" },
      { "<leader>wh", "<C-W>h", desc = "window-left" },
      { "<leader>wj", "<C-W>j", desc = "window-below" },
      { "<leader>wl", "<C-W>l", desc = "window-right" },
      { "<leader>wk", "<C-W>k", desc = "window-up" },
      { "<leader>wH", "<C-W>5<", desc = "expand-left" },
      { "<leader>wJ", ":resize +5", desc = "expand-below" },
      { "<leader>wL", "<C-W>5>", desc = "expand-right" },
      { "<leader>wK", ":resize -5", desc = "expand-up" },
      { "<leader>w=", "<C-W>=", desc = "balance" },
      { "<leader>ws", "<C-W>s", desc = "split-below" },
      { "<leader>wv", "<C-W>v", desc = "split-right" },
      { "<leader>wm", "<C-W>m", desc = "zoom" },

      -- 原生 Buffer 操作
      { "<leader>b1", ":b1", desc = "buffer 1" },
      { "<leader>b2", ":b2", desc = "buffer 2" },
      -- { "<leader>bd", ":bd", desc = "delete-buffer" },   -- 使用 snacks.bufdelete 替代，更安全
      { "<leader>bf", ":bfirst", desc = "first-buffer" },
      { "<leader>bl", ":blast", desc = "last-buffer" },
      { "<leader>bn", ":bnext", desc = "next-buffer" },
      { "<leader>bp", ":bprevious", desc = "previous-buffer" },

      -- 杂项（tiny-func）
      { "<leader>ur", "<cmd>Markview toggle<cr>", desc = "toggle render" },
      { "<leader>ut", "<cmd>Tableize<cr>", desc = "tableize", mode = "x" },
      { "<leader>ut", "<cmd>TableModeToggle<cr>", desc = "toggle table-mode" },
      { "<leader>us", ":source $MYVIMRC<cr>", desc = "reload-config" },
      { "<leader>uq", function() vim.fn.setqflist({}) end, desc = "clean-qf" },
      { "<leader>up", "\"+p", desc = "paste from +" },
      { "<leader>uo", "o<esc>\"+p", desc = "newline paate" },
      -- { "<leader>uy", "\"+y", desc = "copy into +", mode = "x" },
      -- { "<leader>uy", require("_utils").yank_without_indent, desc = "copy into +", mode = "x" },
      { "<leader>uyy", "\"+yy", desc = "copy curline into +" },
    },
  },
}
