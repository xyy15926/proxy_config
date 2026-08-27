-- ==========================================================================
-- File    : rooter.lua
-- Author  : xyy15926
-- Created : 2026-08-27 17:35:17
-- Updated : 2026-08-27 17:48:22
-- Desc    : Find and set the root of the project as the working directory.
-- ==========================================================================

local M = {}

M.defaults = {
  root_flags = { ".root", ".svn", ".git", ".hg", ".project", "Makefile" },
  file_ptns = "*",
}
M.opts = vim.deepcopy(M.defaults)

-- 向上搜索找到项目根目录
function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  return vim.fs.root(0, M.opts.root_flags) or ""
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  vim.api.nvim_create_autocmd("BufEnter", {
    group =  vim.api.nvim_create_augroup("ProjectRooter", { clear = true }),
    pattern = M.opts.file_ptns,
    callback = function(args)
      local root = M.find_project_root()
      if root ~= "" then
        vim.cmd("cd " .. root)
      end
    end,
  })
end

return M
