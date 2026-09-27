-- ==========================================================================
-- File    : vimclip.lua
-- Author  : xyy15926
-- Created : 2026-09-22 13:37:29
-- Updated : 2026-09-22 13:37:29
-- Desc    : Editor context to read `"` register.
--
-- Ref:
-- - lazy/codecompanion.nvim/lua/codecompanion/interactions/inline/editor_context/clipboard.lua
-- - lazy/codecompanion.nvim/lua/codecompanion/interactions/shared/editor_context/selection.lua
-- ==========================================================================

--- @class CodeCompanion.Inline.EditorContext.VimClip: CodeCompanion.Inline.EditorContextItems
local VimClip = {}

--- @param args CodeCompanion.Inline.EditorContextArgs
function VimClip.new(args)
  return setmetatable({
    context = args.context,
  }, { __index = VimClip })
end


--- Fetch and output a buffer's contents
--- @return string|nil
function VimClip:output()
  local content = vim.fn.getreg("\"")
  if content == "" then
    content = vim.fn.getreg("+")
  end
  if content == "" then
    content = vim.fn.getreg("*")
  end

  return string.format(
    [[Sharing the contents of my clipboard:

<clipboard>%s</clipboard>]],
    content
  )
end

return VimClip
