-- ==========================================================================
-- File    : utils.lua
-- Author  : xyy15926
-- Created : 2026-09-21 15:48:59
-- Updated : 2026-09-21 15:48:59
-- Desc    : Utils for prompts.
--
-- Ref
-- - lazy/codecompanion.nvim/doc/configuration/prompt-library.md
-- ==========================================================================

--- @class PromptArgs
--- @field context PromptContext
--- @field item PromptItem
---
--- @class PromptContext
--- @field bufnr integer
--- @field buftype string
--- @field filetype string
--- @field winnr integer
--- @field cursor_pos integer[2]
--- @field start_col integer
--- @field start_line integer
--- @field end_col integer
--- @field end_line integer
--- @field is_normal boolean
--- @field is_visual boolean
--- @field mode "V"|"v"|"\22" `vim.fn.mode()`
--- @field code string
--- @field lines string[]
---
--- @class PromptItem

local M = {}


--- Get and return staged changes
--- @params args PromptArgs
function M.git_diff(args)
  return vim.system(
    { "git", "diff", "--no-ext-diff", "--staged" }
    , { text = true }
  ):wait().stdout
end


--- Get and return LSP diagnostics
--- @params args PromptArgs
function M.diagnostics(args)
  local diagnostics = require("codecompanion.helpers.code").get_diagnostics(
    args.context.start_line,
    args.context.end_line,
    args.context.bufnr
  )

  local concatenated_diagnostics = ""
  for i, diagnostic in ipairs(diagnostics) do
    concatenated_diagnostics = concatenated_diagnostics
      .. i
      .. ". Issue "
      .. i
      .. "\n  - Location: Line "
      .. diagnostic.line_number
      .. "\n  - Buffer: "
      .. args.context.bufnr
      .. "\n  - Severity: "
      .. diagnostic.severity
      .. "\n  - Message: "
      .. diagnostic.message
      .. "\n"
  end

  return concatenated_diagnostics
end


return M
