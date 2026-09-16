-- ==========================================================================
-- File    : virtual_text.lua
-- Author  : xyy15926
-- Created : 2026-09-14 19:48:22
-- Updated : 2026-09-14 19:48:22
-- Desc    : DAP virtual text config.
-- ==========================================================================


return {
  "theHamsta/nvim-dap-virtual-text",
  lazy = true,
  enabled = true,
  opts = {
    enabled = true,
    enabled_commands = true,

    -- 高亮变更的变量值
    highlight_changed_variables = true,
    highlight_new_as_changed = false,

    -- 在什么位置显示虚拟文本
    show_stop_reason = true,

    -- 仅在当前帧显示
    only_first_definition = true,
    all_references = false,

    -- 过滤器
    filter_references_pattern = "<module>",

    -- 文本格式
    virt_text_pos = "eol",         -- 行末显示
    all_frames = false,            -- 仅当前帧
    virt_lines = false,            -- 不使用虚拟行
    virt_text_win_col = nil,       -- 自动计算位置
  },
}
