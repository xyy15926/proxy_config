-- ==========================================================================
-- File    : bufau.lua
-- Author  : xyy15926
-- Created : 2026-09-26 21:37:56
-- Updated : 2026-09-27 21:54:43
-- Desc    : Utils to attach function to buffer.
-- ==========================================================================

local utils = require("users.utils")

local M = {}

M.defaults = {
  wait = 300,
  freq_events = { "TextChanged", "InsertLeave", "BufWritePost", "BufEnter" },
}
M.opts = vim.deepcopy(M.defaults)

--- 各 buffer 的开启状态
--- @type table<integer, boolean>
M._enabled = {}



-- %% =======================================================================
--  按 Filetype 为特定 buffer 设置 toggle 函数
-- ==========================================================================

--- @param bufnr integer
--- @param filetypes string[] 支持的 filetypes
--- @return boolean
local function is_supported(bufnr, filetypes)
  return utils.buf_supported(bufnr, {
    filetypes = filetypes,
  })
end


--- 根据设置、清除函数创建 enable, disable, toggle 状态切换函数
--- enable 函数会检查 buffer 是否被支持，可视为有 filetype 守卫的 update
--- @param fn function<integer> 在指定 bufnr 上执行设置
--- @param unset_fn function<integer>? 在指定 bufnr 上清除设置
--- @param enabled table<integer, boolean> 维护 buffer 是否被设置
--- @param filetypes string[] 支持的 filetypes
--- @return function, function, function
function M.toggle_on_filetypes(fn, unset_fn, enabled, filetypes)
  local enable = function(bufnr)
    bufnr = utils.bufnr(bufnr)
    if not is_supported(bufnr, filetypes) then return end
    enabled[bufnr] = true
    fn(bufnr)
  end

  local disable = function(bufnr)
    bufnr = utils.bufnr(bufnr)
    if not is_supported(bufnr, filetypes) then return end
    enabled[bufnr] = false
    if unset_fn then unset_fn(bufnr) end
  end

  local toggle = function(bufnr)
    bufnr = utils.bufnr(bufnr)
    if not is_supported(bufnr, filetypes) then return end
    if enabled[bufnr] then
      disable(bufnr)
    else
      enable(bufnr)
    end
  end

  return enable, disable, toggle
end


--- 为指定 filetype 的 buffer 注册执行 `fn` 的局部自动命令并绑定防抖
--  即，`debounce.register_debounce_au` 简单封装
--- @param aug_key string 自动命令组名 key
--- @param fn function<integer?, string?> 防抖后实际要执行的函数
--- @param unset_fn function<integer?>? 清除防抖后的需执行的钩子函数
--- @param enabled table<integer, boolean> 维护 buffer 是否被设置
--- @param filetypes string[] 待注册 autocmd 的 filetypes
--- @param events string[]? 触发事件列表 (e.g., {"TextChanged", "InsertLeave"})
--- @param wait integer? 防抖延迟时间 (毫秒)
function M.toggle_debounce_au_on_filetypes(aug_key, fn, unset_fn, enabled, filetypes, events, wait)
  local filetype_aug = aug_key .. ".ft"
  local debounce_aug = aug_key .. ".debounce"
  events = events or M.opts.freq_events

  -- 1. 创建 enable 函数
  local enable = function(bufnr)
    bufnr = utils.bufnr(bufnr)
    if not is_supported(bufnr, filetypes) then return end
    utils.register_debounce_au(debounce_aug, bufnr, fn, events, wait)
    enabled[bufnr] = true
    fn(bufnr)
  end

  -- 2. 注册 debounced 自动命令
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup(filetype_aug, { clear = true } ),
    pattern = filetypes,
    callback = function(ev)
      local bufnr = utils.bufnr(ev.buf)
      if not is_supported(bufnr, filetypes) then return end
      -- 在 bufnr 上启用
      enable(bufnr)
    end,
  })

  -- 3. 创建 disable 函数
  local disable = function(bufnr)
    bufnr = utils.bufnr(bufnr)
    if not is_supported(bufnr, filetypes) then return end
    -- 清除 debounced 自动命令
    utils.clear_debounce_au(debounce_aug, bufnr)
    enabled[bufnr] = false
    if unset_fn then unset_fn(bufnr) end
  end

  -- 4. 创建 toggle 函数
  local toggle = function(bufnr)
    bufnr = utils.bufnr(bufnr)
    if not is_supported(bufnr, filetypes) then return end
    if enabled[bufnr] then
      disable(bufnr)
    else
      enable(bufnr)
    end
  end

  -- 为已打开的 buffer 补调用 enable
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if is_supported(bufnr, filetypes) then enable(bufnr) end
  end

  return enable, disable, toggle
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

end

return M
