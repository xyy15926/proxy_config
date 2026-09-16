-- ==========================================================================
-- File    : mason.lua
-- Author  : xyy15926
-- Created : 2026-09-14 22:00:14
-- Updated : 2026-09-16 08:48:27
-- Desc    : Mason and mason-plugins.
--
-- --------------------------------------------------------------------------
-- Mason 核心定位就是包管理器：
-- 1. 负责安装、更新和管理 Neovim 生态里的外部工具
-- 1.1. LSP servers（如 lua-language-server, pyright, tsserver）
-- 1.2. DAP servers（调试适配器）
-- 1.3. Linters（如 eslint, ruff）
-- 1.4. Formatters（如 prettier, stylua）
-- 2. 否则，需要手动通过 npm, pip, cargo 等多种语言的包管理器分别安装、更新、
--   并管理安装路径。
-- 3. `:MasonInstall <some-bin>` 可以直接安装，并将二进制文件统一放在
--   `require("mason.settings").current.install_root_dir` 下，方便其他 Mason
--   相关工具使用
-- 3.1. Mason 会将 `install_root_dir` 添加到 neovim 的 PATH 中
--   （仅在 neovim 进程内）
-- 4. 但注意，Mason 是独立安装的、全局二进制
-- 4.1. 对 mypy 这种依赖虚拟环境的工具，使用 Mason 安装无法直接访问虚拟环境
--   依赖，可能无法直接使用
-- 4.2. 特别的，debugpy 类似的调试工具可能
-- 4.2.1. 还需要加载针对特定 Python 版本编译的 .so C 扩展文件，Python 版本
--   不一致可能导致加载出错
-- 4.3. 对 `rust-analyzer`、`cargo` 等 LSP、Linter 总是随着 Rust 工具链自动
--   安装的，也无需通过 Mason 管理
-- 4.4. 但，通过 Mason 安装、管理一套独立的 LSP、DAP、Linter、Formater
--   作为兜底似乎也有价值？
--
-- --------------------------------------------------------------------------
-- mason-lspconfig：mason 与 vim.lsp 桥接
-- 1. 名称映射：Mason 和 lspconfig 对不同工具名称可能不同，mason-lspconfig
--   维护有一套映射表，可直接使用 lspconfig 中名称
-- 1.1 如 lspconfig 中 rust_analyzer 对应 Mason 中 rust-analyzer
-- 2. `ensure_installed` 自动调用 `MasonInstall` 安装
-- 3. `automatic_enable` 自动调用 `vim.lsp.enable()` 启用 LSP
-- 3.1. 遍历已安装 LSP server，调用 `vim.lsp.enable()`
-- 3.2. 在 `vim.lsp.enable` 会注册针对 FileType 的自动命令，为对应类型
--   buffer 调用 `vim.lsp.start(config)`
-- 3.3. `config` 即已经注册的 LSP 配置（`nvim-lspconfig` 包含预置配置）
-- 4. LSP 配置中 `cmd`, `before_init` 设置
-- 4.1. mason-lspconfig 中 LSP 配置数量很少，基本只涉及 `cmd`、`before_init`
-- 4.2. 通过 `vim.lsp.config` 加载配置，且仅在 `automatic_setup` 置位时加载
--
-- Ref:
-- - lazy/mason-lspconfig.nvim/lua/mason-lspconfig/settings.lua
-- - lazy/mason-lspconfig.nvim/lua/mason-lspconfig/features/automatic_enable.lua
-- - /usr/share/nvim/runtime/lua/vim/lsp.lua
--
-- --------------------------------------------------------------------------
-- mason-nvim-dap：Mason 和 nvim-dap 桥接
-- 1. 名称映射：维护 filetype 和对应的 DAP server 实现的映射关系
-- 2. `ensure_installed` 通过 Mason 自动安装、管理 DAP adapter
-- 3. `opts.handlers` 中钩子函数拦截、修改 DAP 配置
-- 3.1. `adapters` DAP 适配器：mason-nvim-dap 有默认配置，主要包含 DAP server
--   的启动命令、参数
-- 3.2. `configurations` debug 项配置：mason-nvim-dap 有少量场景的默认配置，
--   但 debug 场景较多，除文件 debug 外还有特定框架，需要自行配置
-- 4. 为此，对应 nvim-lspconfig 存在 nvim-dap-python 等 DAP 配置集合
-- 4.1. 但，nvim-lspconfig 是对多种 filetype 的集合，而 nvim-dap-python 等
--   一般是针对特定 filetype(DAP server) 的多种 debug 项目的集合
-- 4.2. 且，mason-nvim-dap 中 adapters, configurations 基本够用，而
--   nvim-dap-python 也没有针对复杂场景的适配，其实用处不大
--
-- Ref: 
-- - lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/settings.lua
-- - lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/init.lua
-- - lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/filetypes.lua
-- - lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/adapters/python.lua
-- - lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/configurations.lua
--
-- --------------------------------------------------------------------------
-- LSP 与 DAP 都是 MS 为 VScode 设计的协议
--        client     server                  mason              settings-collections
-- LSP    vim.lsp    pyright, basedpyright   mason-lspconfig    nvim-lspconfig
-- DAP    nvim-dap   debugpy                 mason-nvim-dap     mason-nvim-dap, nvim-dap-python
--
-- 1. 不过，vim.lsp 是 neovim 内置模块，并且在逐步吸收 nvim-lspconfig 能力
--
-- --------------------------------------------------------------------------
-- mason-tool-installer：Linter, Formatter 安装管理
-- ==========================================================================

return {
  -- -------------------- Mason（自动安装 LSP/DAP/Linter）--------------------
  {
    "williamboman/mason.nvim",
    enable = true,
    lazy = true,
    cmd = { "Mason" },
    opts = {
      install_root_dir = vim.fn.stdpath("data") .. "/mason",
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enable = true,
    lazy = true,
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        -- "clangd",
        "rust_analyzer",
      },
      automatic_enable = true,
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    enable = true,
    lazy = true,
    -- dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    -- mason-nvim-dap 其实不依赖 nvim-dap，handlers 中钩子函数应该是延迟执行的
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "python",       -- debugpy
        "codelldb",     -- c, c++, rust, swift, zig
      },
      automatic_installation = true,
      handlers = {
        -- 默认 handler：对所有未单独指定 adapter 生效
        -- 参数 config：mason-nvim-dap 为各语言设置的默认 DAP 配置
        -- 主要即修改 `config.adapters`、`config.configurations`
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
        python = function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    },
  }
  -- {
  --   "WhoIsSethDaniel/mason-tool-installer.nvim",
  --   dependencies = { "williamboman/mason.nvim" },
  --   config = function()
  --     require("mason-tool-installer").setup({
  --       ensure_installed = {
  --         -- Linter
  --         "ruff",
  --         "mypy",
  --         -- Formatter
  --         "stylua",
  --       },
  --     })
  --   end,
  -- },
}
