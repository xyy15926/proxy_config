-- =========================================================
-- File    : alignment.lua
-- Author  : xyy15926
-- Created : 2026-08-24 22:14:09
-- Updated : 2026-08-26 10:31:00
-- Desc    : 对齐注释、逗号等
-- =========================================================

local M = {}

-- 默认配置
M.defaults = {
  min_spaces = 2,       -- 代码与注释之间至少保留的空格数
  search_range = 5,     -- 上下搜索的行数范围
  auto_align = false,   -- 退出 Insert 自动对齐
  auto_file_ptns = {
    "*.py",
    "*.rs",
    "*.lua",
    "*.c", "*.cpp", "*.h",
    "*.sh",
  }
}

M.opts = vim.deepcopy(M.defaults)

-- ============================================================================
-- 1. 获取当前代码类型的行内注释分隔符
-- ============================================================================
function M.get_comment_marker()
  local cs = vim.bo.commentstring
  if cs and cs ~= "" then
    -- 若 commentstring 显式包含 //，优先采用（覆盖 C 语言默认的 /*%s*/）
    if cs:find("//", 1, true) then
      return "//"
    end
    -- 提取 %s 之前的部分
    local marker = cs:match("^(.-)%%s")
    if marker then
      marker = vim.trim(marker)
      if marker ~= "" then
        return marker
      end
    end
  end

  -- 常见语言 fallback
  local map = {
    c = "//", cpp = "//", java = "//", javascript = "//", typescript = "//",
    javascriptreact = "//", typescriptreact = "//", jsonc = "//",
    rust = "//", go = "//", kotlin = "//", swift = "//", csharp = "//",
    php = "//", scala = "//", dart = "//",
    lua = "--", sql = "--", haskell = "--",
    python = "#", ruby = "#", perl = "#", sh = "#", bash = "#", zsh = "#",
    yaml = "#", toml = "#", conf = "#", dockerfile = "#", makefile = "#",
    r = "#",
    vim = '"', dosini = ";", ini = ";",
  }
  return map[vim.bo.filetype] or "//"
end

-- ============================================================================
-- 辅助：拆分一行为 [代码部分, 注释部分]
-- 仅识别真正的"行内注释"（注释符前存在非空白代码；纯注释行返回 nil）
-- ============================================================================
function M.split_inline_comment(line, marker)
  if not line or line:match("^%s*$") then
    return nil, nil
  end
  -- local esc = vim.pesc(marker)               -- 无需转义
  local start_pos = line:find(marker, 1, true)  -- 此处 `true` 表示纯文本匹配，转义反而不对
  if not start_pos then
    return nil, nil
  end
  local code = line:sub(1, start_pos - 1):gsub("%s+$", "")
  local comment = line:sub(start_pos)
  -- 行内注释要求注释前必须有实际代码内容
  if code == "" then
    return nil, nil
  end
  return code, comment
end

-- ============================================================================
-- 2. 最大搜索当前行上下指定范围，确定当前行所属代码块范围
-- 参数: row (1-indexed), max_radius (默认 50)
-- 返回: block_start, block_end (1-indexed, 闭区间)
-- 规则: 相同缩进 + 连续行内注释；空行/缩进变化/无注释/纯注释行 均打断
-- ============================================================================
function M.get_current_block_range(row, max_radius)
  max_radius = max_radius or M.opts.search_range
  local buf = vim.api.nvim_get_current_buf()
  local total = vim.api.nvim_buf_line_count(buf)
  local marker = M.get_comment_marker()

  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
  local base_indent = line:match("^(%s*)") or ""

  -- 若当前行本身不含行内注释，仅返回当前行（无法对齐）
  local base_code, base_comment = M.split_inline_comment(line, marker)
  if not base_comment then
    return row, row
  end

  local start_row, end_row = row, row

  -- 向上搜索
  for r = row - 1, math.max(1, row - max_radius), -1 do
    local l = vim.api.nvim_buf_get_lines(buf, r - 1, r, false)[1] or ""
    if l:match("^%s*$") then break end

    local indent = l:match("^(%s*)") or ""
    if #indent ~= #base_indent then break end

    local code, comment = M.split_inline_comment(l, marker)
    if not comment then break end

    start_row = r
  end

  -- 向下搜索
  for r = row + 1, math.min(total, row + max_radius) do
    local l = vim.api.nvim_buf_get_lines(buf, r - 1, r, false)[1] or ""
    if l:match("^%s*$") then break end

    local indent = l:match("^(%s*)") or ""
    if #indent ~= #base_indent then break end

    local code, comment = M.split_inline_comment(l, marker)
    if not comment then break end

    end_row = r
  end

  return start_row, end_row
end

-- ============================================================================
-- 3. 将 visual 选取按缩进、连续行内注释切分为多个代码块
-- 参数: start_row, end_row (1-indexed, 闭区间)
-- 返回: blocks = { {start_row=..., end_row=...}, ... }
-- ============================================================================
function M.split_visual_blocks(start_row, end_row)
  local buf = vim.api.nvim_get_current_buf()
  local marker = M.get_comment_marker()
  local blocks = {}
  local cur_block = nil
  local cur_indent = nil

  for r = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(buf, r - 1, r, false)[1] or ""

    -- 空行打断
    if line:match("^%s*$") then
      if cur_block then
        table.insert(blocks, cur_block)
        cur_block = nil
        cur_indent = nil
      end
      goto continue
    end

    local indent = line:match("^(%s*)") or ""
    local code, comment = M.split_inline_comment(line, marker)

    -- 无行内注释或纯注释行打断
    if not comment then
      if cur_block then
        table.insert(blocks, cur_block)
        cur_block = nil
        cur_indent = nil
      end
      goto continue
    end

    if not cur_block then
      cur_block = { start_row = r, end_row = r }
      cur_indent = indent
    elseif #indent == #cur_indent then
      cur_block.end_row = r
    else
      -- 缩进变化，结束旧块，开启新块
      table.insert(blocks, cur_block)
      cur_block = { start_row = r, end_row = r }
      cur_indent = indent
    end

    ::continue::
  end

  if cur_block then
    table.insert(blocks, cur_block)
  end

  return blocks
end

-- ============================================================================
-- 4. 核心功能：对齐指定范围内行内注释
--   无注释行保持原样
--   有注释行按代码部分最大显示宽度对齐
-- 参数: start_row, end_row (1-indexed, 闭区间)
-- ============================================================================
function M.align_block(start_row, end_row)
  if start_row > end_row then return end
  local buf = vim.api.nvim_get_current_buf()
  local marker = M.get_comment_marker()
  local min_gap = M.opts.min_spaces

  local rows = {}
  local max_width = 0

  -- 第一遍：收集信息并计算最大代码显示宽度（自动处理 Tab/宽字符）
  for r = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(buf, r - 1, r, false)[1] or ""
    local code, comment = M.split_inline_comment(line, marker)

    if comment then
      local w = vim.fn.strdisplaywidth(code)
      max_width = math.max(max_width, w)
      table.insert(rows, { row = r, code = code, comment = comment, width = w })
    else
      table.insert(rows, { row = r, original = line })
    end
  end

  if max_width == 0 then return end

  -- 第二遍：构建新行并批量写入
  local new_lines = {}
  for _, item in ipairs(rows) do
    if item.comment then
      local pad = max_width - item.width + min_gap
      local new_line = item.code .. string.rep(" ", pad) .. item.comment
      table.insert(new_lines, new_line)
    else
      table.insert(new_lines, item.original)
    end
  end

  vim.api.nvim_buf_set_lines(buf, start_row - 1, end_row, false, new_lines)
end


-- 指定范围自动分段对齐（用于 Visual 模式）
function M.align_block_auto_split(start_row, end_row)
  local blocks = M.split_visual_blocks(start_row, end_row)
  for _, b in ipairs(blocks) do
    M.align_block(b.start_row, b.end_row)
  end
end


-- ============================================================================
-- 组合功能
-- ============================================================================

-- 针对当前行的注释对齐（自动探测所属代码块）
function M.align_current_line_auto()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local s, e = M.get_current_block_range(row)
  M.align_block(s, e)
end

-- 指定范围自动分段对齐（用于 Visual 模式）
function M.align_visual_auto()
  local s = vim.fn.line("v")
  local e = vim.fn.line(".")
  if s > e then s, e = e, s end
  M.align_block_auto_split(s, e)
  -- 手动退出可视状态
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false
  )
end

-- Visual 模式：对选取范围强制整体对齐
function M.align_visual_force()
  local s = vim.fn.line("v")
  local e = vim.fn.line(".")
  if s > e then s, e = e, s end
  M.align_block(s, e)
  -- 手动退出可视状态
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false
  )
end

-- Normal 模式：支持 [count]<leader>XXX 范围强制整体对齐，默认仅当前行
function M.align_normal_count_force()
  local count = vim.v.count1
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local s = row
  local e = math.min(row + count - 1, vim.api.nvim_buf_line_count(0))
  M.align_force_range(s, e)
end

-- ============================================================================
-- 初始化与键位绑定
-- ============================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  vim.keymap.set("n", "<leader>ua", M.align_current_line_auto, { desc = "Align Comments" })
  vim.keymap.set("v", "<leader>ua", M.align_visual_auto, { desc = "Align Comments(auto split)" })
  vim.keymap.set("n", "<leader>uq", M.align_normal_count_force, { desc = "Align Comments(force range)" })
  vim.keymap.set("v", "<leader>uq", M.align_visual_force, { desc = "Align Comments(force range)" })

  -- 脱离 Insert 自动对齐
  local group = vim.api.nvim_create_augroup("AutoAlignInlineComment", { clear = true })
  if opts.auto_align then
    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
      group = group,
      pattern = M.opts.auto_file_ptns,
      callback = function(args)
        M.align_current_line_auto()
      end,
    })
  end
end

return M
