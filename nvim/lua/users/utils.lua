-- ==========================================================================
-- File    : utils.lua
-- Author  : xyy15926
-- Created : 2026-08-26 15:34:07
-- Updated : 2026-09-18 14:38:49
-- Desc    : Utils for lua scripts.
-- ==========================================================================

local M = {}


-- %% =======================================================================
--  模块设置
-- ==========================================================================
local dev = require("users.utils.dev").setup()
local usercmd = require("users.utils.usercmd").setup()
local flashhl = require("users.utils.flashhl").setup()
local mrd = require("users.utils.markdown").setup()
local file_link = require("users.utils.file_link").setup()


M.apply_on_0range_lines = usercmd.apply_on_0range_lines
M.apply_on_1range_lines = usercmd.apply_on_1range_lines
M.register_range_apply_command = usercmd.register_range_apply_command
M.flash = flashhl.flash
M.clear_flash = flashhl.clear_flash
M.flash_line = flashhl.flash_line
M.flash_from_marks = flashhl.flash_from_marks
M.get_markdown_link = mrd.get_markdown_link_regex
M.set_gx_pattern = file_link.set_gx_pattern
M.web_url = file_link.web_url
M.file_url = file_link.file_url
M.scan_directory = file_link.scan_directory
M.scan_directories = file_link.scan_directories
P = dev.float_inspect
M.read_source = dev.read_source
M.feedkeys = dev.feedkeys
M.get_content = dev.get_content


-- %% =======================================================================
return M
