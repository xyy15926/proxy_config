-- ============================================================
-- navigation.lua
--   rooter         根目录定位，保留
--   telescope      文件导航，替代 LeaderF
-- ============================================================

local root_flags = require("_utils").root_flags

return {

  -- -------------------- vim-rooter（保留）--------------------
  {
    "airblade/vim-rooter",
    lazy = false,
    config = function()
      vim.g.rooter_targets = "/,*"
      vim.g.rooter_buftypes = { "" }
      vim.g.rooter_patterns = root_flags
      vim.g.rooter_change_directory_for_non_project_files = "current"
    end,
  },

  -- -------------------- telescope（替代 LeaderF）--------------------
  {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.8",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top", width = 0.9 },
          sorting_strategy = "ascending",
          file_ignore_patterns = {
            "%.pyc",
            "%.so",
            "%.o",
            "%.bin",
            "%.exe",
            "%.dll",
            "%.class",
            "%.jar",
            "%.png",
            "%.jpg",
            "%.pdf",
            "%.docx",
            "%.doc",
            "%.xlsx",
            "%.xls",
            "%.ppt",
            "%.pptx",
            "node_modules",
            "%.git/",
            "__pycache__",
          },

          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              -- Tab 退出 insert 模式进入 normal 模式
              ["<Tab>"] = function()
                vim.cmd("stopinsert")
              end,
            },
            n = {
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["q"] = actions.close,
              -- Enter 选中并回到 insert 模式（可选）
              ["<CR>"] = actions.select_default,
              -- i 或 a 回到 insert 模式（可选）
              ["i"] = function()
                vim.cmd("startinsert")
              end,
              ["t"] = actions.select_tab,
              ["v"] = actions.select_vertical,
              ["s"] = actions.select_horizontal,
            },
          },
        },

        pickers = {
          colorscheme = {
            enable_preview = true,
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },
}
