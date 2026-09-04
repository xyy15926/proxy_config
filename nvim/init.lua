-- ==========================================================================
-- File    : init.lua
-- Author  : xyy15926
-- Created : 2026-09-01 10:56:36
-- Updated : 2026-09-01 13:41:31
-- Desc    : Init neovim.
--
-- --------------------------------------------------------------------------
-- 关于 LazyVim 插件配置 spec 的说明
-- - 安装、基本信息
--   - [1] Github 仓库名
--   - name：插件显示名称
--     - 缺省从仓库名推导
--   - version：语义版本号
--     - 缺省为 `*` 表示使用最新 tag
--   - tag：指定 git tag
--   - commit：指定 git commit hash
--   - branch：指定分支
--   - url：自定义 URL
--     - 指定后，不从 Github 安装
--   - dir：本地插件路径
--   - dev：从本地开发目录加载，配合 `lazy.vim` 的 `dev` 选项
-- - 插件加载
--   - lazy：懒加载
--     - 懒加载复位时，后续插件 trigger 无意义
--   - priority：（非懒）加载优先级
--     - 缺省 50
--     - 仅影响 `lazy = false` 插件
-- - 插件加载 trigger
--   - ft：设置 filetype
--     - 不影响插件实际生效的 buffer
--     - 即，插件加载后对哪些 filetype buffer 生效与此无关
--   - cmd：执行命令
--   - keys：按下快捷键
--     - 并，同时绑定相关快捷键
--   - event：（用户定义）事件监听
--     - 常为 `VeryLazy` 指 LazyVim 其他加载完毕后
--   - dependencies：依赖项
--     - 依赖插件将在当前插件之前加载
-- - 初始化配置
--   - main：模块名称
--     - 缺省从仓库名推导
--     - 仅在仓库名、模块名不同，且默认初始化时需手动设置，如 `nvim-lspconfig`
--       模块名为 `lspconfig`
--   - opts：配置表
--     - 可替代 `config` 实现简单、默认初始化
--   - config：自定义初始化函数
--     - 签名为 `config(plugin, opts)`
--       - `plugin` 为插件 spec 表，一般置 `_` 不使用
--       - `opts` 即前述 `opts` 字段
--     - 缺省，可视为执行 `require(main).setup(opts)`
--     - `opts`、`config` 均不存在时，只执行 `require(main)`
-- - 构建
--   - build：插件安装、更新后执行的命令
--     - 如：`make`、`:TSUpdate`
-- - 约束
--   - enabled：安装、启用插件（可为函数）
--     - 复位时，不安装、不加载
--   - cond：是否加载插件（可为函数）
--     - 不影响已安装插件，只控制是否加载
--   - pin：锁定版本
--     - 置位时，`:Lazy update` 也不更新插件
-- ==========================================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("users.init")

-- 此处设置 `plugins` 将扫描、导入 `plugins/*.lua` 模块
-- 即，`plugins/init.lua` 中无需 `import` lua 文件模块，仅需 `import` 文件夹
require("lazy").setup("plugins", {
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "catppuccin-mocha" } },    -- 仅用于制定首次安装插件时的配色
  checker = { enabled = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
