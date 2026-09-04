-- ==========================================================================
-- File    : lint.lua
-- Author  : xyy15926
-- Created : 2026-08-28 18:47:00
-- Updated : 2026-08-31 09:28:24
-- Desc    : Plugins for linting.
--
-- Linters:
-- pip install ruff
-- npm install -g eslint_d
-- luarocks install luacheck
-- sudo apt install shellcheck
-- npm install -g markdownlint-cli
-- pip install yamllint
-- brew install hadolint
-- go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
-- ==========================================================================

return {
  -- -------------------------- nvim-lint ------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    keys = {
      { "<leader>hj", function() require("lint").try_lint() end, desc = "Lint" },
    },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff", "mypy" },
        c      = { "clang" },
        cpp    = { "clang" },
        rust   = { "cargo" },
        -- lua = { "luacheck" },
        -- javascript = { "eslint_d" },
        -- typescript = { "eslint_d" },
        -- sh = { "shellcheck" },
        -- markdown = { "markdownlint" },
        -- yaml = { "yamllint" },
        -- go = { "golangcilint" },
        -- docerfile = { "hadolint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
