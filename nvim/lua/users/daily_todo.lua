-- ==========================================================================
-- File    : daily_todo.lua
-- Author  : xyy15926
-- Created : 2026-08-28 10:29:33
-- Updated : 2026-09-06 15:46:34
-- Desc    : Determine the todo file.
-- ==========================================================================

local M = {}

M.defaults = {
  todo_base = vim.fn.expand("."),
}

M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  日期处理
-- ==========================================================================
---将 20220101、2022-01-01 类似的字符串转换为时间戳
---@param date string
---@return integer time From os.time
function M.str2timestamp(date)
  local date_t
  local ts
  if #date == 8 then
    date_t = {
      year  = tonumber(date:sub(1, 4)),
      month = tonumber(date:sub(5, 6)),
      day   = tonumber(date:sub(7, 8)),
      hour  = 0,
      min   = 0,
      sec   = 0
    }
  elseif #date == 10 then
    date_t = {
      year  = tonumber(date:sub(1, 4)),
      month = tonumber(date:sub(6, 7)),
      day   = tonumber(date:sub(9, 10)),
      hour  = 0,
      min   = 0,
      sec   = 0
    }
  else
    local y, m, d = date:match("(%d%d%d%d)(%d%d)(%d%d)")
    date_t = {
      year  = tonumber(y),
      month = tonumber(m),
      day   = tonumber(d),
      hour  = 0, min = 0, sec = 0,
    }
  end
  ts = os.time(date_t)
  return ts
end


---获取某日所属周的 `no` 指定的那日
---@param date string|table|number?
---@param no number? 1-Monday, 7-Sunday
---@return integer From os.time
function M.get_week_date(date, no)
  local today
  if date == nil then
    today = os.date("*t")
  elseif type(date) == "string" then
    today = os.date("*t", M.str2timestamp(date))
  elseif type(date) == "number" then
    today = os.date("*t", date)
  elseif type(date) == "table" then
      today = os.date("*t", os.time(date))
  end
  local wday = today.wday         -- 1=周日, 2=周一, ..., 7=周六

  -- 距离本周一的天数（周一=0, 周日=6）
  local days_since_monday = (wday + 5) % 7

  -- 本周一（os.time 支持负数 day，自动回退月份）
  local monday = os.time({
    year  = today.year,
    month = today.month,
    day   = today.day - days_since_monday,
  })

  no = no or 1
  return monday + (no - 1) * 86400
end


-- %% =======================================================================
--  Buffer 创建、打开
-- ==========================================================================
---当前日期所属周 markdown 文件
---@param date string|table|integer?
---@param offset integer Offset of number of weeks.
---@return string file_path
function M.weekly_todo(date, offset)
  offset = offset or 0
  local monday = M.get_week_date(date, 1) + offset * 86400 * 7
  local sunday = monday + 6 * 86400
  local date_str = os.date("%Y%m%d", monday) .. "_" .. os.date("%m%d", sunday)

  -- local pattern = base .. "/" .. date_str .. "_*.md"
  -- local files = vim.fn.glob(pattern, false, true)       -- glob 匹配返回路径列表
  -- if #files > 0 then
  --   return files[1]  -- 找到已有文件
  -- end

  return M.opts.todo_base .. "/" .. date_str .. ".md"
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  vim.api.nvim_create_user_command(
    "WeeklyTodo",
    -- opts.args 字符串形式参数
    -- opts.fargs 参数列表
    -- opts.bang 是否使用 `!`
    -- opts.line1、opts.line2 范围起止行号
    -- opts.range 范围数量
    -- opts.count 范围计数（range 命令）
    -- opts.reg 寄存器名
    function(opts)
      local offset = tonumber(opts.fargs[1]) or 0
      vim.cmd("tabnew " .. M.weekly_todo(nil, offset))
    end, { nargs = "*" } )
end

return M
