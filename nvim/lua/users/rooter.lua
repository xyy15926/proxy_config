-- ==========================================================================
-- File    : rooter.lua
-- Author  : xyy15926
-- Created : 2026-08-27 17:35:17
-- Updated : 2026-08-28 17:56:39
-- Desc    : Find and set the root of the project as the working directory.
-- ==========================================================================

local M = {}

M.defaults = {
  root_flags = { ".root", ".svn", ".git", ".hg", ".project", "Makefile" },
}
M.opts = vim.deepcopy(M.defaults)

--- 向上搜索找到项目根目录
function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  return vim.fs.root(0, M.opts.root_flags) or ""
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("SetRoot", { clear = true }),
    pattern = "*",
    callback = function(args)
      local root = M.find_project_root()
      if root ~= "" then
        vim.cmd("cd " .. root)
      end
    end,
  })
end

return M
