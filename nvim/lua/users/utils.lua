-- ==========================================================================
-- File    : utils.lua
-- Author  : xyy15926
-- Created : 2026-08-26 15:34:07
-- Updated : 2026-09-17 09:51:55
-- Desc    : Utils for lua scripts.
-- ==========================================================================

local M = {}


-- %% =======================================================================
--  模块设置
-- ==========================================================================
require("users.utils.dev").setup()
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


-- %% =======================================================================
--  Buffer 读取、定位
-- ==========================================================================
--- 获取指定文件内容字符串或 buffer 号
--- @param filepath string
function M.read_source(filepath)
  -- 当前 buffer，优先级最高，直接返回 buffer number
  if vim.fn.expand("%:p") == vim.fn.fnamemodify(filepath, ":p") then
    return 0
  end
  -- 文件在其他窗口/标签页的 buffer 里，也返回 buffer number
  local buf = vim.fn.bufnr(filepath)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    return buf
  end
  -- 否则，从磁盘读取，返回文件内容字符串
  return table.concat(vim.fn.readfile(filepath), "\n")
end


-- %% =======================================================================
return M
