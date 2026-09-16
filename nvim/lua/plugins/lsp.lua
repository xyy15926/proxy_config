-- ==========================================================================
-- File    : lsp.lua
-- Author  : xyy15926
-- Created : 2026-09-03 09:53:52
-- Updated : 2026-09-15 16:24:27
-- Desc    : nvim-lspconfig
--
-- --------------------------------------------------------------------------
-- vim.lsp：内置的 LSP client
-- 1. 协议层：实现 LSP 通信机制，负责与 LSP server 交换信息
-- 2. 核心API：`vim.lsp.start()`、`vim.lsp.buf.*`、`vim.lsp.diagnostic.*`
-- 3. 基础能力：跳转定义、引用查找、补全触发、诊断处理等
-- 4. 底层回调：`on_attach` 等各种回调、钩子暴露
--
-- --------------------------------------------------------------------------
-- LSP capabilities
-- 1. LSP 初始化阶段，client 和 server 需要互相告知支持的功能
-- 1.1 涉及文档同步、诊断、补全、文档、签名、跳转、代码操作、格式化、重命名等
-- 1.2 默认的，`vim.lsp.protocol.make_client_capabilities()` 即获取 vim.lsp
--   作为 client 的支持的功能
-- 2. 但是部分插件 `blink.cmp` 可以扩展 LSP client 的能力，则插件需要修改、
--   覆盖 `vim.lsp.protocol.make_client_capabilities()` 中能力声明
-- 2.1. 并作为 vim.lsp.config 参数，以告知 LSP server 支持的能力
-- 2.2. 似乎 Neovim 0.11 后插件都会主动通过 `vim.lsp.config` 注册能力
--
-- Ref:
-- - lazy/blink.cmp/plugin/blink-cmp.lua
--
-- --------------------------------------------------------------------------
-- Neovim 0.11 新增机制，逐渐吸收原 `nvim-lspconfig` 功能
-- 1. `vim.lsp.config`：LSP 服务类，其中存储各 LSP 服务配置
-- 1.1. `vim.lsp.<name>`、`vim.lsp[<name>]` 查看 LSP 服务配置
-- 1.2. `vim.lsp.config(name, cfg)` 配置 LSP 服务，不同来源配置参数在此合并
-- 1.3. 各 `runtimepath` 下 `lsp/<name>.lua` 中配置将自动被 `vim.lsp.config`
--   加载
-- 2. `vim.lsp.enable(name, eable)`：启用、禁用 LSP 服务
-- 2.1. `vim.lsp.enable` 中会注册针对 FileType 的自动命令，为对应类型
--   buffer 调用 `vim.lsp.start(config, opts)` 以 attach LSP
-- 2.2. 事实上，可以直接通过 `vim.lsp.start` 直接启动 LSP 服务器
--   vim.lsp.start({
--     name = "pyright",
--     cmd = { "pyright-langserver", "--stdio" },
--     root_dir = vim.fs.dirname(vim.fs.find({"pyproject.toml"}, { upward = true })[1]),
--   })
--
-- Ref:
-- - /usr/share/nvim/runtime/lua/vim/lsp.lua
--
-- --------------------------------------------------------------------------
-- nvim-lspconfig：预设多种 LSP 配置
-- 1. 预先配置了多种 LSP server 的 `vim.lsp.start` 调用参数
-- 1.1. `cmd`：每种服务器的启动命令
-- 1.2. `root_dir`：每种服务器该用什么文件作为项目根标记
--  （如 pyproject.toml、go.mod、Cargo.toml）
-- 1.3. `settings`：每种服务器接受哪些配置项
-- 1.4. 事实上，nvim-lspconfig 中各 LSP 服务的配置即位于 nvim-lspconfig/lsp 中
-- 2. 此外，还有公共默认配置 `lspconfig.util.default_config`
-- 2.1. 但公共默认配置似乎已经被 `vim.lsp.config` 默认配置替代？
--
-- Ref:
-- - lazy/nvim-lspconfig/lsp/basedpyright.lua
-- - lazy/nvim-lspconfig/lsp/lua_ls.lua
-- - lazy/nvim-lspconfig/lua/lspconfig/util.lua
-- ==========================================================================

return {
  {
  ------------------------ nvim-lspconfig ----------------------------------
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
    },
    config = function()
      vim.diagnostic.config(require("plugins.lsp.diagnostic"))
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = require("plugins.lsp.attached_keymaps")
      })
      -- 为所有服务器配置 blink.cmp 加强的 capabilities
      -- blink.cmp 中已配置
      -- vim.lsp.config("*", {
      --   capabilities = require("blink.cmp").get_lsp_capabilities(),
      -- })
    end,
  },
}
