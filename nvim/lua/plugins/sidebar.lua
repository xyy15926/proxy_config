-- ==========================================================================
-- File    : sidebar.lua
-- Author  : xyy15926
-- Created : 2026-08-30 15:20:25
-- Updated : 2026-09-08 11:25:17
-- Desc    : Plugins related to sidebars.
-- ==========================================================================

return {
  -- -------------------- aerial（替代 tagbar）--------------------
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "AerialToggle" },
    keys = {
      { "<leader>nt", "<cmd>AerialToggle<CR>", desc = "Toggle Tag List" },
    },
    opts = {
      -- LSP 返回更细粒度符号，忽略
      backends = { "lsp", "treesitter" },
      layout = {
        default_direction = "right",
        min_width = 25,
      },
      -- 接管 neovim 默认折叠行为
      manage_folds = true,
      -- buffer 折叠、符号树折叠相互影响
      link_folds_to_tree = true,
      link_tree_to_folds = true,
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Struct",
      },
    }
  },

  -- -------------------- mundo --------------------
  { "simnalamburt/vim-mundo",
    cmd = "MundoToggle",
    keys = {
      { "<leader>nh", "<cmd>MundoToggle<CR>", desc = "Toggle Undo Tree" },
    },
    config = function()
      vim.g.mundo_width = 30
      vim.g.mundo_preview_height = 15
      vim.g.mundo_right = 1
      vim.g.mundo_auto_preview = 1
      vim.g.mundo_auto_preview_delay = 1000
      vim.g.mundo_verbose_graph = 0
      vim.g.mundo_close_on_revert = 1
      vim.g.mundo_return_on_revert = 1
    end
  },
}
