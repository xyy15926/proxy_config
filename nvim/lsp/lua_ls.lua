-- ==========================================================================
-- File    : lsp/lua_ls.lua
-- Author  : xyy15927
-- Created : 2026-09-03 09:44:53
-- Updated : 2026-09-16 11:10:20
-- Desc    : Config for lua lspconfig client, lua_ls.
--
-- Ref:
-- - lazy/nvim-lspconfig/lsp/lua_ls.lua 中默认值？
-- --------------------------------------------------------------------------
-- Lua_ls Notions:
--
-- 1. `workspace.library`（和 `root_dir`）共同构成索引空间
-- 1.1. 注意：`workspace.library` 中项目、`root_dir` 不会解析最终路径，对
--   软连接目录将直接使用，则真实目录、软连接目录同时存在将被重复搜索，且
--   结果被视为独立、不同结果，可能导致返回重复结果
-- 1.2. 同样类似 Neovim 中 `runtimepath` option，前述的目录项中 `lua` 子目录
--   会自动被作为 `require` 搜索起点（似乎还有 `meta`、`source` 之类的路径）
--
-- 2. `runtime.path` 控制 `require()` 的解析规则，是 **路径模式**
-- 2.1. 默认值为 `{"?.lua", "?/init.lua"}`，其中 `?` 将被替换为 `require` 中
--   目标模块
-- 2.2. 即对 `require("foo.bar")` 尝试在上述 `workspace.library`、`root_dir`
--   中各项中使用 `foo/bar.lua`、`foo/bar/init.lua` 查找、匹配
--
-- 3. 特别的，`workspace.library`、`root_dir` 中尾随 `lua`，与 `runtime.path`
--   中前导 `lua` 是可以共存的，即二者同时设置尾随（前导） `lua`、或二者同时
--   不设置、或二者之一设置均可行
-- 3.1 但，应是分别独立考虑，不可在其中之一设置多个 `lua/lua/`
--
-- 4. 注意，lua_ls 是基于语法分析，形如 `require("foo.bar")` 有定义、可定位，
--   不代表 `nvim_create_namespace("foo.bar")` 可定位
--
-- --------------------------------------------------------------------------
-- Neovim Notions:
-- 1. 可用 `:lua =vim.lsp.config.lua_ls` 查看 lua_ls 配置，确认合并后配置
--   或 `:lua =vim.lsp.get_clients()[1].config` 查看生效的 lsp 配置
-- 2. `:lua local params = vim.lsp.util.make_position_params(0, 'utf-16'); vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result) print(vim.inspect(result)) end)`
--   可用于查找 `vim.lsp.buf.definition()` 时 LSP 服务器返回结果
-- 3. 配置修改后，可直接 `:LspRestart` 重启以加载配置
-- ==========================================================================

return {
  -- capabilities = require("cmp_nvim_lsp").default_capabilities(),
  -- 1. `root_markers` 在 `lsp/lua_ls.lua` 中设置无效，无法覆盖
  --   lazy/nvim-lspconfig/lsp/lua_ls.lua 中默认值？
  --   可能需在 `after/lsp/lua_ls.lua` 才可生效
  -- 2. 但 nvim-lspconfig 中无 `root_dir` 配置，`root_dir` 设置有效
  -- root_markers = require("users.rooter").opts.root_flags,
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
      workspace = {
        checkThirdParty = false,
        maxPreload = 1000,
        preloadFileSize = 10000,
      },
      telemetry = { enable = false },
      diagnostics = {
        globals = { },
        unusedLocalExclude = { "_*" },  -- 以 `_` 开头变量不报警，`unusedLocalExclude` 对函数无效，也没有对应函数版本
        disable = { "unused-function" },  -- 配合禁用 `unused-function`，则若函数名未 `_` 开头则报 `unused-local`
        severity = {  -- 以下为默认取值
          ["unused-function"] = "Hint",
          ["unused-local"]    = "Hint",
        },
      },
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
          -- path = vim.split(package.path, ";"),
          path = { "?.lua", "?/init.lua" },
        },
        diagnostics = {
          globals = { "vim" },  -- 将 `vim` 视为全局变量
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            -- `~/.config/nvim`：为当前项目符号链接，若不使用
            -- `vim.uv.fs_realpath` 解析真实路径，同一目录将被添加两次，
            --  并导致 `vim.lsp.buf.definition()` 会返回两条记录
            vim.uv.fs_realpath(vim.fn.stdpath("config")),
            vim.fn.stdpath("data") .. "/lazy/blink.cmp/lua",
            vim.fn.stdpath("data") .. "/lazy/snacks.nvim/lua",
            vim.fn.stdpath("data") .. "/lazy/codecompanion.nvim/lua",
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
