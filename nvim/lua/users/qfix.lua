-- ==========================================================================
-- File    : qfix.lua
-- Author  : xyy15926
-- Created : 2026-09-19 20:59:20
-- Updated : 2026-09-19 20:59:20
-- Desc    : Config about quickfix.
-- ==========================================================================

local M = {}

M.defaults = { }
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  Quickfix toggle
-- ==========================================================================
local function toggle_quickfix()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      qf_exists = true
    end
  end
  if qf_exists then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- 新 tabpage 打开 quickfix 项
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
      -- <C-W> — 进入窗口操作前缀
      -- <CR> — 在 quickfix 窗口的上下文中，等价于按回车，即打开当前行对应的文件条目
      -- <C-W> — 又是窗口操作前缀
      -- T — 大写 T，Vim 的内置命令：把当前窗口拆出来，放到一个全新的 tab 里
      vim.keymap.set("n", "t", "<C-W><CR><C-W>T", { buffer = true, desc = "tabnew-open" })
    end,
  })
  vim.keymap.set("n", "<leader>wq", toggle_quickfix, { desc = "Toggle Qfix" })
end

return M
