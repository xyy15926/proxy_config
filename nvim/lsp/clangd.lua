-- nvim/lsp/clangd.lua
-- ==================================================
-- LSP config for lua
-- 1. 此目录下文件将被 mason-lsp-config 插件，在 `automatic_enable = true` 时
--   用于通过`vim.lsp.config` 为对应语言类型进行配置。
-- 2. 若位于其他目录，一般需在 `nvim-lspconfig` 的 `config` 手动加载
--  `require(...)`。（或者不拆分）
-- ==================================================

return {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
}
