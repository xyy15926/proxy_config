-- ============================================================
-- editing.lua
--   nvim-lint          替代 ALE lint
--   conform            替代 ALE fix
-- ============================================================

return {

  -- -------------------- nvim-lint（替代 ALE lint）--------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    keys = {
      { "<leader>ss", function() require("lint").try_lint() end, desc = "Lint" },
    },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff", "mypy" },
        c      = { "clang" },
        cpp    = { "clang" },
        rust   = { "cargo" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- -------------------- conform.nvim（替代 ALE fix）--------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      { "<leader>sf", function() require("conform").format({ async = true }) end, desc = "Format" },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format", "black" },
          c      = { "clang-format" },
          cpp    = { "clang-format" },
          rust   = { "rustfmt" },
          lua    = { "stylua" },
        },
        format_on_save = false,
      })
    end,
  },

  -- -------------------- template.nvim（文件模板）--------------------
  -- {
  --   "glepnir/template.nvim",
  --   event = "BufNewFile",
  --   config = function()
  --     require("template").setup({
  --       -- 模板目录
  --       temp_dir = vim.fn.expand("~/.config/nvim/templates/"),
  --       -- 作者
  --       author = "xyy15926",
  --       -- 日期格式
  --       date_format = "%Y-%m-%d %H:%M:%S",
  --     })
  --   end,
  -- },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",  -- 推荐 v2 稳定版
    build = "make install_jsregexp",  -- 可选：支持正则变换
    -- dependencies = { "rafamadriz/friendly-snippets" },  -- 可选，VSCode JSON 风格预设 Snippnet
    opts = {
      enable_autosnippets = false,      -- 禁止自动插入
      store_selection_keys = "<C-q>",   -- 可视模式下存取文本快捷键，后续可用于填充 snippet
    },
    keys = {
      { "<C-j>", function() require("luasnip").jump(1) end, desc = "Next Node", mode = { "i", "s" }, silent = true },
      { "<C-k>", function() require("luasnip").jump(-1) end, desc = "Prev Node", mode = { "i", "s" }, silent = true },
      -- { "<C-l>", function() require("luasnip").change_choice(1) end, desc = "Next Snip", mode = { "i", "s" }, silent = true },
    },
    config = function()
      local ls = require("luasnip")
      ls.setup({
        history = false,              -- 允许在事件检查后删除 snippets，否则永远可以跳转
        updateevents = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged,InsertLeave",  -- 事件触发时，检查 snippets 外内容是否变动，变动则删除 snippet
        -- region_check_events = "InsertEnter",              -- 事件触发时，**检查光标**，若光标离开 snippet 区域则不活跃
        enable_autosnippets = true,   -- 启用自动触发（比如输入 `date` 自动展开）
      })
      -- require("luasnip.loaders.from_vscode").lazy_load() -- 加载 friendly-snippets 的 vscode 格式片段
      -- 1. `lazy_load` 将根据文件类型加载对应类型文件：可搭配命令式、或声明式配置
      -- 2. `load` 将加载目录下所有文件：此时不应搭配声明式配置，否则所有配置对所有文件均生效
      require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/lua/snippets/" })
    end,
  }
}
