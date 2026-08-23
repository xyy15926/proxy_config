-- ===================================================
-- Common Snippets
-- ===================================================

local ls = require("luasnip")
local s = ls.snippet            -- 触发关键词
local t = ls.text_node          -- 固定文本
local f = ls.function_node      -- 动态内容

ls.add_snippets("all", {
  s("date",     { f(function() return os.date("%Y-%m-%d") end) }),
  s("datetime", { f(function() return os.date("%Y-%m-%d %H:%M:%S") end) }),
  s("time",     { f(function() return os.date("%H:%M") end) }),
  s("filename", { f(function() return vim.fn.expand("%:t") end) }),
  s("filepath", { f(function() return vim.fn.expand("%:p") end) }),
})
