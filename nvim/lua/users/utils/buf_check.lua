-- ==========================================================================
-- File    : buf_check.lua
-- Author  : xyy15926
-- Created : 2026-09-26 10:22:48
-- Updated : 2026-09-27 22:05:18
-- Desc    : Check before register autocmd to guard.
-- ==========================================================================

local M = {}


-- %% =======================================================================
--  buffer 支持性检查
-- ==========================================================================

--- @param bufnr integer 已 norm 过的 buffer 句柄
--- @return boolean
local function is_loaded(bufnr)
  return vim.api.nvim_buf_is_loaded(bufnr)
end


--- @param bufnr integer 已 norm 过的 buffer 句柄
--- @param filetypes string[] | string | nil
--- @return boolean
local function check_filetype(bufnr, filetypes)
  if type(filetypes) == "string" then
    return filetypes == vim.bo[bufnr].filetype
  elseif type(filetypes) == "table" then
    return vim.tbl_contains(filetypes, vim.bo[bufnr].filetype)
  else
    return true
  end
end


--- @param bufnr integer 已 norm 过的 buffer 句柄
--- @param file_ptns string[] | string | nil
--- @return boolean
local function check_file_ptn(bufnr, file_ptns)
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  if type(file_ptns) == "string" then
    return buf_name:match(file_ptns)
  elseif type(file_ptns) == "table" then
    local matched = false
    for _, ptn in ipairs(file_ptns) do
      if buf_name:match(ptn) then
        matched = true
        break
      end
    end
    return matched
  else
    return true
  end
end


--- @param bufnr integer 已 norm 过的 buffer 句柄
--- @param buftypes string[] | string | nil 默认只允许 `"“` 普通 buffer
--- @return boolean
local function check_buftype(bufnr, buftypes)
  buftypes = buftypes or ""
  if type(buftypes) == "string" then
    return buftypes == vim.bo[bufnr].buftype
  elseif type(buftypes) == "table" then
    return vim.tbl_contains(buftypes, vim.bo[bufnr].buftype)
  else
    return true
  end
end


--- 规范化 bufnr 参数:nil/0 -> 当前 buffer
--- @param bufnr integer|nil
--- @return integer
function M.bufnr(bufnr)
  if bufnr == nil or bufnr == 0 then return vim.api.nvim_get_current_buf()
  else return bufnr end
end


--- @class BufSupporteOption
--- @field filetypes string[] | string | nil
--- @field buftypes string[] | string | nil
--- @field file_ptns string[] | string | nil

--- 检查 buffer 是否满足所有条件
--- @param bufnr integer? buffer 句柄
--- @param opts BufSupporteOption
--- @return boolean
function M.buf_supported(bufnr, opts)
  bufnr = M.bufnr(bufnr)
  return is_loaded(bufnr)
    and check_filetype(bufnr, opts.filetypes)
    and check_buftype(bufnr, opts.buftypes)
    and check_file_ptn(bufnr, opts.file_ptns)
end


-- %% =======================================================================
--  文件、内容读取
-- ==========================================================================

--- Read the content of a file at a given path
--- @param filepath string The file to read
--- @return string
function M.read(filepath)
  local fd = assert(vim.uv.fs_open(filepath, "r", 420))
  local stat = assert(vim.uv.fs_fstat(fd))
  local data = assert(vim.uv.fs_read(fd, stat.size, 0)) or ""
  assert(vim.uv.fs_close(fd))

  return data
end


--- 获取指定文件内容字符串或 buffer 号
--- @param filepath string
--- @return integer | string
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
  -- return table.concat(vim.fn.readfile(filepath), "\n")
  return M.read(filepath)
end


--- 获取当前行或 visual 选区中多行
--- 当前非 visual 模式时，visusal 选区始终按 `v` 模式读取
--- @param keep_mode boolean?
--- @param last_visual boolean?
--- @return string[]
function M.get_content(keep_mode, last_visual)
  local content
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local sp = vim.fn.getpos("v")
    local ep = vim.fn.getpos(".")
    content = vim.fn.getregion(sp, ep, { type = mode })
    if not keep_mode then M.feedkeys("<Esc>") end
  else
    if last_visual then
      local sp = vim.fn.getpos("'<")
      local ep = vim.fn.getpos("'>")
      content = vim.fn.getregion(sp, ep, { type = "v" })
    else
      content = { vim.api.nvim_get_current_line() }
    end
  end
  return content
end


return M
