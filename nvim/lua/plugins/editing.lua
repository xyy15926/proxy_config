-- ============================================================
-- editing.lua
--   nvim-lint          替代 ALE lint
--   conform            替代 ALE fix
--   table-mode         保留
--   vim-commentary     移除（Neovim 0.10+ 内置 gc）
--   markview.nvim      MD 渲染插件
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

  -- -------------------- table-mode（保留）--------------------
  { "dhruvasagar/vim-table-mode", ft = { "markdown", "python" },
    config = function()
      vim.g.table_mode_auto_align = 1
      vim.g.table_mode_update_time = 100
      vim.g.table_mode_disable_mappings = 1
      vim.g.table_mode_disable_tableize_mappings = 1
    end },


  -- -------------------- markview.nvim（MD 渲染插件）--------------------
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("markview").setup({
        -- 在编辑器里直接渲染 Markdown（标题、代码块、表格等）
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
