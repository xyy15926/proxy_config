-- ============================================================
-- ui.lua — 界面插件
--   lualine            底栏信息，替代 lightline
--   alpha-nvim         启动界面，替代 startify
--   rainbow            括号匹配
--   markview.nvim      MD 渲染插件
--   table-mode         MD 表格格式化
--   gitsigns           Git 文件状态
--
-- 1. Markview 渲染依赖符号，需要安装 NerdFont 字体，可以浏览
--   - https://www.nerdfonts.com/font-downloads
-- 2. 注意字体一定需要带有 NerdFont、NF，否则只是普通字体
-- 3. 可以考虑 JetBrain Nerd Font、FiraCode Nerd Font
-- ============================================================

local utils = require("_utils")

return {

  -- -------------------- rainbow --------------------
  { "frazrepo/vim-rainbow", event = "BufReadPost",
    config = function() vim.g.rainbow_active = 1 end },

  -- -------------------- lualine（替代 lightline）--------------------
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = {
            function()
              local ln = vim.fn.line(".")
              local lt = vim.fn.line("$")
              local cw = vim.fn.virtcol(".")
              local lw = vim.fn.strdisplaywidth(vim.fn.getline("."))
              return string.format("%d/%d : %d/%d", ln, lt, cw, lw)
            end,
          },
        },
      })
    end,
  },

  -- -------------------- markview.nvim（MD 渲染插件）--------------------
  -- 渲染效果、对齐、语法高亮优于 render-markdown
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("markview").setup({
        -- 在编辑器里直接渲染 Markdown（标题、代码块、表格等）
        enable_hybrid_mode = true,
        hybrid_modes = { "n" },  -- 在 Normal 模式启用 hybrid
        linewise_hybrid_mode = false,  -- true 则切换为行级模式
      })
    end,
  },

  -- -------------------- table-mode（保留）-------------------------------
  { "dhruvasagar/vim-table-mode", ft = { "markdown", "python" },
    config = function()
      vim.g.table_mode_auto_align = 1
      vim.g.table_mode_update_time = 100
      vim.g.table_mode_disable_mappings = 1
      vim.g.table_mode_disable_tableize_mappings = 1
      -- 必须显式手动解绑
      pcall(vim.keymap.del, "n", "<leader>tt")
      pcall(vim.keymap.del, "n", "<leader>tm")
    end
  },

  -- -------------------- gitsigns（Git 状态标签）------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "-" },
          topdelete    = { text = "-" },
          changedelete = { text = "~" },
          untracked    = { text = "│" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- 工厂函数帮忙补充 `desc`
          local function opts(desc)
            return { buffer = bufnr, silent = true, desc = desc }
          end

          -- 跳转 hunk
          vim.keymap.set("n", "]h", gs.next_hunk,     opts("Next Hunk"))
          vim.keymap.set("n", "[h", gs.prev_hunk,     opts("Prev Hunk"))

          -- 操作
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk,  opts("Preview Hunk"))
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk,    opts("Stage Hunk"))
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk,    opts("Reset Hunk"))
          vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, opts("Undo Stage Hunk"))
          vim.keymap.set("n", "<leader>hb", gs.blame_line,    opts("Blame Line"))
          vim.keymap.set("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts("Stage Hunk Line"))
          vim.keymap.set("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts("Reset Hunk Line"))
        end,
      })
    end,
  },
}
