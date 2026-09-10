-- ==========================================================================
-- File    : markdown.lua
-- Author  : xyy15926
-- Created : 2026-08-27 18:37:15
-- Updated : 2026-09-08 18:31:52
-- Desc    : Plugins related to markdown.
--
-- Notions:
-- 1. Markview 渲染依赖符号，需要安装 NerdFont 字体，可以浏览
--   - https://www.nerdfonts.com/font-downloads
-- 2. 注意字体一定需要带有 NerdFont、NF，否则只是普通字体，
--   可以考虑 JetBrain Nerd Font、FiraCode Nerd Font
--
-- Notions:
-- 1. Nerd Font 是开发者社区对 unicode 码元中 \uE000-\uF8FF 私有区间的定制，
--   只有开发者常用的 Nerd Font 字体可以正常渲染，实际渲染为单色矢量图
-- 2. 而 Emoji 是国际标准彩色符号，位于 \u1F000-\1FFFF 区间
--
-- Notions:
-- 1. snacker.picker.preview 写死自动 `pcall` 尝试加载 markview 和
--   render-markdown，只要 picker 预览到 `.md` 文件就会加载
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
    lazy = true,
    keys = {
      { "<leader>ru", "<cmd>RenderMarkdown toggle<cr>", desc = "Render Markdown2" },
    },
    opts = {
      enabled = false,
      -- 指定启用的 filetype，未指定时会读取 Lazyvim spec 中 `ft` 字段
      -- 可参考 `stdpath("data")/nvim/lazy/render-markdown/lua/init.lua`
      file_types = md_fts,
      render_modes = { "n", "c", "t" },
      anti_conceal = {
        enabled = false,  -- 整体关闭反隐藏（光标所在行保持渲染）
        ignore = {
          code = true,
        },
      },
      heading = {
        sign = false,
        position = "inline",
        width = "block",
        left_pad = 1,
        right_pad = 1,
        -- icons = { "󰬺  ", "󰬻  ", "󰬼  ", "󰬽  ", "󰬾  ", "󰬿  " },
        icons = { "󰉫  ", "󰉬  ", "󰉭  ", "󰉮  ", "󰉯  ", "󰉰  " },
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
        unchecked = { icon = " " },
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
  },

  ------------------ markview.nvim（MD 渲染插件）------------------------
  -- 渲染效果、对齐、语法高亮优于 render-markdown
  {
    "OXY2DEV/markview.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = md_fts,
    enabled = true,
    -- 延迟加载会出很多问题，似乎整个 `opts` 都不生效
    lazy = false,
    keys = {
      { "<leader>rv", "<cmd>Markview Toggle<cr>", desc = "Render Markdown" },
    },
    opts = {
      -- Ref
      -- - lazy/markview.nvim/markview.nvim.wiki/Configuration.md
      -- - lazy/markview.nvim/markview.nvim.wiki/Preview.md
      -- - https://github.com/OXY2DEV/markview.nvim/wiki/Preview
      preview = {
        enable = false,  -- 默认不启用
        map_gx = false,  -- 禁用内置的 `gx` 映射，逻辑完全无用

        -- 控制插件是否对缓冲区真正启用
        -- filetypes = { "markdown", "quarto", "rmd", "typst", "codecompanion" },
        filetypes = md_fts,
        ignore_buftypes = { "nofile" },

        -- hybrid_modes：渲染、plain txt 共存模式
        enable_hybrid_mode = false,  -- 默认不启用
        hybrid_modes = { "n" },  -- 在 Normal 模式启用 hybrid
        linewise_hybrid_mode = false,  -- true 则切换为行级模式

        max_buf_lines = 100,
      },
      markdown = {},
    },
  },

  -- -------------------- table-mode（表格模式）------------------------------
  {
    "dhruvasagar/vim-table-mode",
    -- ft = { "markdown", "python" },
    cmd = { "Tableize", "TableModeToggle" },
    keys = {
      -- 1. `:XXX<cr>`：真实模拟按键 `:XXX`、执行，兼容 visual 模式下按下
      --   `:` 后自动触发跟随 `:`<,`>`
      -- 2. `<cmd>XXX<cr>`：直接执行命令，没有 `:` 自动触发机制
      { "<leader>st", ":Tableize/;<cr>", mode = "x", desc = "Tableize;" },
      { "<leader>st", "<cmd>TableModeToggle<cr>", desc = "Table Mode" },
      { "<leader>sT", "<Plug>(table-mode-tableize-delimiter)", desc = "Tableize" },
    },
    config = function()
      vim.g.table_mode_auto_align = 1
      vim.g.table_mode_update_time = 100
      vim.g.table_mode_disable_mappings = 1
      vim.g.table_mode_disable_tableize_mappings = 1
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      -- 必须显式手动解绑
      pcall(vim.keymap.del, "n", "<leader>tt")
      pcall(vim.keymap.del, "n", "<leader>tm")
      pcall(vim.keymap.del, "v", "<leader>T")
      -- 进入插入模式自动禁用 TableMode
      -- vim.api.nvim_create_autocmd("InsertEnter", {
      --   group = vim.api.nvim_create_augroup("DisableTableMode", { clear = true }),
      --   pattern = "*.md",
      --   callback = function()
      --     -- 未激活过 TableMode 前高亮组不存在，直接 `TableModeDisable` 会报错
      --     if vim.fn.hlexists("Table") > 0 then
      --       vim.cmd("TableModeDisable")
      --     end
      --   end,
      -- })
    end
  },
}
