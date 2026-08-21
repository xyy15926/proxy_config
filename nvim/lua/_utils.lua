-- ==================================================
-- _utils.lua
-- 通用配置、函数
-- ==================================================

local M = {}

M.defaults = {
  root_flags = { '.root', '.svn', '.git', '.hg', '.project', 'Makefile' },
}

-- 全局配置
M.opts = vim.deepcopy(M.defaults)

-- 向上搜索找到项目根目录
function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  return vim.fs.root(0, M.opts.root_flags) or ''
end

-- 允许自定义全局配置
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M
