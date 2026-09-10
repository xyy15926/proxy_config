-- ==========================================================================
-- File    : lsp.lua
-- Author  : xyy15926
-- Created : 2026-09-03 09:53:52
-- Updated : 2026-09-10 16:14:39
-- Desc    : nvim-lspconfig
-- ==========================================================================

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
  },
  config = function()
    -- 诊断外观
    vim.diagnostic.config({
      virtual_text = { prefix = "●" },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "🚫",
          [vim.diagnostic.severity.WARN]  = "⚡",
          [vim.diagnostic.severity.INFO]  = "ℹ",
          [vim.diagnostic.severity.HINT]  = "💡",
        },
      },
      float = {
        border = "rounded",
        source = "if_many",
        -- 可通过 `=vim.diagnostic.get(0, lnum={vim.fn.line(".") - 1})` 查看
        -- 当前行 diagnostic 表信息，即以下函数参数
        format = function(diagnostic)
          return string.format("[%s] %s",
            diagnostic.source or "?",
            diagnostic.message
          )
        end,
      },
      update_in_insert = false,
    })

    -- 统一的 LspAttach 键位（比 on_attach 更可靠）
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(args)
        local bufnr = args.buf

        -- 工厂函数帮忙补充 `desc`
        local function opts(desc)
          return { buffer = bufnr, silent = true, desc = desc }
        end

        -- =============================================================
        -- nvim 0.11+ 在 LSP attach 时的默认键位，可不配置
        -- 跳转
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Goto Definition"))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Goto Declaration"))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Goto Implementation"))
        -- vim.keymap.set("n", "]d", function() vim.diagnostic.jump( { count = 1 }) end, opts("Next Diagnostic"))
        -- vim.keymap.set("n", "[d", function() vim.diagnostic.jump( { count = -1 }) end, opts("Prev Diagnostic"))
        -- 信息
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover"))
        pcall(vim.keymap.del, "n", "K", { buffer = bufnr })
        -- 操作
        vim.keymap.set("n", "grr", vim.lsp.buf.references, opts("References"))
        vim.keymap.set("n", "gra", vim.lsp.buf.code_action, opts("Code Action"))
        vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts("Rename"))
        -- 跳转
        -- =============================================================

        -- 跳转
        vim.keymap.set("n", "<leader>jr", function() vim.diagnostic.jump( { count = -1 }) end, opts("Prev Diagnostic"))
        vim.keymap.set("n", "<leader>jf", function() vim.diagnostic.jump( { count = 1 }) end, opts("Next Diagnostic"))
        vim.keymap.set("n", "gy",   vim.lsp.buf.type_definition, opts("Goto Type Definition"))
        -- vim.keymap.set("n", "gg", function()
        --   vim.cmd("tab split")
        --   vim.lsp.buf.definition()
        -- end, opts("Goto Definition (Tab)"))
        vim.keymap.set("n", "gv", function()
          vim.cmd("rightbelow vsplit")
          vim.lsp.buf.definition()
        end, opts("Goto Definition (Vsplit)"))
        -- vim.keymap.set("n", "gn", function() vim.diagnostic.jump({ count = 1 }) end, opts("Next Diagnostic"))
        -- vim.keymap.set("n", "gp", function() vim.diagnostic.jump({ count = -1 }) end, opts("Prev Diagnostic"))
        vim.keymap.set("n", "gf", vim.diagnostic.open_float, opts("Open Diagnostic"))
        vim.keymap.set("n", "gq", vim.diagnostic.setqflist, opts("Diagnostic SetQFix"))

        -- 信息
        -- `vim.lsp.buf.signature_help` 包含 doc 且无法 toggle
        vim.keymap.set("i", "<C-l>", vim.lsp.buf.signature_help, opts("Signature Help"))
        vim.keymap.set("n", "<leader>hh", vim.lsp.buf.hover, opts("Hover"))
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          vim.keymap.set("n", "<leader>hk", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
          end, opts("Toggle Inlay Hints" ))
        end

      end,
    })
    -- =================================================================
    -- `vim.lsp.config`、`vim.lsp.enable` 是 neovim 0.11 的新增机制
    --
    -- 1. `vim.lsp.config(<lang_server>, ...)` 为语言 lang 配置 LSP
    -- 2. `vim.lsp.enable(<lang_server>)` 为语言 lang 启用 LSP 后，neovim 会
    --    自动将 `vim.lsp.config`、各 `runtimepath` 下 `lsp/<lang_server>.lua`
    --    合并
    -- 3. 各语言 `vim.lsp.config` 配置已被分散至对应 lua 文件中，同时已配置
    --   `mason-lspconfig` 自动为相应语言调用 `vim.lsp.enable` 启用 LSP
    -- =================================================================
    local lspconfig = require('lspconfig')
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    -- local capabilities = require("cmp_nvim_lsp").default_capabilities(),
    lspconfig.util.default_config = vim.tbl_deep_extend(
      'force',
      lspconfig.util.default_config,
      {
        -- 一次性设置默认 capabilities，后续所有 LSP server 自动继承
        capabilities = capabilities,
        -- 但设置 `root_markers`、`root_dir` 无效，只能在各 <lang_server>.lua
        -- 中分别设置
        -- root_markers = require("users.rooter").opts.root_flags,
        -- root_dir = function(bufnr, on_dir)
        --   local root_flags = require("users.rooter").opts.root_flags
        --   local root = vim.fs.root(bufnr, root_flags)
        --   on_dir(root)
        -- end,
      }
    )

  end,
}

