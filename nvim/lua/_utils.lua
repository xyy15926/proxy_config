local M = {}

local root_flags = { '.root', '.svn', '.git', '.hg', '.project', 'Makefile' }
M.root_flags = root_flags

-- 向上搜索找到项目根目录
function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  return vim.fs.root(0, root_flags) or ''
end

-- 检测是否有 pixi 环境
function M.has_pixi(root)
  return root ~= '' and vim.fn.glob(root .. '/.pixi') ~= ''
end

-- 给命令加上 pixi run 前缀
function M.pixify(cmd, root)
  if M.has_pixi(root) then
    local new_cmd = { 'pixi', 'run' }
    for _, v in ipairs(cmd) do table.insert(new_cmd, v) end
    return new_cmd
  end
  return cmd
end

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
function M.today_note()
  local date_range = M.get_week_range()
  local base = vim.fn.expand("~/files.md/gtd")
  local date_str = os.date("%Y%m%d", date_range.first) .. "_" .. os.date("%m%d", date_range.last)

  -- local pattern = base .. "/" .. date_str .. "_*.md"
  -- local files = vim.fn.glob(pattern, false, true)       -- glob 匹配返回路径列表
  -- if #files > 0 then
  --   return files[1]  -- 找到已有文件
  -- end

  return base .. "/" .. date_str .. ".md"
end

return M
