-- ========================================================
-- snippets/markdown.lua
--
-- 1. 采用声明式风格配置，或许适合被其他 Snippets 文件引用？
-- ========================================================

local ls = require("luasnip")
local daily = require("users.daily_todo")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- local filename = function() return vim.fn.expand("%:t") end
local now      = function() return os.date("%Y-%m-%d %H:%M:%S") end
local author   = os.getenv("USER") or "Author"
local basename = function() return vim.fn.expand("%:t:r") end
local monday   = daily.get_week_date(nil, 1)

-- ls.add_snippets("markdown",  {})     -- 命令式风格配置
return {                              -- 声明式风格配置
  -- 文件模板
  s("heading", {
    t({ "---" }),
    t({ "", "title: " }), i(1, basename()),
    t({ "", "categories:", "  - "}), i(2, "cat1"),
    t({ "", "tags:", "  - "}), i(3, "tag1"),
    t({ "", "author: " }), i(4, author),
    t({ "", "date: " }), f(now),
    t({ "", "updated: " }), f(now),
    t({ "", "mathjax: true" }),
    t({ "", "toc: true" }),
    t({ "", "desc: " }), i(5, "TODO"),
    t({ "", "---", "", "##  "}),
    i(0),   -- Tab 跳转退出位置，可选
    t({ "", "", "", "", ""}),
  }),

  s("weekly", {
    t({
    "##  Lateral",
    "",
    "##  " .. os.date("%Y%m%d", monday + 5 * 86500) .. "、" .. os.date("%Y%m%d", monday + 6 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 4 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 3 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 2 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 1 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday),
    "",
    }), i(0),
  }),

  s("nweekly", {
    t({
    "##  Lateral",
    "",
    "##  " .. os.date("%Y%m%d", monday + 12 * 86500) .. "、" .. os.date("%Y%m%d", monday + 13 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 11 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 10 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 9 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 8 * 86500),
    "",
    "##  " .. os.date("%Y%m%d", monday + 7 * 86500),
    "",
    }), i(0),
  }),
}
