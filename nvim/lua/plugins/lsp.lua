-- ============================================================
-- lsp.lua
--   nvim-lspconfig         LSP 配置
-- ============================================================

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
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
      float = { border = "rounded", source = "if_many" },
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
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump( { count = 1 }) end, opts("Next Diagnostic"))
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump( { count = -1 }) end, opts("Prev Diagnostic"))
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
        vim.keymap.set("n", "gy",   vim.lsp.buf.type_definition, opts("Goto Type Definition"))
        -- vim.keymap.set("n", "gg", function()
        --   vim.cmd("tab split")
        --   vim.lsp.buf.definition()
        -- end, opts("Goto Definition (Tab)"))
        vim.keymap.set("n", "gv", function()
          vim.cmd("rightbelow vsplit")
          vim.lsp.buf.definition()
        end, opts("Goto Definition (Vsplit)"))
        vim.keymap.set("n", "gn", function() vim.diagnostic.jump({ count = 1 }) end, opts("Next Diagnostic"))
        vim.keymap.set("n", "gp", function() vim.diagnostic.jump({ count = -1 }) end, opts("Prev Diagnostic"))
        vim.keymap.set("n", "gf", vim.diagnostic.open_float, opts("Open Diagnostic"))

        -- 信息
        vim.keymap.set("i", "<C-l>", vim.lsp.buf.signature_help, opts("Toggle Signature Help"))
        vim.keymap.set("n", "<leader>sk",   vim.lsp.buf.hover, opts("Hover"))
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          vim.keymap.set("n", "<leader>sh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
          end, opts("Toggle Inlay Hints" ))
        end

      end,
    })

    -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
    -- local utils = require("_utils")
    -- local lspconfig = require("lspconfig")

    -- 下述由 `mason-lspconfig` 自动加载 `nvim/lsp` 目录下文件自动配置替代
    -- vim.lsp.config("lua_ls",{
    --   capabilities = capabilities,
    --   settings = {
    --     Lua = {
    --       workspace = { checkThirdParty = false },
    --       telemetry = { enable = false },
    --       diagnostics = { globals = { "vim" } },
    --     },
    --   },
    -- })
    --
    -- vim.lsp.config("basedpyright",{
    --   capabilities = capabilities,
    --   cmd = {"basedpyright-langserver", "--stdio"},
    --   -- cmd = { "pixi", "run", "basedpyright-langserver", "--stdio" },
    --   settings = {
    --     basedpyright = {
    --       analysis = {
    --         typeCheckingMode = "basic",
    --         autoSearchPaths = true,
    --         useLibraryCodeForTypes = true,
    --       },
    --     },
    --     python = {},
    --   },
    --   -- 指定解释器路径，否则须在目录根目录通过 `pyrightconfig.json` 指定
    --   -- 或者，如前述 `cmd` 配置，直接在 `pixi run` 启动 LSP 服务器
    --   on_init = function(client)
    --     -- local cwd = vim.fn.getcwd()
    --     -- local pixi_python = cwd .. "/.pixi/envs/default/bin/python"
    --     -- if vim.fn.filereadable(pixi_python) == 1 then
    --     local root = utils.find_project_root()
    --     if utils.has_pixi(root) then
    --       local pixi_python = root .. "/.pixi/envs/default/bin/python"
    --       client.config.settings.python.pythonPath = pixi_python
    --       client:notify("workspace/didChangeConfiguration", {
    --         settings = client.config.settings,
    --       })
    --     end
    --   end,
    -- })
    --
    -- vim.lsp.config("clangd",{
    --   capabilities = capabilities,
    --   cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
    -- })
    --
    -- vim.lsp.config("rust_analyzer",{
    --   capabilities = capabilities,
    --   settings = {
    --     ["rust-analyzer"] = {
    --       checkOnSave = { command = "clippy" },
    --       inlayHints = {
    --         parameterHints = { enable = true },
    --         typeHints = { enable = true },
    --         chainingHints = { enable = true },
    --       },
    --     },
    --   },
    -- })
  end,
}

