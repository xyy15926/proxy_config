-- ==========================================================================
-- File    : aerial.lua
-- Author  : xyy15926
-- Created : 2026-08-30 15:20:25
-- Updated : 2026-09-19 22:02:53
-- Desc    : Aarial display the tags in from syntax parser tree constructed
--   by treesitter.
-- ==========================================================================

return {
  -- -------------------- aerial -------------------------------------------
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = true,
    enabled = true,
    cmd = { "AerialToggle" },
    keys = {
      -- `snacks.picker.treesitter()` 也可以列出、预览 tags
      { "<leader>nt", "<cmd>AerialToggle<CR>", desc = "Tags: Sidebar" },
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
        "Field",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        "Struct",
        "Trait",
      },
    }
  },
}
