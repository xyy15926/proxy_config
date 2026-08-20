-- ==================================================
-- snacks
-- ==================================================

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- 简单模块
    bigfile = { enabled = true },       -- 大文件性能优化，禁用 treesitter、语法高亮
    indent = { enabled = true },        -- 缩进线、范围高亮
    input = { enabled = true },         -- 美化 vim.ui.input
    notifier = { enabled = false },     -- 通知系统，替代 nvim-notify
    scope = { enabled = true },         -- 范围高亮，高亮当前函数、代码块
    quickfile = { enabled = false },    -- 快速打开文件，自动打开上次编辑位置
    words = { enabled = true },         -- 单词高亮跳转，类似跨文件 `*`
    scratch = { enabled = true },       -- 临时缓冲区、草稿版
    gitbrowse = { enabled = true },     -- 浏览器中打开当前代码对应的 Github 链接
    lazygit = { enabled = true },       -- 集成 lazygit（Git TUI 客户端）
    bufdelete = { enabled = true },     -- 安全删除缓冲区，保留窗口布局
    exploer = { enabled = true },       -- 文件浏览器（其中 input 搜索硬编码为依赖 fd，而 picker.files 会按 fd、fdfind、rg、find 以此尝试）

    -- 复杂模块引用独立文件
    dashboard = require("plugins.snacks.dashboard"),
    picker = require("plugins.snacks.picker"),
  },
  keys = require("plugins.snacks.keys"),
}
