-- ==========================================================================
-- File    : format.lua
-- Author  : xyy15926
-- Created : 2026-08-28 18:49:51
-- Updated : 2026-08-28 19:50:18
-- Desc    : Plugins for formating.
-- ==========================================================================

return {
  -- ------------------------- conform.nvim ----------------------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      { "<leader>sf", function() require("conform").format({ async = true }) end, desc = "Format" },
    },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
        c      = { "clang-format" },
        cpp    = { "clang-format" },
        rust   = { "rustfmt" },
        -- never：不使用 LSP 格式化
        -- fallback：回退使用 LSP 格式化
        -- prefer：优先使用
        lua    = { "stylua", lsp_format = "fallback" },
      },
      format_on_save = false,     -- 禁止保存时自动格式化
      -- format_on_save = {
      --   timeout_ms = 2000, 
      --   lsp_format = "fallback",
      -- },
    },
    config = function()
      -- 利用 Python 中 json 库格式化 JSON 字符串
      -- 否则用 conform 完成需要安装 prettierd，依赖太重
      vim.api.nvim_create_user_command("Jsonf", function(opts)
        local cmd = "python3 -c 'import json,sys,collections; sys.stdout.write(json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2, ensure_ascii=False))'"
        vim.cmd(opts.line1 .. "," .. opts.line2 .. " !" .. cmd)
      end, { range = true })
    end,
  },
}
