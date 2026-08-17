-- ============================================================
-- treesitter.lua — 替代 rust.vim 的语法高亮 + 更准确的高亮
-- 1. 需要 cargo, npm 安装 `tree-sitter-cli` 以支持将不同的语法
--   规则（`grammer.js`）编译为动态链接库
-- 2. `tree-sitter-cli` 是 Rust 程序，但 `grammer.js` 先转换为
--   C、再编译 C 库，以提高兼容性，Rust 自身 ABI 兼容性一般
-- 3. `tree-sitter-cli` 使用 JS 作为输入，是因为最初用于 Atom
--   项目
-- ============================================================

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter",  -- 指定主模块名，lazy.nvim 会用它调 setup()
  opts = {
    ensure_installed = {
      "lua", "python", "c", "cpp", "rust",
      "bash", "markdown", "markdown_inline",
      "json", "yaml", "toml", "vim", "vimdoc",
    },
    highlight = { enable = true },
    indent = { enable = true },
    auto_install = true,
  },
}
