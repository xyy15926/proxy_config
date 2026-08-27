-- ========================================================
-- snippets/lua.lua
--
-- 1. 采用声明式风格配置，或许适合被其他 Snippets 文件引用？
-- ========================================================

local utils = require("_utils")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local filename = function() return vim.fn.expand("%:t") end
local now      = function() return os.date("%Y-%m-%d %H:%M:%S") end
local author   = function() return os.getenv("USER") or "Author" end
local basename = function() return vim.fn.expand("%:t:r") end
local extname  = function() return vim.fn.expand("%:e") end

-- ls.add_snippets("lua",  {})     -- 命令式风格配置
return {                              -- 声明式风格配置
  -- 文件模板
  s("heading", {
    t({
      "-- ==========================================================================",
    }),
    t({ "", "-- File    : " }), f(filename),
    t({ "", "-- Author  : " }), i(1, utils.author or author()),
    t({ "", "-- Created : " }), f(now),
    t({ "", "-- Updated : " }), f(now),
    t({ "", "-- Desc    : " }), i(2, "TODO"),
    t({
      "",
      "-- ==========================================================================",
      "",
      "",
    }), i(0), -- Tab 跳转退出位置，可选
  }),

  s("localm", {
    t({
      "local M = {}",
      "",
      "M.defaults = {",
      "  ",
    }), i(1, "key"), t({" = "}), i(2, "\"\""),
    t({
      "",
      "}",
      "M.opts = vim.deepcopy(M.defaults)",
      "",
      "",
      "function M.setup(opts)",
      "  M.opts = vim.tbl_deep_extend(\"force\", M.opts, opts or {})",
      "",
    }), i(0),
    t({
      "",
      "end",
      "",
      "return M",
    }),
  }),

  s("mblock", {
    t({
      "-- ==========================================================================",
      "--  ",
    }), i(1, "Block Comment"),
    t({
      "",
      "-- ==========================================================================",
    }), i(0),
  }),

  -- 简写
  s("autocmd", {
    t({"vim.api.nvim_create_autocmd(\""}), i(1, "BufNewFile"), t({
      "\", {",
      "  group = vim.api.nvim_create_augroup(\"",
    }), i(2, basename()), t({ "\", { clear = true })," }),
    t({
      "",
      "  pattern = \""
    }), i(3, "*." .. extname()), t({
      "\",",
      "  callback = function(args)",
      "    local buf = args.buf",
      "",
    }), i(0),
    t({
      "",
      "  end,",
      "})",
    }),
  }),

  s("function", {
    t("function "), i(1, "foo"), t("("), i(2), t({
      ")",
      "",
    }), i(0),
    t({
      "",
      "end"
    }),
  }),

  s("ifend", {
    t("if "), i(1, "true"), t({
      " then",
      "  ",
    }), i(2), t({
      "",
      "end"
    }),
  }),

  s("ifelse", {
    t("if "), i(1, "true"), t({
      " then",
      "  ",
    }), i(2), t({
      "",
      "else",
      "  ",
    }), i(3), t({
      "",
      "end"
    }),
  }),

  s("while", {
    t("while "), i(1, "true"), t({
      " do",
      "",
    }), i(0),
    t({"", "end"})
  }),

  s("for", {
    t("for "), i(1, "i in 1,10"), t({
      " do",
      "",
    }), i(0),
    t({"", "end"})
  }),

  s("augroup", {
    t({ "group = vim.api.nvim_create_augroup(\"" }), i(1, basename()), t({ "\", { clear = true })" }),
  }),

  s("keymap", {
    t("vim.keymap.set("), i(1, "\"n\""), t(", "), i(2, "\"<leader>XX\""), t(", "), i(3, "\"<cmd><cr>\""),
    t(", { desc = \""), i(4, "desc"), t({ "\"})" }),
  }),
}
