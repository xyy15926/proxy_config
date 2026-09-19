-- ==========================================================================
-- File    : keys.lua
-- Author  : xyy15926
-- Created : 2026-09-08 22:01:25
-- Updated : 2026-09-19 22:30:45
-- Desc    : Snacks keymaps
--
-- Ref:
-- - lazy/snacks.nvim/docs/picker.md
-- - lazy/snacks.nvim/lua/snacks/picker/config/sources.lua
-- - lazy/snacks.nvim/lua/snacks/picker/config/defaults.lua
-- - lazy/snacks.nvim/docs/scratch.md
-- ==========================================================================

-- %% ===========================================================
--  为 grep 工具预计算排除参数（启动时检测一次，运行时零开销）
-- 用 fd 参数排除文件（比 Lua 过滤更高效）
-- 如果系统没有 fd，snacks 会自动 fallback 到 rg 或 vim 内置
-- =============================================================
local EXCLUDE_PATTERNS = {
  "*.pyc", "*.so", "*.o", "*.bin", "*.exe", "*.dll",
  "*.class", "*.jar",
  "*.png", "*.jpg", "*.pdf",
  "*.docx", "*.doc", "*.xlsx", "*.xls", "*.ppt", "*.pptx",
  "node_modules", ".git", "__pycache__",
  "*.ttf",
}

-- 检测系统上实际可用的文件搜索工具
-- snacks.files 优先级：fd > rg > find
local FILE_TOOL = (function()
  if vim.fn.executable("fd") == 1 then return "fd" end
  if vim.fn.executable("fdfind") == 1 then return "fd" end  -- Ubuntu 包名
  if vim.fn.executable("rg") == 1 then return "rg" end
  return "find"
end)()

-- 预计算各工具的参数表
local PRECOMPUTED = {
  fd = {},
  rg = {},
  find = {},
}

-- fd: --exclude PATTERN
for _, p in ipairs(EXCLUDE_PATTERNS) do
  table.insert(PRECOMPUTED.fd, "--exclude")
  table.insert(PRECOMPUTED.fd, p)
end

-- rg: -g '!PATTERN'（目录需要 /**）
for _, p in ipairs(EXCLUDE_PATTERNS) do
  table.insert(PRECOMPUTED.rg, "-g")
  if not p:match("%.") and not p:match("%*%*") then
    table.insert(PRECOMPUTED.rg, "!" .. p .. "/**")
  else
    table.insert(PRECOMPUTED.rg, "!" .. p)
  end
end

-- find: -not -path '*/PATTERN/*'
for _, p in ipairs(EXCLUDE_PATTERNS) do
  table.insert(PRECOMPUTED.find, "-not")
  table.insert(PRECOMPUTED.find, "-path")
  table.insert(PRECOMPUTED.find, "*/" .. p .. "/*")
end

-- 直接取预计算结果
FILE_ARGS = PRECOMPUTED[FILE_TOOL] or {}
GREP_ARGS = PRECOMPUTED.rg  -- grep 始终用 rg


-- %% =======================================================================
--  Keymaps
-- ==========================================================================
-- 获取当前 buffer 对应的根目录，作为文件查询起始点
local gcwd = require("users.rooter").find_project_root

--- @diagnostic disable: undefined-field
return {
  -- %% Filename and buffer-name ============================================
  { "<leader>fs", function() require("snacks").picker.smart({ multi = { "buffers", "recent", "files" }, } ) end, desc = "Find: Smart" },
  { "<leader>ff", function() require("snacks").picker.files({ hidden = true, args = FILE_ARGS, cwd = gcwd(), }) end, desc = "Find: Files(Cwd)", },
  { "<leader>fF", function() require("snacks").picker.files({ hidden = true, args = FILE_ARGS, }) end, desc = "Find: Files(WorkSpace)", },
  { "<leader>fr", function() require("snacks").picker.recent() end, desc = "Find: Recent Files" },
  { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Find: Buffers" },
  { "<leader>ft", function() require("snacks").picker.buffers({ filter = { filter = function(item,_filter) return item.buftype == "terminal" end, } }) end, desc = "Find: Terminals" },

  -- %% File or buffer Content ==============================================
  { "<leader>fg", function() require("snacks").picker.grep({ hidden = true, args = GREP_ARGS, cwd = gcwd(), }) end, desc = "Grep: Live(Cwd)", },
  { "<leader>fG", function() require("snacks").picker.grep({ hidden = true, args = GREP_ARGS }) end, desc = "Grep: Live(WorkSpace)", },
  { "<leader>fw", function() require("snacks").picker.grep({ cwd = gcwd(), search = vim.fn.expand("<cword>") }) end, desc = "Grep: Word(Cwd)" },
  { "<leader>fW", function() require("snacks").picker.grep({ search = vim.fn.expand("<cword>") }) end, desc = "Grep: Word(WorkSpace)" },
  { "<leader>f/", function() require("snacks").picker.grep({ buffers = { vim.api.nvim_get_current_buf() } }) end, desc = "Grep: In Cur Buffer" },
  { "<leader>fl", function() require("snacks").picker.lines() end, desc = "Grep: Line in Cur Buffer" },

  -- %% LSP 信息相关 ========================================================
  { "<leader>hd", function() require("snacks").picker.lsp_definitions() end, desc = "Lsp: Definitions" },
  { "<leader>hr", function() require("snacks").picker.lsp_references() end, desc = "Lsp: References" },
  { "<leader>hs", function() require("snacks").picker.lsp_symbols() end, desc = "Lsp: Symbols" },
  { "<leader>hg", function() require("snacks").picker.diagnostics_buffer() end, desc = "Lsp: Diagnostics" },
  { "<leader>hG", function() require("snacks").picker.diagnostics() end, desc = "Lsp: Diagnostics(Repo)" },

  -- %% Resume, Pickers =====================================================
  { "<leader>fj", function() require("snacks").picker.resume() end, desc = "Resume Last Picker" },
  { "<leader>ll", function() require("snacks").picker.pickers() end, desc = "Picker Picker" },

  -- %% File explorer and preview ===========================================
  -- `snack.explorer()` 与 `snack.picker.explorer()` 等价
  -- 打开当前文件所在根目录、所在目录（缺省为当前工作目录）
  { "<leader>nn", function() require("snacks").explorer({ cwd = gcwd() }) end, desc = "FileTree: Cwd" },
  { "<leader>nN", function() require("snacks").explorer() end, desc = "FileTree: WorkSpace" },
  { "<leader>nc", function() require("snacks").explorer({ cwd = vim.fn.expand("%:p:h") }) end, desc = "FileTree: Parent Dir" },

  { "<leader>nu", function() require("snacks").picker.undo() end, desc = "Preview: Undo" },
  { "<leader>nj", function() require("snacks").picker.jumps() end, desc = "Preview: Jumps" },
  { "<leader>nm", function() require("snacks").picker.marks() end, desc = "Preview: Marks" },

  -- Bug: 默认 markdown = true，但是无法显示标题
  { "<leader>nT", function() require("snacks").picker.treesitter() end, desc = "Tags: Preview" },

  -- %% Git preivew =========================================================
  { "<leader>gA", function() require("snacks").picker.git_diff() end, desc = "Preview: Git Diffs(Repo)" },
  { "<leader>gl", function() require("snacks").picker.git_log_file() end, desc = "Preview: Git Log(File)" },
  { "<leader>gL", function() require("snacks").picker.git_log() end, desc = "Preview: Git Log(Repo)" },
  { "<leader>gB", function() require("snacks").picker.git_log_line() end, desc = "Preview: Git Log(Line)" },

  { "<leader>gm", function() require("snacks").scratch.open({ ft = "gitcommit", name = "commit-draft" }) end, desc = "Commit Msg Scratch" },

  -- %% 其他杂项 picker =====================================================
  { "<leader>lc", function() require("snacks").picker.colorschemes() end, desc = "ColorSchemes" },
  { "<leader>lq", function() require("snacks").picker.qflist() end, desc = "Quickfix" },
  { "<leader>lz", function() require("snacks").picker.loclist() end, desc = "Loclist" },
  { "<leader>lr", function() require("snacks").picker.registers() end, desc = "Registers" },
  { "<leader>lm", function() require("snacks").scratch.select() end, desc = "Scratchs" },
  { "<leader>lp", function() require("snacks").picker.projects() end, desc = "Projects" },
  { "<leader>l/", function() require("snacks").picker.search_history() end, desc = "Search Hist" },

  -- %% 其他组件 ============================================================
  { "<leader>un", function() require("snacks").notifier.show_history() end, desc = "Notification History" },
  { "<leader>uz", function() require("snacks").dashboard() end, desc = "Dashboard" },
  { "<leader>um", function() require("snacks").scratch.open() end, desc = "Scratch" },
  { "<leader>uM", function() require("snacks").scratch.open({ ft = "markdown", name = "markdown" }) end, desc = "Scratch(Markdown)" },

  { "<leader>bd", function() require("snacks").bufdelete() end, desc = "Delete Buffer" },

  { "<leader>qB", function() require("snacks").gitbrowse() end, desc = "Git Browse" },
  { "<leader>qg", function() require("snacks").lazygit() end, desc = "Lazygit" },
}
--- @diagnostic enable: undefined-field
