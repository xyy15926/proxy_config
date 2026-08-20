-- ============================================================
-- mason.lua
--   mason                  工具安装、管理
--   mason-lspconfig        各语言 LSP 安装、配置
--   mason-tool-installer   Linter, Formatter 安装、配置
-- ============================================================

return {

  -- -------------------- Mason（自动安装 LSP/DAP/Linter）--------------------
  -- 1. Mason 独立安装 LSP、Linter、Formater，即使系统已存在也将安装新副本至
  --   `datapath/mason/bin/` 目录下（目录被添加至 `PATH`）。
  -- 2. 其他 `nvim-lint`、`conform` 等工具仅通过 `PATH` 查找工具使用。
  -- 3. 即，`rust-analyzer`、`cargo` 等 LSP、Linter 总是随着 Rust 工具链自动
  --   安装的工具不要通过 Mason 管理。
  -- 4. 下述 `mason-tool-installer` 未启用，即需自行安装 ruff、mypy 等工具
  -- ------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      automatic_enable = true,          -- 自动调用 `vim.lsp.enable()`
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "basedpyright",
          -- "clangd",
          "rust_analyzer",
        },
        automatic_installation = true,
      })
    end,
  },
  -- {
  --   "WhoIsSethDaniel/mason-tool-installer.nvim",
  --   dependencies = { "williamboman/mason.nvim" },
  --   config = function()
  --     require("mason-tool-installer").setup({
  --       ensure_installed = {
  --         -- Linter
  --         "ruff",
  --         "mypy",
  --         -- Formatter
  --         "stylua",
  --       },
  --     })
  --   end,
  -- },
}
