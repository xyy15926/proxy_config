-- ==========================================================================
-- File    : utils.lua
-- Author  : xyy15926
-- Created : 2026-08-26 15:34:07
-- Updated : 2026-08-28 17:21:33
-- Desc    : Utils for lua scripts.
-- ==========================================================================

local usercmd = require("users.utils.usercmd").setup()
local flashhl = require("users.utils.flashhl").setup()

return {
  apply_on_0range_lines = usercmd.apply_on_0range_lines,
  apply_on_1range_lines = usercmd.apply_on_1range_lines,
  register_range_apply_command = usercmd.register_range_apply_command,
  flash = flashhl.flash,
  clear_flash = flashhl.clear_flash,
  flash_line = flashhl.flash_line,
  flash_from_marks = flashhl.flash_from_marks,
}
