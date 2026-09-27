-- ==========================================================================
-- File    : utils.lua
-- Author  : xyy15926
-- Created : 2026-08-26 15:34:07
-- Updated : 2026-09-27 22:09:30
-- Desc    : Utils for lua scripts.
-- ==========================================================================

local M = {}


-- %% =======================================================================
--  模块设置
-- ==========================================================================

local dev = require("users.utils.dev")
local usercmd = require("users.utils.usercmd")
local mrd = require("users.utils.markdown")
local file_link = require("users.utils.file_link")
local debounce = require("users.utils.debounce")
local buf_check = require("users.utils.buf_check")
local extmark = require("users.utils.extmark")


M.apply_on_0range_lines = usercmd.apply_on_0range_lines
M.apply_on_1range_lines = usercmd.apply_on_1range_lines
M.register_range_apply_command = usercmd.register_range_apply_command
M.register_select_command = usercmd.register_select_command
M.get_markdown_link = mrd.get_markdown_link_regex
M.set_gx_pattern = file_link.set_gx_pattern
M.web_url = file_link.web_url
M.file_url = file_link.file_url
M.scan_directory = file_link.scan_directory
M.scan_directories = file_link.scan_directories
P = dev.float_inspect
M.feedkeys = dev.feedkeys
M.named_fmt = dev.named_fmt
M.debounce_fn = debounce.debounce_fn
M.register_debounce_au = debounce.register_debounce_au
M.clear_debounce_au = debounce.clear_debounce_au
M.read = buf_check.read
M.read_source = buf_check.read_source
M.get_content = buf_check.get_content
M.bufnr = buf_check.bufnr
M.buf_supported = buf_check.buf_supported
M.setup_highlight = extmark.setup_highlight
M.render_hl = extmark.render_hl
M.clear_hl = extmark.clear_hl


-- %% =======================================================================
return M
