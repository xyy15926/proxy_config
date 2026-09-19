-- ==========================================================================
-- File    : dev.lua
-- Author  : xyy15926
-- Created : 2026-09-07 22:00:20
-- Updated : 2026-09-18 14:38:19
-- Desc    : Dev tools.
-- ==========================================================================

local M = {}
M.defaults = { }
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  按键模拟
-- ==========================================================================
function M.feedkeys(keys)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, false, true),
    "n",
    false
  )
end


-- %% =======================================================================
--  Lua 值格式化打印
-- ==========================================================================
--- 递归格式化 Lua 值为逐行展开的字符串表示
--- @param v      any        要格式化的值
--- @param depth? number     当前缩进深度，首次调用可省略
--- @param seen?  table      已访问的 table 集合，用于检测循环引用
--- @return string
local function format(v, depth, seen)
  depth = depth or 0
  seen = seen or {}
  local t = type(v)

  -- 基本类型直接转字符串
  if t == "string"   then return string.format("%q", v) end
  if t == "function" then return tostring(v) end
  if t ~= "table"    then return tostring(v) end

  -- 循环引用，避免无限递归
  if seen[v] then return "<ref>" end
  seen[v] = true

  local pad  = string.rep("  ", depth + 1)
  local base = string.rep("  ", depth)
  local parts = {}
  local n = #v  -- 数组部分长度

  -- 遍历数组部分（整数索引 1..n），每项独占一行
  for i = 1, n do
    parts[#parts + 1] = pad .. format(v[i], depth + 1, seen)
  end

  -- 遍历哈希部分（非数组 key）
  for k, val in pairs(v) do
    -- 跳过已处理的数组索引，避免重复输出
    if not (type(k) == "number" and k >= 1 and k <= n and k % 1 == 0) then
      -- 合法标识符直接使用，否则用方括号包裹
      local key = type(k) == "string" and k:match("^[%a_][%w_]*$")
        and k or ("[" .. tostring(k) .. "]")
      parts[#parts + 1] = pad .. key .. " = " .. format(val, depth + 1, seen)
    end
  end

  -- 空表
  if #parts == 0 then return "{}" end
  return "{\n" .. table.concat(parts, ",\n") .. ",\n" .. base .. "}"
end


--- 将 Lua 值格式化后输出到居中浮动窗口
--- @param expr   any    要查看的 Lua 值
--- @param label? string 可选标题，显示在输出顶部
function M.float_inspect(expr, label)
  local lines = {}
  if label then
    lines[#lines + 1] = "-- " .. label
    lines[#lines + 1] = ""
  end
  -- 逐行拆分格式化结果
  for l in (format(expr) .. "\n"):gmatch("(.-)\n") do
    lines[#lines + 1] = l
  end

  -- 创建只读浮动缓冲区
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("filetype",   "lua",   { buf = buf })
  vim.api.nvim_set_option_value("modifiable", false,  { buf = buf })
  vim.api.nvim_set_option_value("bufhidden",  "wipe", { buf = buf })

  -- 计算居中位置
  local w = math.min(math.floor(vim.o.columns * 0.7), 90)
  local h = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", width = w, height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal", border = "rounded",
  })
  vim.api.nvim_set_option_value("number",     true, { win = win })
  vim.api.nvim_set_option_value("cursorline", true, { win = win })

  -- 按 q 关闭窗口
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
end


-- %% =======================================================================
--  文件、内容读取
-- ==========================================================================
--- 获取指定文件内容字符串或 buffer 号
--- @param filepath string
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
  return table.concat(vim.fn.readfile(filepath), "\n")
end


--- 获取当前行或 visual 选区中多行
--- @param keep_mode boolean?
--- @return string | string[]
function M.get_content(keep_mode)
  local sp = vim.fn.getpos(".")
  local ep = vim.fn.getpos("v")
  local content = sp[2] == ep[2] and sp[3] == ep[3]
    and vim.api.nvim_get_current_line()
    or vim.fn.getregion(sp, ep, { type = vim.fn.mode() })
  if not keep_mode then M.feedkeys("<Esc>") end
  return content
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  return M
end

return M
