-- ============================================================
-- sidebar.lua — 侧边导航栏
--   nvim-tree      替代 nerdtree
--   aerial         替代 tagbar
--   mundo          编辑历史，保留
--   zoom           瞬时放大窗口，保留
-- ============================================================

return {

  -- -------------------- nvim-tree（替代 nerdtree）--------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeClose" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 25 },
        filters = {
          custom = { "__pycache__", "%.pyc$", ".egg-info" },
        },
        update_focused_file = { enable = true },
      })
    end,
  },

  -- -------------------- aerial（替代 tagbar）--------------------
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "AerialToggle" },
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter" },
        layout = {
          default_direction = "right",
          min_width = 25,
        },
        filter_kind = false,  -- 显示所有符号类型（对应 tagbar_sort=1, foldlevel=2）
      })
    end,
  },

  -- -------------------- mundo --------------------
  { "simnalamburt/vim-mundo", cmd = "MundoToggle",
    config = function()
      vim.g.mundo_width = 30
      vim.g.mundo_preview_height = 15
      vim.g.mundo_right = 1
      vim.g.mundo_auto_preview = 1
      vim.g.mundo_auto_preview_delay = 1000
      vim.g.mundo_verbose_graph = 0
      vim.g.mundo_close_on_revert = 1
      vim.g.mundo_return_on_revert = 1
    end },

  -- -------------------- zoom --------------------
  { "dhruvasagar/vim-zoom" },
}
