-- =======================================================
-- snacks.dashboard config
-- =======================================================

local utils = require("_utils")

return {
  enabled = true,
  width = 60,           -- 内容总宽度
  row = nil,            -- 垂直居中（nil = 自动）
  col = nil,            -- 水平居中
  pane_gap = 16,        -- 双 pane 模式时的间距

  -- 预设：Header + 快捷按键
  preset = {
    -- 自定义 ASCII Header（可换成你自己的 Logo）
    header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
    ]],

    -- 快捷按键列表（按这里定义的顺序显示）
    keys = {
      { icon = " ", key = "f", desc = "Find File",       action = ":lua Snacks.dashboard.pick('files')" },
      { icon = " ", key = "t", desc = "Today",           action = ":edit" .. utils.today_note() },
      { icon = " ", key = "n", desc = "New File",        action = ":ene | startinsert" },
      { icon = " ", key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('recent')" },
      { icon = " ", key = "g", desc = "Find Text",       action = ":lua Snacks.dashboard.pick('grep')" },
      { icon = " ", key = "c", desc = "Config",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      { icon = " ", key = "s", desc = "Restore Session", section = "session" },
      { icon = "󰒲 ", key = "L", desc = "Lazy",            action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit",            action = ":qa" },
    },
  },

  -- 布局：从上到下依次排列
  sections = {
    -- 1. Header（ASCII Logo）
    { section = "header" },

    -- 2. 快捷按键（自动分配 1-9 等快捷键）
    { section = "keys", gap = 1, padding = 1 },

    -- 3. 最近文件（需要 snacks.picker）
    {
      icon = " ",
      title = "Recent Files",
      section = "recent_files",
      indent = 2,
      padding = 1,
      limit = 5,          -- 最多显示 5 条
    },

    -- 4. 项目列表（基于 git 根目录识别）
    {
      icon = " ",
      title = "Projects",
      section = "projects",
      indent = 2,
      padding = 1,
      limit = 5,
    },

    -- 5. 启动时间统计
    { section = "startup" },

    -- 6. 终端命令（可选：比如显示 fortune/cowsay）
    -- {
    --   section = "terminal",
    --   cmd = "fortune | cowsay",
    --   random = 10,       -- 每 10 秒刷新
    --   pane = 2,          -- 放在右侧 pane
    --   indent = 4,
    --   height = 10,
    -- },
  },
}
