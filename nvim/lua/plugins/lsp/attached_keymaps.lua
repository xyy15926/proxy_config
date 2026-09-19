-- ==========================================================================
-- File    : attached_keymaps.lua
-- Author  : xyy15926
-- Created : 2026-09-15 13:45:40
-- Updated : 2026-09-19 22:35:48
-- Desc    : LSP keymaps.
-- ==========================================================================

return function(args)
  local bufnr = args.buf

  -- 工厂函数帮忙补充 `desc`
  local function opts(desc)
    return { buffer = bufnr, silent = true, desc = desc }
  end

  -- =============================================================
  -- nvim 0.11+ 在 LSP attach 时的默认键位，可不配置
  -- 跳转
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("LspGoto: Definition"))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("LspGoto: Declaration"))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("LspGoto: Implementation"))
  -- vim.keymap.set("n", "]d", function() vim.diagnostic.jump( { count = 1 }) end, opts("Next Diagnostic"))
  -- vim.keymap.set("n", "[d", function() vim.diagnostic.jump( { count = -1 }) end, opts("Prev Diagnostic"))

  -- 信息
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("LspHover: Signature"))
  -- pcall(vim.keymap.del, "n", "K", { buffer = bufnr })

  -- 操作
  vim.keymap.set("n", "grr", vim.lsp.buf.references, opts("LspGoto: References"))
  vim.keymap.set("n", "gra", vim.lsp.buf.code_action, opts("LspDo: Code Action"))
  vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts("LspDo: Rename"))
  -- 跳转
  -- =============================================================

  -- 跳转
  vim.keymap.set("n", "<leader>jr", function() vim.diagnostic.jump( { count = -1 }) end, opts("LspGoto: Prev Diag"))
  vim.keymap.set("n", "<leader>jf", function() vim.diagnostic.jump( { count = 1 }) end, opts("LspGoto: Next Diag"))
  vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts("LspGoto: Type Definition"))
  vim.keymap.set("n", "gv", function() vim.cmd("rightbelow vsplit"); vim.lsp.buf.definition() end, opts("LspVs: Definition"))
  -- vim.keymap.set("n", "gn", function() vim.diagnostic.jump({ count = 1 }) end, opts("Next Diagnostic"))
  -- vim.keymap.set("n", "gp", function() vim.diagnostic.jump({ count = -1 }) end, opts("Prev Diagnostic"))
  vim.keymap.set("n", "gf", vim.diagnostic.open_float, opts("LspHover: Open Diagnostic"))
  -- 正好覆盖 gQ 进入 Ex mode
  vim.keymap.set("n", "gQ", vim.diagnostic.setqflist, opts("Lsp: Diagnostic SetQFix"))

  -- 信息
  -- `vim.lsp.buf.signature_help` 包含 doc 且无法 toggle，建议使用 blink.cmp 中配置的 `<C-h>`
  vim.keymap.set("i", "<C-l>", vim.lsp.buf.signature_help, opts("LspHover: Signature Help"))
  vim.keymap.set("n", "<leader>hh", vim.lsp.buf.hover, opts("LspHover: Signature"))
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    vim.keymap.set("n", "<leader>hi", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
    end, opts("LspHover: Inlay Hints" ))
  end
end
