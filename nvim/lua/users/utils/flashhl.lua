-- ==========================================================================
-- File    : flashhl.lua
-- Author  : xyy15926
-- Created : 2026-08-28 14:43:58
-- Updated : 2026-08-30 19:58:59
-- Desc    : Flash highlight helper.
-- ==========================================================================

local M = {}

-- 默认配置
M.defaults = {
  duration    = 150,  -- 高亮持续时间(ms)，0 表示不自动清除
  hl_group    = "FlashHL",
  priority    = 200,
  hl_opts = {
    fg        = "#1A1A1A",  -- 前景色
    bg        = "#745015",  -- 背景色
    bold      = true,
    -- link = "IncSearch"      -- 直接链接到现有高亮组
  },
  sign = {
    text      = "▶",
    priority  = 10,
    hl_group  = "FlashHLSign",
    hl_opts   = {
      fg      = "#98C379",  -- 背景色
    }
  },
}
M.opts = vim.deepcopy(M.defaults)

-- 统一命名空间
local ns_id = vim.api.nvim_create_namespace("flash_highlight")
local active_timer = nil

-- 初始化高亮组
function M.setup_highlight()
  local function inner_setup(hl_group, hl_opts)
    if hl_opts.link then
      vim.api.nvim_set_hl(0, hl_group, { link = hl_opts.link })
    else
      vim.api.nvim_set_hl(0, hl_group, hl_opts)
    end
  end

  inner_setup(M.opts.hl_group, M.opts.hl_opts)
  if M.opts.sign then
    inner_setup(M.opts.sign.hl_group, M.opts.sign.hl_opts)
  end
end


-- ==========================================================================
--  Flash higlights 核心功能函数
-- ==========================================================================
--- 安全清理 timer
local function clear_timer()
  if active_timer then
    pcall(function()
      active_timer:stop()
      active_timer:close()
    end)
    active_timer = nil
  end
end

--- 清除指定缓冲区的所有闪烁高亮
--- @param buf number|nil 0 表示当前缓冲区
function M.clear_flash(buf)
  buf = buf or 0
  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
  clear_timer()
end

--- 核心 API：闪烁高亮一个区域
--- @param buf      number  缓冲区(0=当前)
--- @param start    table   {line, col}，1-based，与 getpos() 一致
--- @param finish   table   {line, col}，1-based，inclusive
--- @param type     string  "char"|"line"|"block"，也可用 "v"|"V"|"\22"
--- @param opts     table|nil 临时覆盖配置
function M.flash(buf, start, finish, type, opts)
  opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf

  -- 1. 先清掉旧的
  M.clear_flash(buf)

  -- 2. 统一 type 标识
  local t = type
  if t == "v" then t = "char"
  elseif t == "V" then t = "line"
  elseif t == "\22" or t == "" then t = "block"
  end

  -- 3. 转 0-based（extmark 内部使用 0-based）
  local sr, sc = start[1] - 1, start[2] - 1
  local er, ec = finish[1] - 1, finish[2] - 1

  -- 4. 根据类型创建 extmark
  if t == "line" then
    for r = sr, er do
      vim.api.nvim_buf_set_extmark(buf, ns_id, r, 0, {
        end_line   = r + 1,
        hl_group   = opts.hl_group,
        hl_eol     = true,
        priority   = opts.priority,
      })
      if opts.sign then
        vim.api.nvim_buf_set_extmark(buf, ns_id, r, 0, {
          sign_text     = opts.sign.text,
          sign_hl_group = opts.sign.hl_group,
          priority      = opts.sign.priority,
        })
      end
    end

  elseif t == "block" then
    -- 处理从右往左选的情况；end_col 是 exclusive，所以 +1
    if sc > ec then sc, ec = ec, sc end
    ec = ec + 1
    for r = sr, er do
      vim.api.nvim_buf_set_extmark(buf, ns_id, r, sc, {
        end_col  = ec,
        hl_group = opts.hl_group,
        priority = opts.priority,
        strict   = false,       -- block 模式下可能出现 `ec` 大于行长度，允许越界由 vim 自动截断
      })
      if opts.sign then
        vim.api.nvim_buf_set_extmark(buf, ns_id, r, 0, {
          sign_text     = opts.sign.text,
          sign_hl_group = opts.sign.hl_group,
          priority      = opts.sign.priority,
        })
      end
    end

  else -- char
    vim.api.nvim_buf_set_extmark(buf, ns_id, sr, sc, {
      end_line = er,
      end_col  = ec + 1,   -- inclusive -> exclusive
      hl_group = opts.hl_group,
      priority = opts.priority,
    })
    if opts.sign then
      vim.api.nvim_buf_set_extmark(buf, ns_id, sr, 0, {
        sign_text     = opts.sign.text,
        sign_hl_group = opts.sign.hl_group,
        priority      = opts.sign.priority,
      })
    end
  end

  -- 5. 自动清除
  if opts.duration > 0 then
    active_timer = vim.loop.new_timer()
    active_timer:start(opts.duration, 0, vim.schedule_wrap(function()
      M.clear_flash(buf)
    end))
  end
end


-- ==========================================================================
--  快捷封装
-- ==========================================================================
--- 快捷方式：闪烁单行
--- @param buf  number|nil
--- @param lnum number     1-based 行号
--- @param opts table|nil
function M.flash_line(buf, lnum, opts)
  M.flash(buf or 0, {lnum, 1}, {lnum, 1}, "line", opts)
end

--- 快捷方式：直接从 vim.getpos() 结果闪烁
--- @param buf        number|nil
--- @param start_mark table  getpos(""[") 格式: {bufnr, lnum, col, off}
--- @param end_mark   table  getpos(""]") 格式
--- @param type       string
--- @param opts       table|nil
function M.flash_from_marks(buf, start_mark, end_mark, type, opts)
  local sp = { start_mark[2], start_mark[3] }
  local ep = { end_mark[2], end_mark[3] }
  M.flash(buf or start_mark[1], sp, ep, type, opts)
end


-- ==========================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  M.setup_highlight()
  return M
end

return M
