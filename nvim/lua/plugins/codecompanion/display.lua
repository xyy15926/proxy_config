-- ==========================================================================
-- File    : display.lua
-- Author  : xyy15926
-- Created : 2026-09-01 21:51:42
-- Updated : 2026-09-04 10:00:36
-- Desc    : Display config.
-- ==========================================================================

return {
  chat = {
    intro_message = "Welcome to CodeCompanion ✨✨✨! Press ? for options",
    show_context = true,
    fold_context = false,     -- 不折叠 Context
    fold_reasoning = true,
    show_reasoning = true,
    -- show_settings = true,  -- chat buffer 顶部展示相关配置，置位时无法切换模型
    show_token_count = true,
    start_in_insert_mode = false,
    auto_scroll = true,       -- 自动滚动到底部
    seprator = "=",  -- 对话分隔符
    show_header_separator = false,  -- header 分隔线，有 MD 渲染插件可复位

    -- chat 对话窗口
    window = {
      buflisted = false,  -- 展示在 buffer list 中
      sticky = false,  -- 切换 tabpage 时保持出现
      pretab = false,  -- tabpage 拥有独立 chat 窗口

      layout = "vertical",    -- 垂直分屏（右侧栏）
      full_height = true,
      position = "right",
      width = 0.4,           -- 窗口宽度占屏幕比例
      height = 0,  -- 自动高度

      border = "single",
      relative = "editor",

      -- chat buffer 的 neovim options
      opts = {
        breakindent = true,
        linebreak = true,
        wrap = true,
        number = true,
        relativenumber = false,
        signcolumn = "no",
      },
    },
    -- 浮动窗口，包括帮助窗口等
    floating_window = {
      ---@return number|fun(): number
      width = function()
        return vim.o.columns - 40
      end,
      ---@return number|fun(): number
      height = function()
        return vim.o.lines - 20
      end,
      -- row = "center",
      -- col = "center",
      relative = "editor",
      opts = {
        wrap = false,
        number = false,
        relativenumber = false,
      },
    },
    icons = {
      sync_all = "󰪴 ",
      sync_diff = " ",
      chat_context = " ",
      chat_fold = " ",
      tool_pending = "  ",
      tool_in_progress = "  ",
      tool_failure = "  ",
      tool_success = "  ",
    },
  },
  -- Action palette：buffer、prompts、插件特点入口
  action_palette = {
    width = 30,
    height = 10,
    prompt = "Prompt ",
    provider = "default",
    opts = {
      show_preset_actions = true,
      show_preset_prompts = true,
      title = "CodeCompanion Actions",
    },
  },
  -- Code Review 下 diff 配置 #TODO
  diff = {
    enabled = true,
    thresh_for_chat = 6,
    window = {
      opts = {},
    },
    word_highlights = {
      additions = true,
      deletions = true,
    },
  },
}
