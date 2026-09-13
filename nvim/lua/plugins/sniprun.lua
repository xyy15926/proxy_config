-- ==========================================================================
-- File    : sniprun.lua
-- Author  : xyy15926
-- Created : 2026-09-06 21:24:46
-- Updated : 2026-09-13 13:50:49
-- Desc    : Config for sniprun.
--
-- Ref:
-- - lazy/sniprun/doc/sources/README.md
--
-- TODO:
-- 1. 兼容 `>>>`, `$` 等代码前导符，注意：markdown 文档中 sniprun 会载入整个
--   代码块
-- ==========================================================================

--- Extract, run the inspect the result of the expression.
--- @param whole boolean?
local function sniprun_expr(whole)
  local line = vim.api.nvim_get_current_line()
  if vim.bo.filetype == "lua" then
    if not whole then
      line = line:gsub("^.*%s*=%s*", ""):gsub("%s*,?%s*%-%-.*$", ""):gsub("%s*,%s*$", "")
    end
    vim.notify(
      "Expression: " .. line .. ", will be run and inspected",
      vim.log.levels.TRACE
    )
    require("sniprun.api").run_string(
      "print(vim.inspect(" .. line .. "))",
      {
        -- 禁用 VirtualText，行号会乱跳
        display = {
          "Api",          -- 自定义函数输出
          "Classic",      -- 命令行输出结果
        },
      }
    )
  end
end


-- %% =======================================================================
return {
  "michaelb/sniprun",
  -- 需要从 github 下载，记得修改代理
  build = "bash install.sh",
  lazy = true,
  enabled = true,
  cmd = { "SnipRun", "SnipInfo" },
  keys = {
    { "<leader>rr", ":SnipRun<cr>", mode = { "n", "v" }, desc = "Snip: Run", silent = true },
    { "<leader>rE", function() sniprun_expr(true) end, mode = "n", desc = "Snip: Inspect(whole line)" },
    { "<leader>re", sniprun_expr, mode = "n", desc = "Snip: Inspect" },
    { "<leader>rm", "<Plug>SnipRunOperator", mode = "n", desc = "Snip: Run Range" },
    { "<leader>rq", "<cmd>SnipClose<cr>", mode = "n", desc = "Snip: Clear Extmark" },
    { "<leader>rQ", "<cmd>SnipReplMemoryClean<cr>", mode = "n", desc = "Snip: Clear Memory" },
    { "<leader>rC", "<cmd>SnipReset<cr>", mode = "n", desc = "Snip: Reset" },
    { "<leader>rL", "<cmd>SnipLive<cr>", mode = "n", desc = "Snip: Toggle Live" },
  },
  opts = {
    -- use those instead of the default for the current filetype
    selected_interpreters = {
      "Lua_nvim",
    },
    -- 为解释器启用 REPL-like behavior：变量可跨次保留
    -- 启用 REPL 模式后，对 Markdown 中某些类型（Python）代码块
    -- 1. 若当前行执行中代码块中变量未定义，则前序代码会被执行直至变量被定义
    -- 2. 但，前序输出被抑制
    repl_enable = {
      -- 直接在当前 noevim 环境中执行，直接影响当前配置
      "Lua_nvim",
      -- 需 klepto 包支持管理 REPL 状态
      "Python3_original",
    },
    repl_disable = {},
    interpreter_options = {
      Python3_original = {
        interpreter = "python3",
        -- 常用的额外库，sniprun 启动时自动导入
        default_imports = {
          "import os",
          "import sys",
          "import json",
          "import math",
          "from collections import *",
          "from itertools import *",
        },
      },
    },
    -- 输出显示方式
    display = {
      -- 如果同时设置 `VirtualTextOk`、`VirtualTextOk`，则 `VirtualTextOk` 将被清除
      "VirtualText",  -- 虚拟文本输出
      "Api",          -- 自定义函数输出
      "Classic",      -- 命令行输出结果
    },
    live_mode_toggle = "off",
    -- live mode 输出显示方式
    live_display = {
      "VirtualText",  -- 虚拟文本输出
      "Api",          -- 自定义函数输出
      "Classic",      -- 命令行输出结果
    },
    display_options = {
      notification_timeout = 5,
    },
    snipruncolors = {
      SniprunVirtualTextOk   =  {bg="#98C379", fg="#000000", ctermbg="Cyan", ctermfg="Black"},
      SniprunFloatingWinOk   =  {fg="#98C379", ctermfg="Cyan"},
      SniprunVirtualTextErr  =  {bg="#E06C75", fg="#000000", ctermbg="DarkRed", ctermfg="Black"},
      SniprunFloatingWinErr  =  {fg="#E06C75", ctermfg="DarkRed", bold=true},
    },
  },
  config = function(_, opts)
    require("sniprun").setup(opts)
    require("sniprun.api").register_listener(function (d)
      vim.notify(
        d.message,
        d.status == "ok" and vim.log.levels.INFO
        or vim.log.levels.WARN
      )
    end)
  end,
}
