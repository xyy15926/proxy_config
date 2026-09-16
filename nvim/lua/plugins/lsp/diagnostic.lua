-- ==========================================================================
-- File    : diagnostic.lua
-- Author  : xyy15926
-- Created : 2026-09-15 13:40:47
-- Updated : 2026-09-15 13:40:47
-- Desc    : LSP diagnostic configs
-- ==========================================================================

return {
  -- 诊断外观
  virtual_text = { prefix = "●" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
      -- [vim.diagnostic.severity.ERROR] = "🚫",
      -- [vim.diagnostic.severity.WARN]  = "⚡",
      -- [vim.diagnostic.severity.INFO]  = "ℹ",
      -- [vim.diagnostic.severity.HINT]  = "💡",
    },
  },
  float = {
    border = "rounded",
    source = "if_many",
    -- 可通过 `=vim.diagnostic.get(0, lnum={vim.fn.line(".") - 1})` 查看
    -- 当前行 diagnostic 表信息，即以下函数参数
    format = function(diagnostic)
      return string.format("[%s] %s",
        diagnostic.source or "?",
        diagnostic.message
      )
    end,
  },
  update_in_insert = false,
}
