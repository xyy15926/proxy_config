-- ==========================================================================
-- File    : ui.lua
-- Author  : xyy15926
-- Created : 2026-08-27 19:46:23
-- Updated : 2026-09-08 22:14:48
-- Desc    : Plugins to provide more information while prettify the UI.
-- ==========================================================================

return {
  ------------------ rainbow-delimiters（括号颜色配对）-----------------------
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- 需要 treesitter 支持
    },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      require("rainbow-delimiters.setup").setup({
        -- 策略：global 表示全局高亮，local 表示只高亮当前可见区域
        strategy = {
          [""] = rainbow_delimiters.strategy["global"], -- 默认全局
          vim = rainbow_delimiters.strategy["local"],   -- vim 文件用局部策略
          -- 你也可以对某些文件类型禁用
          -- html = rainbow_delimiters.strategy["noop"],
        },

        -- 查询模式：决定匹配哪些分隔符
        query = {
          [""] = "rainbow-delimiters",           -- 默认：括号、标签等
          lua = "rainbow-blocks",                -- lua 额外支持 do/end, if/end 等块
          sh = "rainbow-blocks",
          javascript = "rainbow-delimiters-react", -- JSX/TSX 支持 React 标签
          tsx = "rainbow-delimiters-react",
          jsx = "rainbow-delimiters-react",
        },

        -- 高亮优先级，避免被其他高亮覆盖
        priority = {
          [""] = 200,
          lua = 210,
        },

        -- 高亮组名称（默认 7 个颜色循环）
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },

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

  -- %%------------------------- ascii arts ---------------------------------
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    enabled = true,
    keys = {
      { "<leader>up", function() require("ascii").preview() end, desc = "Preview Ascii Arts" },
    },
  },
}
