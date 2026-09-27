-- ==========================================================================
-- File    : system_prompt.lua
-- Author  : xyy15926
-- Created : 2026-09-23 11:31:04
-- Updated : 2026-09-23 11:31:04
-- Desc    : Build system prompt.
--
-- Ref:
-- - lazy/codecompanion.nvim/lua/codecompanion/prompt_library/markdown.lua
-- - lazy/codecompanion.nvim/lua/codecompanion/config.lua
-- - lazy/codecompanion.nvim/doc/configuration/system-prompt.md
-- ==========================================================================

--- @class MarkdownPrompt
--- @field context CodeCompanion.BufferContext | nil
--- @field description string
--- @field interaction string
--- @field mcp_servers string[]
--- @field name string
--- @field opts table
--- @field path string
--- @field prompts string
--- @field rules string[]
--- @field tools string[]

local M = {
  default_prompt = "你是资深开发者，善于解决编程问题。",
}
local utils = require("users.utils")


--- @param context CodeCompanion.BufferContext
--- @return string
function M.system_prompt(context)
  local filepath = vim.fn.stdpath("config") .. "/lua/plugins/codecompanion/system_prompts/basic_code.md"
  local prompt = M.load_system_prompt(filepath, context)
  if prompt == nil or prompt == "" then
    return M.default_prompt
  end
  return prompt
end


--- @param filepath string
--- @param context CodeCompanion.BufferContext
--- @return string | nil
function M.load_system_prompt(filepath, context)
  local prompt = utils.read(filepath)
  if prompt == nil then
    vim.notify(
      "Failed to load system prompt from: " .. filepath,
      vim.log.levels.WARN
    )
    return nil
  end
  prompt = prompt:match("^%-%-%-\n.-\n%-%-%-\n+(.*)")
  return utils.named_fmt(prompt, context, false)
end


return M
