-- ==========================================================================
-- File    : lint.lua
-- Author  : xyy15926
-- Created : 2026-08-28 18:47:00
-- Updated : 2026-08-28 19:16:50
-- Desc    : Plugins for linting.
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
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
