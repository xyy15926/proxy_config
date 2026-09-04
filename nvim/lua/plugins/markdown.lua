-- ==========================================================================
-- File    : markdown.lua
-- Author  : xyy15926
-- Created : 2026-08-27 18:37:15
-- Updated : 2026-09-04 08:39:23
-- Desc    : Plugins related to markdown.
--
-- Notions:
-- 1. Markview 渲染依赖符号，需要安装 NerdFont 字体，可以浏览
--   - https://www.nerdfonts.com/font-downloads
-- 2. 注意字体一定需要带有 NerdFont、NF，否则只是普通字体
-- 3. 可以考虑 JetBrain Nerd Font、FiraCode Nerd Font
-- ==========================================================================

local md_fts = { "markdown", "codecompanion" }

return {
  -- -------------------- render-markdown（MD 渲染插件）---------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    -- ft = md_fts,
    enabled = false,
    opts = {
      -- 指定启用的 filetype，未指定时会读取 Lazyvim spec 中 `ft` 字段
      -- 可参考 `stdpath("data")/nvim/lazy/render-markdown/lua/init.lua`
      file_types = md_fts,
      render_modes = { "n", "c", "t" },
      heading = {
        sign = false,
        position = "inline",
        width = "block",
        left_pad = 1,
        right_pad = 1,
        icons = { "󰲠  ", "󰲢  ", "󰲤  ", "󰲦  ", "󰲨  ", "󰲪  " },
      },
      code = {
        sign = false,
        language_icon = true,
        language_name = false,
        left_pad = 2,
        right_pad = 2,
        border = "thin",
        style = "full",
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰄵 ", scope_highlight = "@markup.strikethrough" },
        custom = {
          todo = { raw = "[-]", rendered = "󰅐 ", highlight = "RenderMarkdownTodo" },
        },
      },
      pipe_table = {
        style = "full",
        cell = "padded",
        border = { "┌", "┬", "┐", "├", "┼", "┤", "└", "┴", "┘", "│", "─" },
      },
      link = { hyperlink = "" },
      sign = { enabled = false },
      latex = { enabled = false },
      overrides = {
        buftype = {
          nofile = {
            code = { border = "hide", style = "normal", left_pad = 0, right_pad = 0 },
            heading = { icons = { "", "", "", "", "", "" } },
          },
        },
      },
    },
    keys = {
      { "<leader>ru", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render" },
    },
  },

  ------------------ markview.nvim（MD 渲染插件）------------------------
  -- 渲染效果、对齐、语法高亮优于 render-markdown
  {
    "OXY2DEV/markview.nvim",
    -- ft = md_fts,
    enabled = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>rv", "<cmd>Markview Toggle<cr>", buffer = true, desc = "Render Markdown" },
    },
    config = function()
      require("markview").setup({
        -- 在编辑器里直接渲染 Markdown（标题、代码块、表格等）
        enable_hybrid_mode = true,
        hybrid_modes = { "n" },  -- 在 Normal 模式启用 hybrid
        linewise_hybrid_mode = false,  -- true 则切换为行级模式
        -- 控制插件是否对缓冲区真正启用
        preview = {
          -- filetypes = { "markdown", "quarto", "rmd", "typst", "codecompanion" },
          filetypes = md_fts,
          ignore_buftypes = {},
          -- 接受 buffer 作为参数的回调函数，控制插件是否对缓冲区启用
          condition = nil,
        },
      })
    end,
  },

  -- -------------------- table-mode（表格模式）------------------------------
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "python" },
    keys = {
      -- 1. `:XXX<cr>`：真实模拟按键 `:XXX`、执行，兼容 visual 模式下按下
      --   `:` 后自动触发跟随 `:`<,`>`
      -- 2. `<cmd>XXX<cr>`：直接执行命令，没有 `:` 自动触发机制
      { "<leader>st", ":Tableize/;<cr>", mode = "x", desc = "Tableize" },
      { "<leader>st", "<cmd>TableModeToggle<cr>", desc = "Table Mode" },
    },
    config = function()
      vim.g.table_mode_auto_align = 1
      vim.g.table_mode_update_time = 100
      vim.g.table_mode_disable_mappings = 1
      vim.g.table_mode_disable_tableize_mappings = 1
      -- 必须显式手动解绑
      pcall(vim.keymap.del, "n", "<leader>tt")
      pcall(vim.keymap.del, "n", "<leader>tm")
      vim.api.nvim_create_autocmd("InsertEnter", {
        group = vim.api.nvim_create_augroup("DisableTableMode", { clear = true }),
        pattern = "*.md",
        callback = function()
          if vim.fn.hlexists("Table") > 0 then
            vim.cmd("TableModeDisable")
          end
        end,
      })
    end
  },
}
