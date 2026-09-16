-- ==========================================================================
-- File    : ui.lua
-- Author  : xyy15926
-- Created : 2026-09-14 19:43:58
-- Updated : 2026-09-14 19:43:58
-- Desc    : nvim-dap UI configs.
-- ==========================================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dap-float",
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close!<cr>", { buffer = event.buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close!<cr>", { buffer = event.buf, silent = true })
  end,
})

return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "nvim-neotest/nvim-nio" },
  lazy = true,
  enabled = true,
  opts = {
    layouts = {
      {
        elements = {
          { id = "scopes",  size = 0.35 },
          { id = "breakpoints", size = 0.15 },
          { id = "stacks",  size = 0.25 },
          { id = "watches", size = 0.25 },
        },
        size = 0.30,     -- 占屏幕宽度的 30%
        position = "right",
      },
      {
        elements = {
          { id = "repl",    size = 0.55 },
          { id = "console", size = 0.45 },
        },
        size = 0.25,     -- 占屏幕高度的 25%
        position = "bottom",
      },
    },
    -- 浮动窗口设置
    floating = {
      max_height = 0.85,
      max_width = 0.85,
      border = "rounded",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    -- 控制窗口如何渲染元素
    render = {
      max_type_length = nil,    -- 不截断类型名
      max_value_lines = 100,    -- 最多显示 100 行
      indent = 1,
    },
    -- 自动展开变量
    expand_lines = true,
  },
}
