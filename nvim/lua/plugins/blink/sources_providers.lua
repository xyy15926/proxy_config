-- ==========================================================================
-- File    : sources_providers.lua
-- Author  : xyy15926
-- Created : 2026-09-12 22:03:31
-- Updated : 2026-09-12 22:03:31
-- Desc    : Sources providers.
--
-- Ref:
-- - https://github.com/MahanRahmati/blink-nerdfont.nvim
-- - https://github.com/disrupted/blink-cmp-conventional-commits
-- ==========================================================================

return {
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
  -- 自定义的实现都是实时查询目录，开销比较大
  -- 不过 blink.cmp 自身的 path 也是实时查询，不过是异步查询
  -- ref: lazy/blink.cmp/lua/blink/cmp/sources/path/fs.lua
  vimpath = {
    name = "vimpath",
    module = "plugins.blink.vimpath",
    enabled = true,
    score_offset = 0,
    opts = {
      max_items = 200,
      find_path = {
        "",
        ".",
        vim.fn.expand("~/code/pproxy"),
      }
    },
    fallback = { "path" },
  },
  vimpath_lua = {
    name = "vimpath",
    module = "plugins.blink.vimpath",
    enabled = true,
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
    fallback = { "path" },
  },
}
