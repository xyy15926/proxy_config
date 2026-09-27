-- ==========================================================================
-- File    : debounce.lua
-- Author  : xyy15926
-- Created : 2026-09-24 16:09:27
-- Updated : 2026-09-24 16:09:27
-- Desc    : Debounce to 
-- ==========================================================================

local uv = vim.uv or vim.loop
local api = vim.api
local M = {}

--- 各 buffer 的防抖 timer(由 uv_timer 实现)
--- @type table<integer, uv.uv_timer_t>
M._timers = {}


--- 生成防抖用的唯一 key
--- @param aug_name string
--- @param bufnr integer
--- @return string
local function timer_key(aug_name, bufnr)
  return aug_name.. ":" .. bufnr
end


--- 触发防抖
--- @param fn function<integer?, string?> 防抖后实际要执行的函数
--- @param aug_name string 通常为 augroup 名称，用于确定 timer 键
--- @param bufnr integer 缓冲区 ID，timer 一般须为各缓冲区单独指定
--- @param wait integer? 防抖延迟毫秒数，默认 300ms
--- @param ev_name string|nil 事件名
--- @return nil
function M.debounce_fn(fn, aug_name, bufnr, wait, ev_name)
  local key = timer_key(aug_name, bufnr)
  local timer = M._timers[key]
  wait = wait or 300

  if not timer then
    timer = uv.new_timer()
    M._timers[key] = timer
  end
  if timer == nil then
    error("cannot set timer te debounce for: " .. key)
  end

  timer:stop()
  timer:start(wait, 0, vim.schedule_wrap(function()
    if timer:is_closing() then return end
    fn(bufnr, ev_name)
  end))
end


--- 清理当前 buffer 绑定的防抖与自动命令
--- @param aug_name string 自动命令组名
--- @param bufnr integer 规范化的目标 buffer id
--- @return nil
function M.clear_debounce_au(aug_name, bufnr)
  local key = timer_key(aug_name, bufnr)
  local timer = M._timers[key]
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
  M._timers[key] = nil
  api.nvim_clear_autocmds({ group = aug_name, buffer = bufnr })
end


--- 为指定 buffer 注册执行 `fn` 的局部自动命令并绑定防抖
--- @param aug_name string 自动命令组名
--- @param bufnr integer 规范化的目标 buffer id
--- @param fn function<integer?, string?> 防抖后实际要执行的函数
--- @param events string[]? 触发事件列表 (e.g., {"TextChanged", "InsertLeave"})
--- @param wait integer? 防抖延迟时间 (毫秒)
function M.register_debounce_au(aug_name, bufnr, fn, events, wait)
  events = events or { "TextChanged", "InsertLeave", "BufWritePost" }
  wait = wait or 300
  assert(bufnr > 0, "Buffer number should be normed")

  -- 可能在多个 buffer 分别调用，故置 `clear = false` 避免清除
  -- 而是，通过注册在各 buffer 上的 `clear_debounce_au` 中 `nvim_clear_autocmds` 管理
  local group = api.nvim_create_augroup(aug_name, { clear = false })

  api.nvim_create_autocmd(events, {
    group = group,
    buffer = bufnr,
    callback = function(ev)
      M.debounce_fn(fn, aug_name, bufnr, wait, ev.event)
    end,
  })

  api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      M.clear_debounce_au(aug_name, bufnr)
    end,
  })
end


function M.setup(_opts)
  return M
end

return M
