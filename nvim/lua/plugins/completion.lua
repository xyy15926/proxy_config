-- ============================================================
-- completion.lua
--   mason                  工具安装
--   mason-lspconfig        各语言 LSP 安装、配置
--   mason-tool-installer   Linter, Formatter 安装、配置
--   nvim-lspconfig         LSP 配置+ mason + nvim-cmp
--   nvim-cmp               补全
--   全面替代 YouCompleteMe
-- ============================================================

local utils = require("_utils")

return {

  -- -------------------- Mason（自动安装 LSP/DAP/Linter）--------------------
  -- 1. Mason 独立安装 LSP、Linter、Formater，即使系统已存在也将安装新副本至
  --   `datapath/mason/bin/` 目录下（目录被添加至 `PATH`）。
  -- 2. 其他 `nvim-lint`、`conform` 等工具仅通过 `PATH` 查找工具使用。
  -- 3. 即，`rust-analyzer`、`cargo` 等 LSP、Linter 总是随着 Rust 工具链自动
  --   安装的工具不要通过 Mason 管理。
  -- 4. 下述 `mason-tool-installer` 未启用，即需自行安装 ruff、mypy 等工具
  -- ------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "basedpyright",
          -- "clangd",
          "rust_analyzer",
        },
        automatic_installation = true,
      })
    end,
  },
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

  -- LSP 配置（用 vim.lsp.config，不再用 nvim-lspconfig 的 setup）
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 诊断外观
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        float = { border = "rounded", source = "if_many" },
        update_in_insert = false,
      })
      vim.fn.sign_define("DiagnosticSignError", { text = "🚫" })
      vim.fn.sign_define("DiagnosticSignWarn",  { text = "⚡" })
      vim.fn.sign_define("DiagnosticSignInfo",  { text = "ℹ" })
      vim.fn.sign_define("DiagnosticSignHint",  { text = "💡" })

      -- 通用 on_attach
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("i", "<C-l>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "rn", vim.lsp.buf.rename, opts)
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          vim.keymap.set("n", "<C-l>", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
          end, opts)
        end
      end

      -- 用 vim.lsp.config() 配置各服务器
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = {"basedpyright-langserver", "--stdio"},
        -- cmd = { "pixi", "run", "basedpyright-langserver", "--stdio" },
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
          python = {},
        },
        -- 指定解释器路径，否则须在目录根目录通过 `pyrightconfig.json` 指定
        -- 或者，如前述 `cmd` 配置，直接在 `pixi run` 启动 LSP 服务器
        on_init = function(client)
          -- local cwd = vim.fn.getcwd()
          -- local pixi_python = cwd .. "/.pixi/envs/default/bin/python"
          -- if vim.fn.filereadable(pixi_python) == 1 then
          local root = utils.find_project_root()
          if utils.has_pixi(root) then
            pixi_python = root .. "/.pixi/envs/default/bin/python"
            client.config.settings.python.pythonPath = pixi_python
            client:notify("workspace/didChangeConfiguration", {
              settings = client.config.settings,
            })
          end
        end,
      })

      vim.lsp.config("clangd", {
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
      })

      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            inlayHints = {
              parameterHints = { enable = true },
              typeHints = { enable = true },
              chainingHints = { enable = true },
            },
          },
        },
      })

      -- 启用所有已配置的 LSP 服务器
      vim.lsp.enable({ "lua_ls", "basedpyright", "clangd", "rust_analyzer" })
    end,
  },

  -- -------------------- nvim-cmp（替代 YCM 补全 UI）--------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = function(entry, vim_item)
            local source_names = {
              nvim_lsp = "[LSP]",
              luasnip  = "[Snip]",
              buffer   = "[Buf]",
              path     = "[Path]",
            }
            vim_item.menu = source_names[entry.source.name] or ""
            return vim_item
          end,
        },
      })
    end,
  },
}
