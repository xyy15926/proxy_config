-- nvim/lsp/basedpyright.lua
-- ==================================================
-- LSP config for lua
-- 1. 此目录下文件将被 mason-lsp-config 插件，在 `automatic_enable = true` 时
--   用于通过`vim.lsp.config` 为对应语言类型进行配置。
-- 2. 若位于其他目录，一般需在 `nvim-lspconfig` 的 `config` 手动加载
--  `require(...)`。（或者不拆分）
-- ==================================================

return {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
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
    local utils = require("_utils")
    local pyenv = require("users.pyenv")
    local root = utils.find_project_root()
    if pyenv.has_pixi(root) then
      local pixi_python = root .. "/.pixi/envs/default/bin/python"
      client.config.settings.python.pythonPath = pixi_python
      client:notify("workspace/didChangeConfiguration", {
        settings = client.config.settings,
      })
    end
  end,
}
