-- ==========================================================================
-- File    : utils.lua
-- Author  : xyy15926
-- Created : 2026-08-26 15:34:07
-- Updated : 2026-09-08 18:58:18
-- Desc    : Utils for lua scripts.
-- ==========================================================================

require("users.utils.dev").setup()
local usercmd = require("users.utils.usercmd").setup()
local flashhl = require("users.utils.flashhl").setup()
local mrd = require("users.utils.markdown").setup()

return {
  apply_on_0range_lines = usercmd.apply_on_0range_lines,
  apply_on_1range_lines = usercmd.apply_on_1range_lines,
  register_range_apply_command = usercmd.register_range_apply_command,
  flash = flashhl.flash,
  clear_flash = flashhl.clear_flash,
  flash_line = flashhl.flash_line,
  flash_from_marks = flashhl.flash_from_marks,
  get_markdown_link = mrd.get_markdown_link_regex,
}
