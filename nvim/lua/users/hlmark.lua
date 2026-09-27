-- ==========================================================================
-- File    : hlmark.lua
-- Author  : xyy15926
-- Created : 2026-09-26 20:05:41
-- Updated : 2026-09-26 20:05:41
-- Desc    : Predefined highlight or extmark just to pack `extmark.render_hl`
--   for convenience.
-- ==========================================================================

local utils = require("users.utils")
local M = {}

M.defaults = {
  flash_opts = {
    hl_group      = "users.flashhl",
    hl_ns         = "users.flashhl",
    duration      = 150,  -- 高亮持续时间(ms)，0 表示不自动清除
    once          = false,
    style_opts    = {
      fg          = "#1A1A1A",  -- 前景色
      bg          = "#745015",  -- 背景色
      bold        = true,
    },
    render_opts = {
      priority    = 200,
    },
    sign = {
      style_opts   = {
        fg        = "#98C379",
      },
      render_opts = {
        priority  = 10,
        text      = "▶",
      },
    },
  },
  mark_opts = {
    hl_group      = "users.mark",
    hl_ns         = "users.mark",
    duration      = nil,
    style_opts    = {
      sp          = "#E8A043",
      underline   = true,
    },
    render_opts   = {
      priority    = 50,
    },
  },
  virt_opts = {
    hl_group      = "users.virt_text",
    hl_ns         = "users.virt_text",
    duration      = nil,
    once          = false,
    virt = {
      style_opts  = {
        fg        = "#E06C75",
        bold      = true,
        underline = true,
      },
      render_opts = {
        priority  = 100,
        text      = "▶",
        pos       = "inline",
      },
    },
  },
}
M.opts = vim.deepcopy(M.defaults)


function M.setup_predef_hls()
  -- 初始化预定义高亮组
  for _, hl_opts in pairs(M.opts) do
    utils.setup_highlight(hl_opts)
  end
end


-- %% =======================================================================
--  闪烁高亮
-- ==========================================================================

--- 指定范围闪烁高亮
--- @param bufnr integer
--- @param start_pos integer[]
--- @param end_pos integer[]? 默认即渲染当前行
--- @param hl_type string? 高亮类型
function M.flash_hl(bufnr, start_pos, end_pos, hl_type)
  local opts = M.opts.flash_opts
  utils.render_hl(bufnr, start_pos, end_pos, opts, hl_type)
end


--- 指定行闪烁高亮
--- @param bufnr integer
--- @param line_no integer
function M.flash_line(bufnr, line_no)
  local opts = M.opts.flash_opts
  local start_pos = { 0, line_no, 0, 0 }
  utils.render_hl(bufnr, start_pos, nil, opts, "line")
end


--- 指定行闪烁高亮
--- @param bufnr integer
--- @param line_nos integer[]
function M.flash_lines(bufnr, line_nos)
  local opts = M.opts.flash_opts
  for _, lno in ipairs(line_nos) do
    local start_pos = { 0, lno, 0, 0 }
    utils.render_hl(bufnr, start_pos, nil, opts, "line")
  end
end


--- 清除闪烁高亮
--- @param bufnr integer
function M.clear_flash(bufnr)
  local opts = M.opts.flash_opt
  utils.clear_hl(bufnr, opts)
end


-- %% =======================================================================
--  常驻行标记
-- ==========================================================================

--- 指定范围闪烁高亮
--- @param bufnr integer
--- @param start_pos integer[]
--- @param end_pos integer[]? 默认即渲染当前行
--- @param hl_type string? 高亮类型
function M.mark_hl(bufnr, start_pos, end_pos, hl_type)
  local opts = M.opts.mark_opts
  utils.render_hl(bufnr, start_pos, end_pos, opts, hl_type)
end


--- 常驻行标记
--- @param bufnr integer
--- @param line_no integer
function M.mark_line(bufnr, line_no)
  local opts = M.opts.mark_opts
  local start_pos = { 0, line_no, 0, 0 }
  utils.render_hl(bufnr, start_pos, nil, opts, "line")
end


--- 常驻行标记
--- @param bufnr integer
--- @param line_nos integer[]
function M.mark_lines(bufnr, line_nos)
  local opts = M.opts.mark_opts
  for _, lno in ipairs(line_nos) do
    local start_pos = { 0, lno, 0, 0 }
    utils.render_hl(bufnr, start_pos, nil, opts, "line")
  end
end


--- 清除行标记
--- @param bufnr integer
function M.clear_mark(bufnr)
  local opts = M.opts.mark_opts
  utils.clear_hl(bufnr, opts)
end


-- %% =======================================================================
--  常驻虚拟文本
-- ==========================================================================

--- @class LineOpts
--- @field pos integer[]
--- @field text string
---
--- 常驻行标记
--- @param bufnr integer
--- @param line_opt LineOpts
function M.virt_line(bufnr, line_opt)
  local virt_opts = vim.deepcopy(M.opts.virt_opts)
  virt_opts.virt.render_opts.text = line_opt.text
  utils.render_hl(bufnr, line_opt.pos, nil, virt_opts)
end


--- 常驻行标记
--- @param bufnr integer
--- @param lines_opt LineOpts[]
function M.virt_lines(bufnr, lines_opt)
  local virt_opts = vim.deepcopy(M.opts.virt_opts)
  for _, lopt in ipairs(lines_opt) do
    virt_opts.virt.render_opts.text = lopt.text
    utils.render_hl(bufnr, lopt.pos, nil, virt_opts)
  end
end


--- 清除行标记
--- @param bufnr integer
function M.clear_virt(bufnr)
  local opts = M.opts.virt_opts
  utils.clear_hl(bufnr, opts)
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  M.setup_predef_hls()
end


return M
