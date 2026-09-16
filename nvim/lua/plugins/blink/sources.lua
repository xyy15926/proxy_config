-- ==========================================================================
-- File    : sources_providers.lua
-- Author  : xyy15926
-- Created : 2026-09-12 22:03:31
-- Updated : 2026-09-14 18:20:22
-- Desc    : Sources providers.
--
-- Ref:
-- - https://github.com/MahanRahmati/blink-nerdfont.nvim
-- - https://github.com/disrupted/blink-cmp-conventional-commits
-- - lazy/blink.cmp/doc/configuration/sources.md
-- - lazy/blink.cmp/doc/recipes.md#sources
-- ==========================================================================

return {
  -- 默认 { "lsp", "path", "snippets", "buffer" } 常量（可为函数）
  -- default = function(_ctx)
  --   local path = vim.bo.filetype == "lua" and "vimpath_lua" or "vimpath"
  --   -- vim.treesitter.get_node() 在当前位置为行末尾时可能返回 `chunk`
  --   -- 用于判断所需的节点类型不适合，当然也可以指定位置
  --   local success, node = pcall(vim.treesitter.get_node)
  --   if success and node then
  --     local ntype = node:type()
  --     if ntype:find("comment") or ntype:find("string")
  --     then
  --       return { "nerdfont", "buffer", path, "path" }
  --     end
  --   end
  --   return { "lsp", "snippets", "buffer", "nerdfont" }
  -- end,
  default = { "lsp", "snippets", "buffer", "nerdfont", "path" },
  per_filetype = {
    -- `inherit_defaults = true`：先继承 default
    gitcommit = { inherit_defaults = true, "conventional_commits" },
    markdown = { inherit_defaults = true, "vimpath" },
    lua = { inherit_defaults = true, "vimpath_lua" },
  },
  min_keyword_length = function()
    return vim.bo.filetype == "markdown" and 2 or 0
  end,
  providers = {
    lsp = {
      -- fallbacks 可以包含未添加 sources，但只有添加的才生效
      fallbacks = { "buffer", "vimpath", "vimpath_lua", "path" },
    },
    -- `path` 可配置相对路径的查找起始目录，默认是当前 buffer 目录
    path = {
      enabled = true,
      opts = {
        get_cwd = function(_)
          return vim.bo.filetype == "markdown" and vim.fn.expand("%:p:h")
            or vim.fn.getcwd()
        end,
        show_hidden_files_by_default = true,
      },
    },
    conventional_commits = {
      name = "Conventional Commits",
      module = "blink-cmp-conventional-commits",
      enabled = function()
        return vim.bo.filetype == "gitcommit"
      end,
    },
    nerdfont = {
      module = "blink-nerdfont",
      name = "Nerd Fonts",
      enabled = true,
      score_offset = 15,  -- Tune by preference
      opts = {
        insert = true,  -- Insert nerdfont icon (default) or complete its name
        trigger = ":?"  -- Customize the trigger. Defaults to ":"
      },
    },
    -- 自定义的实现都是实时查询目录，开销比较大，还是都关了吧 :-(
    -- 不过 blink.cmp 自身的 path 也是实时查询，不过是异步查询
    -- （这里的 `async = true` 只是指是否等待结果）
    -- ref: lazy/blink.cmp/lua/blink/cmp/sources/path/fs.lua
    vimpath = {
      name = "vimpath",
      module = "plugins.blink.vimpath",
      enabled = false,
      async = true,
      score_offset = 0,
      opts = {
        max_items = 200,
        find_path = {
          "",
          ".",
          vim.fn.expand("~/code/pproxy"),
        }
      },
      fallbacks = { "path" },
    },
    vimpath_lua = {
      name = "vimpath",
      module = "plugins.blink.vimpath",
      enabled = false,
      async = true,
      score_offset = 0,
      opts = {
        max_items = 200,
        find_path = {
          "",
          ".",
          vim.fn.stdpath("config"),
          vim.fn.stdpath("data"),
          vim.fn.expand("~/code/pproxy"),
        }
      },
      fallbacks = { "path" },
    },
  }
}
