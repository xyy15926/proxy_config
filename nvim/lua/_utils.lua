local M = {}

M.defaults = {
  root_flags = { '.root', '.svn', '.git', '.hg', '.project', 'Makefile' },
  todo_base = vim.fn.expand("."),
}

-- 全局配置
M.opts = vim.deepcopy(M.defaults)

-- 向上搜索找到项目根目录
function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  return vim.fs.root(0, M.opts.root_flags) or ''
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
  local date_str = os.date("%Y%m%d", date_range.first) .. "_" .. os.date("%m%d", date_range.last)

  -- local pattern = base .. "/" .. date_str .. "_*.md"
  -- local files = vim.fn.glob(pattern, false, true)       -- glob 匹配返回路径列表
  -- if #files > 0 then
  --   return files[1]  -- 找到已有文件
  -- end

  return M.opts.todo_base .. "/" .. date_str .. ".md"
end

function M.yank_without_indent()
  -- 必须在退出 visual 前捕获这些状态！
  local mode = vim.fn.mode()           -- "v", "V", 或 "\22"(^V)
  local vpos = vim.fn.getpos('v')      -- visual 起点（实时）
  local cpos = vim.fn.getpos('.')      -- 光标位置（实时）

  -- 先退出 visual，后续行为与原生 y 一致
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
    'x', false
  )

  -- getregion 需要正确的 type 标识
  local reg_type = mode
  if mode == '\22' then
    reg_type = 'block'
  end

  -- 获取选中文本（Neovim 0.10+）
  local ok, lines = pcall(vim.fn.getregion, vpos, cpos, { type = reg_type })
  if not ok or not lines or #lines == 0 then
    return
  end

  -- 计算非空行的最小前导空白
  local min_indent = math.huge
  for _, line in ipairs(lines) do
    if line:find('%S') then
      local lead = #(line:match('^%s*') or '')
      min_indent = math.min(min_indent, lead)
    end
  end

  local text
  if min_indent == math.huge or min_indent == 0 then
    text = table.concat(lines, '\n')
  else
    local trimmed = {}
    for _, line in ipairs(lines) do
      table.insert(trimmed, line:sub(min_indent + 1))
    end
    text = table.concat(trimmed, '\n')
  end

  -- 更新寄存器，与原生 y 行为完全一致
  -- vim.fn.setreg('"', text, mode)  -- 匿名寄存器，默认删、改、复制、黏贴目标
  vim.fn.setreg('+', text, mode)  -- 系统 Clipboard 寄存器
  -- vim.fn.setreg('*', text, mode)  -- X11 为鼠标中间粘贴内容；Win/MacOS 下同 `+`，似乎会与 `+` 自动同步
  -- vim.fn.setreg('0', text, mode)  -- yank 专用寄存器

  -- 触发 yank 高亮反馈
  vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 150, visual = true })
end

-- 允许自定义全局配置
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M
