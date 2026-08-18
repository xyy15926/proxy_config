-- ============================================================
-- editing.lua
--   nvim-lint          替代 ALE lint
--   conform            替代 ALE fix
--   vim-commentary     移除（Neovim 0.10+ 内置 gc）
-- ============================================================

return {

  -- -------------------- nvim-lint（替代 ALE lint）--------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
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

  -- -------------------- conform.nvim（替代 ALE fix）--------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format", "black" },
          c      = { "clang-format" },
          cpp    = { "clang-format" },
          rust   = { "rustfmt" },
          lua    = { "stylua" },
        },
        format_on_save = false,
      })
    end,
  },

  -- -------------------- template.nvim（文件模板）--------------------
  -- {
  --   "glepnir/template.nvim",
  --   event = "BufNewFile",
  --   config = function()
  --     require("template").setup({
  --       -- 模板目录
  --       temp_dir = vim.fn.expand("~/.config/nvim/templates/"),
  --       -- 作者
  --       author = "xyy15926",
  --       -- 日期格式
  --       date_format = "%Y-%m-%d %H:%M:%S",
  --     })
  --   end,
  -- },
}
