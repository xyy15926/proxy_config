-- ==========================================================================
-- File    : whichkey.lua
-- Author  : xyy15926
-- Created : 2026-09-12 16:44:01
-- Updated : 2026-09-19 21:18:06
-- Desc    : WhichKey configs and some ft-related keymaps.
-- ==========================================================================


-- %% =======================================================================
--  模块真实配置
-- ==========================================================================
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
      -- %% 分组定义（目录）
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
      { "<leader>j", group = "jump", icon = " " },
      { "<leader>x", group = "build-run", icon = " " },
      { "<leader>a", group = "ai-avante", icon = " " },
      { "<leader>g", group = "git-actions", icon = " " },
      { "<leader>h", group = "lint-lsp-info",  icon = "󰴑 " },
      { "<leader>u", group = "tiny-func", icon = "󰊕 " },
      { "<leader>c", group = "content", icon = "󰆐 " },
      { "<leader>m", group = "msg-scratch", icon = "󱖩 " },
      { "<leader>d", group = "debug", icon = " " },

      -- %% 原生 Window 操作（无插件依赖，留在这里）
      -- 切换
      { "<leader>ww", "<C-w>w", desc = "other-window" },
      { "<leader>wh", "<C-w>h", desc = "window-left" },
      { "<leader>wj", "<C-w>j", desc = "window-below" },
      { "<leader>wl", "<C-w>l", desc = "window-right" },
      { "<leader>wk", "<C-w>k", desc = "window-up" },
      -- 拆分
      { "<leader>ws", "<C-w>s", desc = "split-below" },
      { "<leader>wv", "<C-w>v", desc = "split-right" },
      -- 关闭
      { "<leader>wd", "<C-w>c", desc = "close-window" },
      { "<leader>wo", "<C-w>o", desc = "close-other-window" },
      -- 移动
      { "<leader>wr", "<C-w>r", desc = "cycle-window" },
      { "<leader>wt", "<C-w>T", desc = "newtab-window" },
      -- 大小调整
      { "<leader>wH", "<C-w>5<", desc = "expand-left" },
      { "<leader>wJ", ":resize +5<cr>", desc = "expand-below" },
      { "<leader>wL", "<C-w>5>", desc = "expand-right" },
      { "<leader>wK", ":resize -5<cr>", desc = "expand-up" },
      { "<leader>w=", "<C-w>=", desc = "balance" },
      { "<leader>wm", "<C-w>m", desc = "zoom" },

      -- %% 特殊窗口导航
      { "<M-H>", "<C-w>h", desc = "window-left" },
      { "<M-L>", "<C-w>l", desc = "window-right" },
      { "<M-J>", "<C-w>j", desc = "window-down" },
      { "<M-K>", "<C-w>k", desc = "window-up" },
      { "<M-H>", "<Esc><C-w>h", mode = "i", desc = "window-left" },
      { "<M-L>", "<Esc><C-w>l", mode = "i", desc = "window-right" },
      { "<M-J>", "<Esc><C-w>j", mode = "i", desc = "window-down" },
      { "<M-K>", "<Esc><C-w>k", mode = "i", desc = "window-up" },
      -- { "<Esc>", "<C-\\><C-n>", mode = "t", desc = "to-normal" },

      -- %% 原生 Buffer 操作
      { "<leader>b1", ":b1<cr>", desc = "buffer 1" },
      { "<leader>b2", ":b2<cr>", desc = "buffer 2" },
      -- { "<leader>bd", ":bd<cr>", desc = "delete-buffer" },   -- 使用 snacks.bufdelete 替代，更安全
      { "<leader>bf", ":bfirst<cr>", desc = "first-buffer" },
      { "<leader>bl", ":blast<cr>", desc = "last-buffer" },
      { "<leader>bn", ":bnext<cr>", desc = "next-buffer" },
      { "<leader>bp", ":bprevious<cr>", desc = "previous-buffer" },
      { "<leader>bo", ":only<cr>", desc = "only" },

      -- %% 杂项（tiny-func）
      { "<leader>us", ":source $MYVIMRC<cr>", desc = "reload-config" },
      { "<leader>uq", function() vim.fn.setqflist({}) end, desc = "clean-qf" },

      -- %%jump
      { "<leader>jm", "`m", desc = "jump-mark-m" },  -- 跳转到使用 `mm` 设置的标记处，`'m` 则只跳转精确至行
      { "<leader>jq", "<cmd>cprev<cr>", desc = "qfix: prev qf" },
      { "<leader>ja", "<cmd>cnext<cr>", desc = "qfix: next qf" },
      { "<leader>jz", "<cmd>cc<cr>", desc = "qfix: current qf" },
      { "<leader>jw", "[c", desc = "vimdiff: prev diff" },
      { "<leader>js", "]c", desc = "vimdiff: next dfff" },

      -- %% fold
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

      -- %% GClip 复制、粘贴
      { "<leader>cp", "\"+p", desc = "paste from +" },
      { "<leader>co", "o<esc>\"+p", desc = "newline paste" },
      { "<leader>cyy", "\"+yy", desc = "copy curline into +" },
    },
  },
}
