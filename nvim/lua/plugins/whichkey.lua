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
    -- 若按键本身为内置命令，需要手动添加作为触发器才会按下后有提示
    triggers = {
      { "<auto>", mode = "nixsotc" },  -- `<auto>`：自动监测已有注册的子映射，弹出提示框
      { "m", mode = "n" },  -- `m` 按键被 vim 内置命令抢占，需要手动声明
    },
    spec = {
      { "<leader><leader>", "<cmd>WhichKey<cr>", desc = "which-key", icon = "? " },
      -- 分组定义（目录）
      { "<leader>w", group = "windows", icon = " " },
      { "<leader>b", group = "buffer", icon = " " },
      { "z",         group = "fold", icon = "z " },

      { "<leader>n", group = "sidebar", icon = " " },
      { "<leader>s", group = "format", icon = "󱇂 " },
      { "<leader>r", group = "run-unit", icon = " " },
      { "<leader>f", group = "file-picker", icon = " " },
      { "<leader>l", group = "other-picker", icon = " " },
      { "g",         group = "native-goto", icon = "󰋱 " },
      { "<leader>q", group = "outvim-actions", icon = "󱋿 " },
      { "<leader>m", group = "jump-move",      icon = " " },
      { "<leader>x", group = "build-run", icon = " " },
      { "<leader>a", group = "ai-avante", icon = " " },
      { "<leader>g", group = "git-actions", icon = " " },
      { "<leader>h", group = "lint-hint",  icon = "󰴑 " },
      { "<leader>u", group = "tiny-func", icon = "󰊕 " },
      { "<leader>c", group = "content", icon = "󰆐 " },

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
      { "<leader>wq", "<cmd>cclose<cr>", desc = "qfix-close" },

      -- 特殊窗口导航
      { "<M-H>", "<C-w>h", desc = "window-left" },
      { "<M-L>", "<C-w>l", desc = "window-right" },
      { "<M-J>", "<C-w>j", desc = "window-down" },
      { "<M-K>", "<C-w>k", desc = "window-up" },
      { "<M-H>", "<Esc><C-w>h", mode = "i", desc = "window-left" },
      { "<M-L>", "<Esc><C-w>l", mode = "i", desc = "window-right" },
      { "<M-J>", "<Esc><C-w>j", mode = "i", desc = "window-down" },
      { "<M-K>", "<Esc><C-w>k", mode = "i", desc = "window-up" },
      -- { "<Esc>", "<C-\\><C-n>", mode = "t", desc = "to-normal" },

      -- 原生 Buffer 操作
      { "<leader>b1", ":b1<cr>", desc = "buffer 1" },
      { "<leader>b2", ":b2<cr>", desc = "buffer 2" },
      -- { "<leader>bd", ":bd<cr>", desc = "delete-buffer" },   -- 使用 snacks.bufdelete 替代，更安全
      { "<leader>bf", ":bfirst<cr>", desc = "first-buffer" },
      { "<leader>bl", ":blast<cr>", desc = "last-buffer" },
      { "<leader>bn", ":bnext<cr>", desc = "next-buffer" },
      { "<leader>bp", ":bprevious<cr>", desc = "previous-buffer" },
      { "<leader>bo", ":only<cr>", desc = "only" },

      -- 杂项（tiny-func）
      { "<leader>us", ":source $MYVIMRC<cr>", desc = "reload-config" },
      { "<leader>uq", function() vim.fn.setqflist({}) end, desc = "clean-qf" },
      { "<leader>mq", "<cmd>cprev<cr>", desc = "qfix-prev" },  -- Quickfix 跳转
      { "<leader>mz", "<cmd>cnext<cr>", desc = "qfix-next" },
      { "<leader>mm", "`m", desc = "jump-mark-m" },  -- 跳转到使用 `mm` 设置的标记处，`'m` 则只跳转精确至行
      { "<leader>mc", "]c", desc = "diff-next" },
      { "<leader>me", "[c", desc = "diff-prev" },

      -- fold
      { "z1", ":set foldlevel=1<cr>", desc = "fold-1" },
      { "z2", ":set foldlevel=2<cr>", desc = "fold-2" },
      { "z3", ":set foldlevel=3<cr>", desc = "fold-3" },
      { "z4", ":set foldlevel=4<cr>", desc = "fold-4" },
      { "z5", ":set foldlevel=5<cr>", desc = "fold-5" },
      { "z6", ":set foldlevel=6<cr>", desc = "fold-6" },
      { "z7", ":set foldlevel=7<cr>", desc = "fold-7" },
      { "z8", ":set foldlevel=8<cr>", desc = "fold-8" },
      { "z0", ":set foldlevel=0<cr>", desc = "fold-0" },
      { "z-", ":set foldlevel=999<cr>", desc = "unfold" },

      -- GClip 复制、粘贴
      { "<leader>cp", "\"+p", desc = "paste from +" },
      { "<leader>co", "o<esc>\"+p", desc = "newline paste" },
      { "<leader>cyy", "\"+yy", desc = "copy curline into +" },
    },
  },
}
