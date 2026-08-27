-- ============================================================
-- completion.lua
--   nvim-cmp               补全
-- ============================================================

return {
  -- -------------------- nvim-cmp（替代 YCM 补全 UI）--------------------
  -- {
  --   "hrsh7th/nvim-cmp",
  --   event = "InsertEnter",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "L3MON4D3/LuaSnip",
  --     "saadparwaiz1/cmp_luasnip",
  --   },
  --   config = function()
  --     local cmp = require("cmp")
  --     local luasnip = require("luasnip")
  --
  --     cmp.setup({
  --       snippet = {
  --         expand = function(args) luasnip.lsp_expand(args.body) end,
  --       },
  --       mapping = cmp.mapping.preset.insert({
  --         ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
  --         ["<C-f>"]     = cmp.mapping.scroll_docs(4),
  --         ["<C-Space>"] = cmp.mapping.complete(),
  --         ["<C-e>"]     = cmp.mapping.abort(),
  --         ["<CR>"]      = cmp.mapping.confirm({ select = true }),
  --         ["<Tab>"]     = cmp.mapping(function(fallback)
  --           if cmp.visible() then cmp.select_next_item()
  --           elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
  --           else fallback() end
  --         end, { "i", "s" }),
  --         ["<S-Tab>"]   = cmp.mapping(function(fallback)
  --           if cmp.visible() then cmp.select_prev_item()
  --           elseif luasnip.jumpable(-1) then luasnip.jump(-1)
  --           else fallback() end
  --         end, { "i", "s" }),
  --       }),
  --       sources = cmp.config.sources({
  --         { name = "nvim_lsp" },
  --         { name = "luasnip" },
  --       }, {
  --         { name = "buffer" },
  --         { name = "path" },
  --       }),
  --       window = {
  --         completion = cmp.config.window.bordered(),
  --         documentation = cmp.config.window.bordered(),
  --       },
  --       formatting = {
  --         format = function(entry, vim_item)
  --           local source_names = {
  --             nvim_lsp = "[LSP]",
  --             luasnip  = "[Snip]",
  --             buffer   = "[Buf]",
  --             path     = "[Path]",
  --           }
  --           vim_item.menu = source_names[entry.source.name] or ""
  --           return vim_item
  --         end,
  --       },
  --     })
  --   end,
  -- },

  {
    'saghen/blink.cmp',
    version = "1.*",                      -- blink.cmp 的 2.* 版本问题太多了，甚至连 accept 后光标位置都有问题
    dependencies = {
      "L3MON4D3/LuaSnip",                 -- LusSnip 可选支持，替代内置 `mini.snippets`
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
      sources = {                         -- 补全来源，默认已包含 lsp、path、buffer、snippets，可省略
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {                      -- 补全菜单行为
        list = {
          selection = {
            preselect = true,
            auto_insert = true,           -- 不实时插入预览文本，有 bug
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
        ghost_text = { enabled = true },  -- 选中即接受（ghost text）
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
    opts_extend = { "sources.default" },
  }
}
