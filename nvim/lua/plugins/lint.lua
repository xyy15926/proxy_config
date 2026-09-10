-- ==========================================================================
-- File    : lint.lua
-- Author  : xyy15926
-- Created : 2026-08-28 18:47:00
-- Updated : 2026-09-10 16:22:15
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
    -- nvim-lint 没有形如 `init.lua` 的主模块，仅有 `lua/lint.lua` 模块
    -- 且 `lint.lua` 中没有 `setup()` 函数，不支持 lazy.vim 的常规初始化
    -- Ref:
    -- - lazy/nvim-lint/lua/lint.lua
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        -- python = { "ruff", "mypy" },
        python = { "ruff" },
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
        group = vim.api.nvim_create_augroup("nvim-lint.lint_bofore_write", { clear = true }),
        callback = function() lint.try_lint() end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim-lint.pylint_env", { clear = true }),
        pattern = "python",
        callback = function()
          -- Ref:
          -- - lazy/nvim-lint/lua/lint/linters/mypy.lua
          -- - lazy/nvim-lint/lua/lint/linters/ruff.lua
          -- 此处不能使用 `pixify` 通过 `pixi run` 运行，会检查 cmd 整体是否存在
          lint.linters.mypy.cmd = require("users.pyenv").venv_cmd("mypy")
          lint.linters.ruff.cmd = require("users.pyenv").venv_cmd("ruff")
        end,
      })
    end,
  },
}
