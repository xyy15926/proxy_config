-- ============================================================
-- colorscheme.lua
-- lua/plugins/colorscheme.lua
-- 所有配色主题的插件定义，一个文件管理
-- ============================================================

return {
  -- ── 柔和暖色系 ──────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        telescope = { enabled = true },
        treesitter = true,
        native_lsp = { enabled = true },
        gitsigns = true,
        which_key = true,
        mini = { enabled = true },
      },
    },
  },

  -- ── 冷蓝色系 ────────────────────────────────────────────
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    event = "VeryLazy",
    opts = {
      style = "storm",
      transparent_background = false,
      terminal_colors = true,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
    },
  },

  -- ── 复古暖色 ────────────────────────────────────────────
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    event = "VeryLazy",
    opts = {
      contrast = "medium",
      transparent_mode = true,
    },
  },
  -- {
  --   "morhetz/gruvbox",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.gruvbox_italic = 1
  --     vim.cmd.colorscheme("gruvbox")
  --   end,
  -- },

  -- ── 浮世绘蓝紫 ──────────────────────────────────────────
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    event = "VeryLazy",
    opts = {
      compile = false,
      theme = "wave",
    },
  },

  -- ── 紫绿经典 ────────────────────────────────────────────
  {
    "dracula/vim",
    name = "dracula",
    priority = 1000,
    event = "VeryLazy",
  },

  -- ── 暗色柔和 ────────────────────────────────────────────
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    event = "VeryLazy",
    opts = {
      variant = "main",
    },
  },

  -- ── 文艺暖灰 ────────────────────────────────────────────
  {
    "savq/melange-nvim",
    name = "melange",
    priority = 1000,
    event = "VeryLazy",
  },

  -- ── 低对比护眼 ──────────────────────────────────────────
  {
    "vague2k/vague.nvim",
    name = "vague",
    priority = 1000,
    event = "VeryLazy",
  },

  -- ── Monokai 高饱和 ──────────────────────────────────────
  {
    "sainnhe/sonokai",
    priority = 1000,
    event = "VeryLazy",
    init = function()
      vim.g.sonokai_style = "default"
      vim.g.sonokai_enable_italic = true
    end,
  },

  -- ── Nightfox 系列（5 个变体）────────────────────────────
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    event = "VeryLazy",
  },
}
