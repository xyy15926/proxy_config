-- ==========================================================================
-- File    : rooter.lua
-- Author  : xyy15926
-- Created : 2026-08-27 17:35:17
-- Updated : 2026-09-11 19:12:16
-- Desc    : Find and set the root of the project as the working directory.
-- ==========================================================================

local M = {}

M.defaults = {
  root_flags = { ".root", ".svn", ".git", ".hg", ".project", "Makefile" },
}
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  根目录定位、设置
-- ==========================================================================
--- 向上搜索找到项目根目录
--- @return string
function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  vim.b.root_dir = vim.b.root_dir
    or vim.fs.root(0, M.opts.root_flags)
    or vim.fn.expand("%:p:h")
    or ""
  return vim.b.root_dir
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- 手动重置根目录（工作目录）
  vim.api.nvim_create_user_command("ResetRooterHere", function()
    local root = M.find_project_root()
    if root ~= "" then
      vim.cmd("cd " .. root)
      vim.notify("Set root: " .. root, vim.log.levels.TRACE)
    end
  end, {})

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("users.rooter.set_root", { clear = true }),
    pattern = "*",
    callback = function(args)
      local root = M.find_project_root()
      if root ~= "" then
        vim.cmd("cd " .. root)
        vim.notify("Set root: " .. root, vim.log.levels.TRACE)
      end
    end,
    once = true,  -- 只执行设置一次
  })
end

return M
