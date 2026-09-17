-- ==========================================================================
-- File    : attached_keymaps.lua
-- Author  : xyy15926
-- Created : 2026-09-15 13:45:40
-- Updated : 2026-09-16 19:59:45
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
  -- 正好覆盖 gQ 进入 Ex mode
  vim.keymap.set("n", "gQ", vim.diagnostic.setqflist, opts("Diagnostic SetQFix"))

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
end
