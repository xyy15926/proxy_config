-- =======================================================
-- snacks.dashboard config
-- =======================================================

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
      { icon = " ", key = "n", desc = "New File",        action = ":ene | startinsert" },
      { icon = " ", key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('recent')" },
      { icon = " ", key = "g", desc = "Find Text",       action = ":lua Snacks.dashboard.pick('grep')" },
      { icon = " ", key = "c", desc = "Config",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      -- 手动调用 `filetype detect` 触发类型检测，不知道为什么这里 `edit` 不自动触发
      { icon = " ", key = "t", desc = "Today",           action = ":edit " .. require("users.daily_todo").weekly_todo(nil, 0) .. " | filetype detect"},
      { icon = " ", key = "a", desc = "AI Chat",         action = ":CodeCompanionChat" },
      { icon = " ", key = "d", desc = "Diffview",        action = ":DiffviewOpen" },
      { icon = " ", key = "s", desc = "Restore Session", section = "session" },
      { icon = "󰒲 ", key = "L", desc = "Lazy",            action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit",            action = ":qa" },
    },
  },

  sections = {
    -- 右侧 `pane = 2` 展示 header、随机 ascii arts、启动时间统计
    { pane = 2,
      { section = "header" },
      function()
        local arts = require("ascii").get_random_global()
        -- 左侧内容高度 - 内容高度 - neovim 高度
        local pad = 33 - #arts - 12
        return {
          -- Random ascii arts.
          text = table.concat(arts, "\n"),
          align = "center",
          padding = math.max(pad, 1),
        }
      end,
      -- 启动时间统计
      { section = "startup" },
    },

    -- 左侧 `pane = 1` 展示快捷键、最近文件、项目列表
    {
      pane = 1,
      -- function()
      --   local win_h = vim.o.lines - 1
      --   local content_h = 31
      --   return { text = string.rep("1\n", (win_h - content_h) / 2) }
      -- end,
      { section = "keys", gap = 1, padding = 1 },
      {
        icon = " ",
        title = "Recent Files",
        -- 最近文件：自动分配 1-9 等快捷键
        section = "recent_files",
        indent = 2,
        padding = 1,
        limit = 5,          -- 最多显示 5 条
      },
      {
        icon = " ",
        title = "Projects",
        section = "projects",
        indent = 2,
        padding = 1,
        limit = 5,
      },
    },

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
