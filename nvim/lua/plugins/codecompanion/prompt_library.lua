-- ==========================================================================
-- File    : prompt_library.lua
-- Author  : xyy15926
-- Created : 2026-09-01 21:55:38
-- Updated : 2026-09-21 21:50:04
-- Desc    : Prompts.
--
-- Ref:
-- - lazy/codecompanion.nvim/doc/configuration/prompt-library.md
-- - lazy/codecompanion.nvim/doc/usage/prompt-library.md
-- - lazy/codecompanion.nvim/lua/codecompanion/prompt_library/builtins/explain.md
-- - lazy/codecompanion.nvim/lua/codecompanion/prompt_library/builtins/lsp.lua
--
-- --------------------------------------------------------------------------
-- prompt-library 与 system-prompt 是不同的定位、配置
-- - system-prompt 是独立的 prompt，针对 chat, tool 的配置，更像是规范
-- - prompt-library 是不同用途的 prompt 集合
--
-- ==========================================================================

return {
  markdown = {
    dirs = {
      vim.fn.stdpath("config") .. "/lua/plugins/codecompanion/prompt_library",
      vim.fn.getcwd() .. "/prompts",
    },
  },
}
