-- ==========================================================================
-- File    : sniprun.lua
-- Author  : xyy15926
-- Created : 2026-09-06 21:24:46
-- Updated : 2026-09-08 12:03:44
-- Desc    : Config for sniprun.
--
-- TODO:
-- 1. 兼容 `>>>`, `$` 等代码前导符，注意：markdown 文档中 sniprun 会载入整个
--   代码块
-- ==========================================================================

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
    { "<leader>rm", "<Plug>SnipRunOperator", mode = "n", desc = "Snip: Run Range", silent = true },
    { "<leader>rq", "<cmd>SnipClose<cr>", mode = "n", desc = "Snip: Clear Extmark", silent = true },
    { "<leader>rC", "<cmd>SnipReplMemoryClean<cr>", mode = "n", desc = "Snip: Clear Memory", silent = true },
    { "<leader>rL", "<cmd>SnipLive<cr>", mode = "n", desc = "Snip: Toggle Live", silent = true },
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
    require('sniprun.api').register_listener(function (d)
      if d.status ~= "ok" then
        vim.notify(d.status .. ": " .. d.message)
      end
    end)
  end,
}
