-- ==========================================================================
-- File    : dap.lua
-- Author  : xyy15926
-- Created : 2026-09-14 18:41:06
-- Updated : 2026-09-17 22:18:45
-- Desc    : Nvim-dap configs.
--
-- Ref:
-- - lazy/nvim-dap/README.md
-- - lazy/nvim-dap/lua/dap.lua
-- ==========================================================================

return {
  {
    ----------------------- debug adapter protocol --------------------------
    "mfussenegger/nvim-dap",
    lazy = true,
    enabled = true,
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      { "theHamsta/nvim-dap-virtual-text" },
      { "jay-babu/mason-nvim-dap.nvim" },
    },
    -- 避免过多触发按键
    keys = {
      {
        "<leader>dC",
        function()
          local dap = require("dap")
          if vim.bo.filetype == "python" then
            dap.configurations.python = require("plugins.dap.python").get_configurations(nil, true)
          end
          dap.continue()
        end,
        desc = "Debug: Update&Start"
      },
      { "<leader>db",  function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      -- { "<leader>do",  function() require("dap").step_over() end,         desc = "Debug: Step Over" },
      -- { "<leader>di",  function() require("dap").step_into() end,         desc = "Debug: Step Into" },
      -- { "<leader>dO",  function() require("dap").step_out() end,          desc = "Debug: Step Out" },
      -- { "<leader>dB",  function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional Breakpoint" },
      -- { "<leader>dl",  function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Debug: Log Point" },
      -- { "<leader>dr",  function() require("dap").repl.open() end,         desc = "Debug: Open REPL" },
      -- { "<leader>dt",  function() require("dap").terminate() end,         desc = "Debug: Terminate" },
      -- { "<leader>du",  function() require("dapui").toggle() end,          desc = "Debug: Toggle UI" },
      -- { "<leader>dp",  function() require("dap").run_last() end,          desc = "Debug: Run Last" },
      -- { "<leader>dK",  function() require("dap.ui.widgets").hover() end,  desc = "Debug: Hover Variable", mode = { "n", "v" } },
      -- { "<leader>df",  function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames) end, desc = "Debug: Frames" },
      -- { "<leader>ds",  function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes) end,  desc = "Debug: Scopes" },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      local widgets = require("dap.ui.widgets")

      -- `dap.continue()` 在没有会话时会默认启动，此处禁止
      vim.keymap.set("n", "<leader>dc", function() if dap.session() then dap.continue() end end, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Debug: Conditional BP" })
      vim.keymap.set("n", "<leader>dl", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, { desc = "Debug: Log Point" })
      vim.keymap.set("n", "<leader>dn", dap.step_over,                  { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>di", dap.step_into,                  { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>do", dap.step_out,                   { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>dr", dap.run_to_cursor,              { desc = "Debug: Run to Cursor" })
      vim.keymap.set("n", "<leader>dq", dap.terminate,                  { desc = "Debug: Terminate" })
      vim.keymap.set("n", "<leader>dk", dap.repl.open,                  { desc = "Debug: REPL" })
      vim.keymap.set("n", "<leader>dp", dap.run_last,                   { desc = "Debug: Run Last Task" })
      vim.keymap.set("n", "<leader>df", function() widgets.centered_float(widgets.frames) end, {desc = "Debug: Frames" })
      vim.keymap.set("n", "<leader>ds", function() widgets.centered_float(widgets.scopes) end, {desc = "Debug: Scopes" })
      vim.keymap.set({ "n", "v" }, "<leader>dh", function() widgets.hover() end, { desc = "Debug: Hover Variable" })

      -- ============================================================
      -- 符号定义（断点等图标）、对应高亮组
      -- ============================================================
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DapLogPoint",            linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "⊘", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })

      vim.api.nvim_set_hl(0, "DapBreakpoint",          { fg = "#e06c75", bg = "" })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b", bg = "" })
      vim.api.nvim_set_hl(0, "DapLogPoint",            { fg = "#61afef", bg = "" })
      vim.api.nvim_set_hl(0, "DapStopped",             { fg = "#98c379", bg = "" })
      vim.api.nvim_set_hl(0, "DapStoppedLine",         { bg = "#2d3720" })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected",  { fg = "#5c6370", bg = "" })

      -- ============================================================
      -- 自动打开/关闭 UI
      -- ============================================================
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- ============================================================
      -- adapters, configurations 配置
      -- ============================================================
      dap.adapters.python = require("plugins.dap.python").adapters
      dap.configurations.python = require("plugins.dap.python").configurations
    end,
  },
  require("plugins.dap.ui"),
  require("plugins.dap.virtual_text"),
}
