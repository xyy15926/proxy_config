-- ==================================================
-- daily_todo.lua
-- ==================================================

local M = {}

M.defaults = {
  todo_base = vim.fn.expand("."),
}

-- 全局配置
M.opts = vim.deepcopy(M.defaults)

-- 获取当日所属的周日期范围
function M.get_week_range()
  local today = os.date("*t")
  local wday = today.wday  -- 1=周日, 2=周一, ..., 7=周六

  -- 距离本周一的天数（周一=0, 周日=6）
  local days_since_monday = (wday + 5) % 7

  -- 本周一（os.time 支持负数 day，自动回退月份）
  local monday = os.time({
    year  = today.year,
    month = today.month,
    day   = today.day - days_since_monday,
  })

  -- 本周日 = 周一 + 6 天
  local sunday = monday + 6 * 86400

  return { first = monday, last = sunday, }
end

-- 当前日期所属周 markdown 文件
function M.weekly_todo()
  local date_range = M.get_week_range()
  local date_str = os.date("%Y%m%d", date_range.first) .. "_" .. os.date("%m%d", date_range.last)

  -- local pattern = base .. "/" .. date_str .. "_*.md"
  -- local files = vim.fn.glob(pattern, false, true)       -- glob 匹配返回路径列表
  -- if #files > 0 then
  --   return files[1]  -- 找到已有文件
  -- end

  return M.opts.todo_base .. "/" .. date_str .. ".md"
end

-- 允许自定义全局配置
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M
