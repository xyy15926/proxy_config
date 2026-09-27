-- ==========================================================================
-- File    : extmark.lua
-- Author  : xyy15926
-- Created : 2026-09-26 14:00:14
-- Updated : 2026-09-26 14:00:14
-- Desc    : Pack extmark simplily.
-- ==========================================================================


local M = {}

--- @type table<integer, uv.uv_timer_t>
M._timers = {}  -- 按 namespace 存储 timer


-- %% =======================================================================
--  高亮组设置
-- ==========================================================================

--- @class HighlightOpts
--- @field hl_group string  -- 嵌套的 HighlightOpts 中 `hl_group` 被忽略
--- @field hl_ns string?  -- 高亮命名空间，默认使用 `hl_group`
--- @field duration integer?  -- 持续时间，缺省永久高亮
--- @field once boolean?  -- 高亮一次后清除计时器
--- @field style_opts HLStyleOpts?  -- 高亮组配置
--- @field render_opts HLRenderOpts?  -- 渲染配置
--- @field sign HighlightOpts?  -- 标记配置
--- @field virt HighlightOpts?  -- 虚拟文本配置
---
--- @class HLStyleOpts
--- @field fg string? 前景色
--- @field bg string? 背景色
--- @field sp string? 特殊标记颜色（下划线等）
--- @field bold boolean? 粗体
--- @field link string? 链接至已有高亮组
--- @field underline boolean? 下划线
--- @field italic boolean? 斜体
---
--- @class HLRenderOpts
--- @field priority integer?
--- @field text string?
--- @field pos "inline" | "eol" | "right_align" | nil -- 虚拟文本位置
--- @field hl_mode string?


--- 初始化高亮组
--- @param opts HighlightOpts
function M.setup_highlight(opts)
  local function inner_setup(hl_group, hl_opts)
    if hl_opts.link then
      vim.api.nvim_set_hl(0, hl_group, { link = hl_opts.link })
    else
      vim.api.nvim_set_hl(0, hl_group, hl_opts)
    end
  end

  -- 分别设置文本、sign、虚拟文本高亮组
  if opts.style_opts then
    inner_setup(opts.hl_group, opts.style_opts)
  end
  if opts.sign then
    -- 嵌套 `HighlightOpts.hl_group` 被忽略
    local hl_group = opts.hl_group .. ".sign"
    inner_setup(hl_group, opts.sign.style_opts)
  end
  if opts.virt then
    local hl_group = opts.hl_group .. ".virt"
    inner_setup(hl_group, opts.virt.style_opts)
  end
end


-- %% =======================================================================
--  工具函数
-- ==========================================================================

--- @param hl_type string?
--- @return string
local function norm_render_type(hl_type)
  local t = hl_type or "line"
  if t == "v" then t = "char"
  elseif t == "V" then t = "line"
  elseif t == "\22" or t == "" then t = "block"
  end
  return t
end


--- @param opts HighlightOpts
--- @return integer ns_id
local function get_ns_id(opts)
  assert(opts.hl_group, "Hightlight's group name must be provided.")
  local hl_ns = opts.hl_ns or opts.hl_group
  return vim.api.nvim_create_namespace(hl_ns)
end


-- %% =======================================================================
--  高亮闪烁（自动清除）
-- ==========================================================================

--- 创建、获取计时器
--- @param opts HighlightOpts
--- @return uv.uv_timer_t?
local function get_timer(opts)
  local ns_id = get_ns_id(opts)
  if M._timers[ns_id] then return M._timers[ns_id] end

  if opts.duration and opts.duration > 0 then
    local timer = vim.uv.new_timer()
    if timer == nil then
      error("cannot set timer for flash highlight: " .. opts.hl_group)
    end
    M._timers[ns_id] = timer
    return timer
  end
  return nil
end


--- 清除计时器
--- @param opts HighlightOpts
local function clear_timer(opts)
  local ns_id = get_ns_id(opts)
  local timer = M._timers[ns_id]
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
  M._timer[ns_id] = nil
end


--- 高亮闪烁
--- @param bufnr integer
--- @param opts HighlightOpts
local function flash_hl(bufnr, opts)
  local timer = get_timer(opts)
  if timer == nil then return end

  timer:start(opts.duration, 0, vim.schedule_wrap(function()
    if opts.once then clear_timer(opts) end
    M.clear_hl(bufnr, opts)
  end))
end


-- %% =======================================================================
--  Sign 和虚拟文本渲染
-- ==========================================================================

--- @param bufnr integer
--- @param sr integer 1-based 行号
--- @param er integer? 默认即渲染当前行
--- @param opts HighlightOpts
local function render_sign(bufnr, sr, er, opts)
  local ns_id = get_ns_id(opts)
  er = er or sr
  if opts.sign then
    local render_opts = vim.tbl_deep_extend(
      "keep", {}, opts.sign.render_opts or {}, opts.render_opts or {}
    )
    assert(render_opts.text, "Text cannot be nil for sign extmark.")
    local hl_group = opts.hl_group  .. ".sign"
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, sr, 0, {
      end_row       = er,
      sign_hl_group = hl_group,
      sign_text     = render_opts.text,
      priority      = render_opts.priority,
    })
  end
end


--- virt_text 只在 start_pos 处设置
--- @param bufnr integer
--- @param start_pos integer[] `vim.fn.getpos` 等返回的 1-based 坐标
--- @param opts HighlightOpts
local function render_virt(bufnr, start_pos, opts)
  local ns_id = get_ns_id(opts)
  if opts.virt then
    local render_opts = vim.tbl_deep_extend(
      "keep", {}, opts.virt.render_opts or {}, opts.render_opts or {}
    )
    assert(render_opts.text, "Text cannot be nil for virtual-text extmark.")
    local hl_group = opts.hl_group  .. ".virt"
    -- 将 1-based 坐标转换为 0-based 坐标
    local row, col = start_pos[2] - 1, start_pos[3] - 1
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, col, {
      virt_text     = { { render_opts.text, hl_group } },
      virt_text_pos = render_opts.pos,
      hl_mode       = render_opts.hl_mode,
      priority      = render_opts.priority,
    })
  end
end


-- %% =======================================================================
--  文本内容渲染
-- ==========================================================================

--- @param bufnr integer
--- @param start_pos integer[]
--- @param end_pos integer[]? 默认即渲染当前行
--- @param opts HighlightOpts
function M.render_line(bufnr, start_pos, end_pos, opts)
  local ns_id = get_ns_id(opts)
  end_pos = end_pos or start_pos
  -- pos 通常通过 `vim.fn.getpos` 等 api 获取 1-based、左闭右闭位置
  -- 而 `vim.api.<XXX>_extmark` 内部使用 0-based，且 `col` 列数使用左闭右开位置
  local sr = start_pos[2] - 1
  local er = end_pos[2] - 1
  if sr > er then sr, er = er, sr end

  if opts.style_opts then
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, sr, 0, {
      end_row     = er + 1,
      end_col     = 0,
      hl_group    = opts.hl_group,
      hl_eol      = true,
      priority    = opts.render_opts.priority,
    })
  end
  render_sign(bufnr, sr, er, opts)
  render_virt(bufnr, start_pos, opts)
  flash_hl(bufnr, opts)
end


--- @param bufnr integer
--- @param start_pos integer[]
--- @param end_pos integer[]
--- @param opts HighlightOpts
function M.render_block(bufnr, start_pos, end_pos, opts)
  local ns_id = get_ns_id(opts)
  -- pos 通常通过 `vim.fn.getpos` 等 api 获取 1-based 位置
  -- 而 `vim.api.<XXX>_extmark` 内部使用 0-based 位置
  local sr, sc = start_pos[2] - 1, start_pos[3] - 1
  local er, ec = end_pos[2] - 1, end_pos[3] - 1
  if sr > er then sr, er = er, sr end
  if sc > ec then sc, ec = ec, sc end

  -- `vim.api.nvim_buf_set_extmark` 设置 block 高亮只能逐行设置
  if opts.style_opts then
    for r = sr, er do
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, r, sc, {
        end_col  = ec + 1,
        hl_group = opts.hl_group,
        priority = opts.render_opts.priority,
        strict   = false,       -- block 模式下可能出现 `ec` 大于行长度，允许越界由 vim 自动截断
      })
    end
  end
  render_sign(bufnr, sr, er, opts)
  render_virt(bufnr, start_pos, opts)
  flash_hl(bufnr, opts)
end


--- @param bufnr integer
--- @param start_pos integer[]
--- @param end_pos integer[]
--- @param opts HighlightOpts
function M.render_char(bufnr, start_pos, end_pos, opts)
  local ns_id = get_ns_id(opts)
  -- pos 通常通过 `vim.fn.getpos` 等 api 获取 1-based 位置
  -- 而 `vim.api.<XXX>_extmark` 内部使用 0-based 位置
  local sr, sc = start_pos[2] - 1, start_pos[3] - 1
  local er, ec = end_pos[2] - 1, end_pos[3] - 1
  if sr > er then
      sr, er = er, sr
      sc, ec = ec, sc
  end

  if opts.style_opts then
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, sr, sc, {
      end_line = er,
      end_col  = ec + 1,
      hl_group = opts.hl_group,
      priority = opts.render_opts.priority,
    })
  end
  render_sign(bufnr, sr, er, opts)
  render_virt(bufnr, start_pos, opts)
  flash_hl(bufnr, opts)
end


-- %% =======================================================================
--  常用暴露 API
-- ==========================================================================

--- 清除渲染
--- @param bufnr integer?
--- @param opts HighlightOpts
function M.clear_hl(bufnr, opts)
  bufnr = bufnr or 0
  local ns_id = get_ns_id(opts)
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end


--- @param bufnr integer?
--- @param start_pos integer[]
--- @param end_pos integer[]? 默认即渲染当前行
--- @param opts HighlightOpts
--- @param hl_type string?
function M.render_hl(bufnr, start_pos, end_pos, opts, hl_type)
  bufnr = bufnr or 0
  end_pos = end_pos or start_pos
  hl_type = norm_render_type(hl_type)
  if hl_type == "line" then
    M.render_line(bufnr, start_pos, end_pos, opts)
  elseif hl_type == "block" then
    M.render_block(bufnr, start_pos, end_pos, opts)
  else
    M.render_char(bufnr, start_pos, end_pos, opts)
  end
end


return M
