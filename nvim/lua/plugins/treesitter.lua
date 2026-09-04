-- ==========================================================================
-- File    : treesitter.lua
-- Author  : xyy15926
-- Created : 2026-09-01 09:59:44
-- Updated : 2026-09-02 09:56:20
-- Desc    : Treesitter configs.

-- nvim-treesitter：更准确的语法高亮
-- 1. 需要 cargo, npm 安装 `tree-sitter-cli` 以支持将不同的语法规则
--   （`grammer.js`）编译为动态链接库
-- 2. `tree-sitter-cli` 是 Rust 程序，但 `grammer.js` 先转换为 C、再编译 C 库，
--   以提高兼容性，Rust 自身 ABI 兼容性一般
-- 3. `tree-sitter-cli` 使用 JS 作为输入，是因为最初用于 Atom 项目
-- ==========================================================================

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "lua", "python", "c", "cpp", "rust",
      "bash", "markdown", "markdown_inline",
      "json", "yaml", "toml", "vim", "vimdoc",
    },
    auto_install = true,
    indent = {
      enable = true,
    },
  },
  config = function(_, opts)
    require("nvim-treesitter").setup(opts)
    -- 对 buffer 手动启用 treesitter parser
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      pattern = opts.ensure_installed,
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if lang and pcall(vim.treesitter.language.inspect, lang) then
          vim.treesitter.start(args.buf, lang)
          -- vim.notify("Set buffer " .. args.file .. " with treesitter parser.")
        end
      end,
    })
  end,
}
