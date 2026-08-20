-- ===================================================
-- Snacks keymap
-- ===================================================
-- =============================================================
-- 预计算排除参数（启动时检测一次，运行时零开销）
-- =============================================================

local EXCLUDE_PATTERNS = {
  "*.pyc", "*.so", "*.o", "*.bin", "*.exe", "*.dll",
  "*.class", "*.jar",
  "*.png", "*.jpg", "*.pdf",
  "*.docx", "*.doc", "*.xlsx", "*.xls", "*.ppt", "*.pptx",
  "node_modules", ".git", "__pycache__",
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

return {
  -- ===================================================================
  -- snack.picker
  -- ===================================================================
  -- 文件名搜索结果
  {
    "<leader>ff",
    function()
      require("snacks").picker.files({
        hidden = true,
        -- 用 fd 参数排除文件（比 Lua 过滤更高效）
        -- 如果系统没有 fd，snacks 会自动 fallback 到 rg 或 vim 内置
        args = FILE_ARGS,
      })
    end,
    desc = "Find Files",
  },
  { "<leader>fs", function() require("snacks").picker.smart() end, desc = "Find Smart" },
  { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Buffers" },
  { "<leader>fe", function() require("snacks").picker.recent() end, desc = "Recent Files" },

  -- 文件内容搜索结果
  {
    "<leader>fg",
    function()
      require("snacks").picker.grep({
        hidden = true,
        -- rg 的 glob 排除语法
        args = GREP_ARGS
      })
    end,
    desc = "Live Grep",
  },
  { "<leader>fw", function() require("snacks").picker.grep({ search = vim.fn.expand("<cword>") }) end, desc = "Grep Word Under Cursor" },
  { "<leader>f/", function() require("snacks").picker.grep({ buffers = { vim.api.nvim_get_current_buf() } }) end, desc = "Grep in Current Buffer" },
  { "<leader>fl", function() require("snacks").picker.lines() end, desc = "Search in Current Buffer" },

  -- LSP 相关文件列表
  { "<leader>fd", function() require("snacks").picker.lsp_definitions() end, desc = "LSP Definitions" },
  { "<leader>fr", function() require("snacks").picker.lsp_references() end, desc = "LSP References" },
  { "<leader>ft", function() require("snacks").picker.lsp_symbols() end, desc = "LSP Symbols" },

  -- 其他杂项
  { "<leader>fq", function() require("snacks").picker.qflist() end, desc = "Quickfix List" },
  { "<leader>fp", function() require("snacks").picker.registers() end, desc = "Register List" },

  { "<leader>fj", function() require("snacks").picker.resume() end, desc = "Resume Last Picker" },
  { "<leader>cc", function() require("snacks").picker.colorschemes() end, desc = "Colorschemes" },

  -- ===================================================================
  -- snack.explorer
  -- snack.picker.explorer() 也可以
  -- ===================================================================
  { "<leader>nn", function() require("snacks").explorer() end, desc = "Explorer Sidebar" },
  -- 在当前文件所在目录打开
  { "<leader>nc", function()
    require("snacks").explorer({ cwd = vim.fn.expand("%:p:h") })
    end, desc = "Explorer (Current File)"
  },

  -- ===================================================================
  -- 其他组件
  -- ===================================================================
  { "<leader>un", function() require("snacks").notifier.show_history() end, desc = "Notification History" },
  { "<leader>ub", function() require("snacks").scratch() end, desc = "Scratch Buffer" },
  { "<leader>bd", function() require("snacks").bufdelete() end, desc = "Delete Buffer" },
  { "<leader>gB", function() require("snacks").gitbrowse() end, desc = "Git Browse" },
  { "<leader>gg", function() require("snacks").lazygit() end, desc = "Lazygit" },
}

