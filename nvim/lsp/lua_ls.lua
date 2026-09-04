-- ==========================================================================
-- File    : lsp/lua_ls.lua
-- Author  : xyy15927
-- Created : 2026-09-03 09:44:53
-- Updated : 2026-09-04 11:53:44
-- Desc    : Config for lua lspconfig client, lua_ls.
--
-- PS:
-- - 可用 `:lua =vim.lsp.config.lua_ls` 查看 lua_ls 配置，确认合并后配置
--   或 `:lua =vim.lsp.get_clients()[1].config` 查看生效的 lsp 配置
-- ==========================================================================

return {
  -- capabilities = require("cmp_nvim_lsp").default_capabilities(),
  -- `root_markers` 在 `lsp/lua_ls.lua` 中设置无效，无法覆盖默认值
  -- 可能仅在在 `after/lsp/lua_ls.lua` 才可生效
  -- root_markers = require("users.rooter").opts.root_flags,
  -- 但，`root_dir` 设置有效
  root_dir = function(bufnr, on_dir)
    local root_flags = require("users.rooter").opts.root_flags
    local root = vim.fs.root(bufnr, root_flags) or vim.fn.getcwd()
    on_dir(root)
  end,
  -- 静态配置，LSP 启动时直接发送给 LSP 服务器
  settings = {
    Lua = {
      -- 指定 LSP 分析代码时工作空间范围
      -- 字段：library, checkThirdParty, ignoreDir, maxPreload,
      --   preloadFileSize, useGitIgnore
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { globals = { "vim" } },
    },
  },
  -- 在服务器初始化时动态注入
  on_init = function(client)
    local path = client.workspace_folders[1].name

    -- 如果项目已有 `.luarc.json`，尊重项目本地配置，不覆盖
    -- 即，非 Neovim 配置项目直接返回
    if vim.uv.fs_stat(vim.fs.joinpath(path, ".luarc.json"))
       or vim.uv.fs_stat(vim.fs.joinpath(path, ".luarc.jsonc")) then
      return
    end

    -- 针对 Neovim lua 的专属设置
    local nvim_settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = vim.split(package.path, ";"),
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            vim.fn.stdpath("config"),
          },
        },
        telemetry = { enable = false },
      },
    }

    -- 修改默认设置
    client.config.settings.Lua = vim.tbl_deep_extend(
      "force",
      client.config.settings.Lua or {},
      nvim_settings.Lua
    )
  end,
}
