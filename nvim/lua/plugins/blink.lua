-- ==========================================================================
-- File    : blink.lua
-- Author  : xyy15926
-- Created : 2026-09-12 13:24:08
-- Updated : 2026-09-14 19:14:22
-- Desc    : Blink configs.
-- ==========================================================================

return {
  {
    "saghen/blink.cmp",
    version = "1.*",                      -- blink.cmp 的 2.* 版本问题太多了，包括：accept 后光标位置都有问题、实时插入预览文本
    dependencies = {
      "L3MON4D3/LuaSnip",                 -- LusSnip 可选支持，替代内置 `mini.snippets`
      "disrupted/blink-cmp-conventional-commits",
      "MahanRahmati/blink-nerdfont.nvim",
    },
    opts = {
      keymap = {
        preset = "default",               -- 按键预设："super-tab" | "enter" | "default"
        ["<C-n>"] = {
          "show",                         -- 默认 <C-Space> 会被终端吞，将 show 拆给 <C-n>
          "select_next",
        },
        ["<C-h>"] = {
          "show_documentation",           -- 将 toggle-doc 拆给 <C-h>
          "hide_documentation",
          "show_signature",
          "hide_signature",
        },
        ["<C-k>"] = false,                -- 将 <C-k> 从 toggle-sign 解绑，还给 Snipnets 的 next-node
        ["<Tab>"] = false,                -- 将 <Tab> 从 snip-forward 解绑
      },
      appearance = {
        nerd_font_variant = "mono",       -- 图标样式："mono" 或 "normal"
      },
      snippets = {
        preset = "luasnip",               -- 用 LuaSnip 而不是内置的 mini.snippets
      },
      -- 补全来源
      sources = require("plugins.blink.sources"),
      completion = {                      -- 补全菜单行为
        list = {
          selection = {
            preselect = true,
            auto_insert = false,          -- 不实时插入预览文本
          },
        },
        documentation = {
          auto_show = true,               -- 自动显示文档
          auto_show_delay_ms = 500,
        },
        menu = {                          -- 菜单样式
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
        ghost_text = { enabled = false }, -- 选中即接受（ghost text）
      },
      signature = {                       -- 函数签名（参数）提示，默认 `<c-k>` toggle
        enabled = true,
      },
      fuzzy = {
        implementation = "rust",          -- 使用 Rust 预编译二进制做匹配，`lua` 则使用 Lua 脚本
      },
    },
    -- 1. lazy.nvim 在合并多个插件 spec 的 opts 时，默认使用 `vim.tbl_deep_extend("force", ...)` 覆盖，
    --    对于普通 table 合理，但对于数组/列表结果将不符合预期
    -- 2. `opts_extend` 即指定前序 `opts.sources.default` 应使用追加而不是覆盖
    -- opts_extend = { "sources.default" },
  }
}
