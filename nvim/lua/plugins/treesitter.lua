-- ==========================================================================
-- File    : treesitter.lua
-- Author  : xyy15926
-- Created : 2026-09-01 09:59:44
-- Updated : 2026-09-08 19:57:57
-- Desc    : Treesitter configs.
--
-- --------------------------------------------------------------------------
-- vim.treesitter：Neovim 内置的语法解析能力
-- 1. 解析器接口 — vim.treesitter.get_parser()、vim.treesitter.start()
-- 2. 语法树查询 — vim.treesitter.query.parse()、vim.treesitter.query.get()
-- 3. 高亮引擎 — 底层的高亮渲染机制
-- 4. 增量解析 — 文件变化时只更新部分语法树
-- 5. 代码折叠 — vim.treesitter.foldexpr()
-- 6. 内置命令 — :Inspect、:InspectTree、:EditQuery
--
-- --------------------------------------------------------------------------
-- nvim-treesitter：vim.treesitter 能力封装、查询文件、解析器安装管理
-- 1. 解析器安装管理 — ensure_installed、auto_install、:TSInstall、:TSUpdate
-- 2. 查询文件 — highlights、indents、folds、textobjects 等 .scm 查询文件
-- 3. 模块化功能 — highlight、indent、incremental_selection 等模块的开关配置
-- Neovim 正逐步将 nvim-treesitter 功能吸收
--
-- ---------------------------------------------------------------------------
-- tree-sitter-cli 解析器：需要额外安装
-- 1. 需要 cargo, npm 安装 `tree-sitter-cli` 以支持将不同的语法规则
--   （`grammer.js`）编译为动态链接库
-- 1.1. `tree-sitter-cli` 是 Rust 程序，但 `grammer.js` 先转换为 C、再编译为
--   `.so` C 库，以提高兼容性，Rust 自身 ABI 兼容性一般
-- 1.2. `tree-sitter-cli` 使用 JS 作为输入，是因为最初用于 Atom 项目
-- 2. `:TSIntsall` 即下载编译好的 `.so` 文件
-- 通过 `:InspectTree` 即可查看解析器为当前 buffer 生成的语法解析树
--
-- ---------------------------------------------------------------------------
-- 查询文件 `.scm`：vim.treesitter 中包含大量文件类型对应的查询文件
-- 1. 查询文件包含一组匹配模式，用于将解析器生成的语法解析树中节点映射为供
--   后续高亮、缩进、折叠所需的 “捕获名”
-- 1.1. 如：语法解析树中 `if`, `else` 等节点映射为 `@keyword`
-- 2. 高亮、缩进、折叠等分别对应不同查询文件
-- ==========================================================================

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  -- `TSUpdate` 只更新已安装的解析器
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- nvim-treesitter `setup` 只处理此选项
    install_dir = vim.fn.stdpath('data') .. '/site',
    -- 下述都是自定义、自行处理逻辑的选项
    ensure_installed = {
      "lua", "python", "c", "cpp", "rust",
      "bash", "markdown", "markdown_inline",
      "json", "yaml", "toml", "vim", "vimdoc",
      "query",
    },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },
  config = function(_, opts)
    -- `nvim-treesitter` 的 `setup` 没做任何事情，除了配置 `install_dir`
    require("nvim-treesitter").setup(opts)

    if opts.auto_install then
      require("nvim-treesitter").install(opts.ensure_installed)
    end

    -- Ref:
    -- - lazy/nvim-treesitter/README.md
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      pattern = opts.ensure_installed,
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if lang and pcall(vim.treesitter.language.inspect, lang) then
          -- 1. 为已安装 parser 类型 buffer 通过 `vim.treesitter.start()` 启用
          --   treesitter 语法高亮
          -- 2. 若未设置，则只有 `<rtp>/ftplugin/<lang>.lua` 中包含
          --   `vim.treesitter.start()` 的 buffer 将启用 treesitter 语法高亮
          -- 3. 可通过 `:Inspect` 查看光标下的高亮情况，判断 treesitter 高亮
          --   是否启用
          vim.treesitter.start(args.buf, lang)

          -- 启用 treesitter folds、intention
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          vim.notify(
            "Set highlight, foldexpr and foldmethod for buffer "
            .. args.file .. " with treesitter parser.",
            vim.log.levels.TRACE
          )
        end
      end,
    })
  end,
}
