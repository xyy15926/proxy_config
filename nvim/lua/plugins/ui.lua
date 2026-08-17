-- ============================================================
-- ui.lua — 界面插件
--   lualine     替代 lightline
--   alpha-nvim  替代 startify
--   rainbow
-- ============================================================

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

  -- -------------------- alpha-nvim（替代 startify）--------------------
  {
    "goolord/alpha-nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.startify")

      -- 顶部按钮
      dashboard.section.top_buttons.val = {
        dashboard.button("e", "  New File", "<cmd>ene<CR>"),
      }

      -- 书签（startify 主题没有默认的 bookmarks section，需要自建）
      local bookmarks = {
        type = "group",
        val = {
          { type = "text", val = "Bookmarks", opts = { hl = "SpecialComment", position = "center" } },
          { type = "padding", val = 1 },
          dashboard.button("p", "  ~/code/proxy",        "<cmd>cd ~/code/proxy<CR>"),
          dashboard.button("q", "  ~/code/pproxy",       "<cmd>cd ~/code/pproxy<CR>"),
          dashboard.button("c", "  ~/code/proxy_config", "<cmd>cd ~/code/proxy_config<CR>"),
          dashboard.button("r", "  ~/references/",       "<cmd>cd ~/references/<CR>"),
          dashboard.button("v", "  nvim config",         "<cmd>cd ~/.config/nvim<CR>"),
        },
      }

      -- 插入到 section 列表中（MRU 之后、sessions 之后）
      table.insert(dashboard.config.layout, 4, bookmarks)

      alpha.setup(dashboard.config)
    end,
  },

}
