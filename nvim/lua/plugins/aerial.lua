-- ==========================================================================
-- File    : aerial.lua
-- Author  : xyy15926
-- Created : 2026-08-30 15:20:25
-- Updated : 2026-09-27 21:06:42
-- Desc    : Aarial display the tags in from syntax parser tree constructed
--   by treesitter.
--
-- Ref:
-- - lazy/aerial.nvim/README.md
-- - lazy/aerial.nvim/lua/aerial/config.lua
-- - lazy/aerial.nvim/lua/aerial/backends/markdown.lua
-- - lazy/aerial.nvim/lua/aerial/backends/util.lua
--
-- --------------------------------------------------------------------------
-- aerial 可以配置接管 neovim 默认折叠行为
--
-- 1. 即设置 `foldmethod`, `foldexpr`，并同时调整 za, zA, zc, zC 等按键行为
-- 1.1. `foldmethod = "expr"`
-- 1.1. `foldexpr = "v:lua.aerial_foldexpr`（仅在存在存在未过滤 tag 时）
-- 1.2. za, zc, zo 等按键命令总是被修改为 `[aerial]...` 命令
--
-- 2. 但 aerial 折叠与 tag-tree 紧密相连，无法折叠未在 tag-tree 中、
--   被 `filter_kind` 过滤的节点
-- 2.1. 此时，`set foldlevel=0`、`setlocal foldlevel=0` 等均无法 “正常折叠”
-- 2.1. 不如保留 treesiter 默认 `folexpr = "v:lua.vim.treesitter.foldexpr()"
--
-- P.S.
-- - verbose set foldlevelstart? foldmethod? foldexpr? foldenable? 查看相关选项
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
      backends = {
        "heading_numbers",
        "lsp",
        "treesitter",
      },
      layout = {
        default_direction = "right",
        min_width = 25,
      },
      -- 无法折叠非 tag 节点
      manage_folds = false,
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
      -- 必须添加这个选项，否则 `aerial.backends.utils` 中会因为查不到
      -- `heading_numbers` 作为 backend 而报错
      heading_numbers = {
        update_delay = 300,
      },
    }
  },
}
