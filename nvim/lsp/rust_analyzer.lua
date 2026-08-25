-- nvim/lsp/rust_analyzer.lua
-- ==================================================
-- LSP config for lua
-- 1. 此目录下文件将被 mason-lsp-config 插件，在 `automatic_enable = true` 时
--   用于通过`vim.lsp.config` 为对应语言类型进行配置。
-- 2. 若位于其他目录，一般需在 `nvim-lspconfig` 的 `config` 手动加载
--  `require(...)`。（或者不拆分）
-- ==================================================

return {
  -- capabilities = require("cmp_nvim_lsp").default_capabilities(),
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = true, -- 默认就是 true，可省略
      check = {
        command = "clippy",
        -- extraArgs = { "--", "-W", "clippy::pedantic" }, -- 可选
      },
      inlayHints = {
        -- 新版 rust-analyzer 的 inlayHints 配置项如下：
        bindingModeHints = { enable = true },
        closureReturnTypeHints = { enable = true },
        lifetimeElisionHints = { enable = true },
        parameterNames = { enable = true },
        typeHints = { enable = true },
        chainingHints = { enable = true }, -- 新版中可能已合并到 typeHints
      },
    },
  },
}
