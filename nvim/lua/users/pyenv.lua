-- ==========================================================================
-- File    : pyenv.lua
-- Author  : xyy15926
-- Created : 2026-08-28 17:28:54
-- Updated : 2026-08-28 17:33:54
-- Desc    : Settings for python env.
-- ==========================================================================

local M = {}
M.defaults = {}
M.opts = vim.deepcopy(M.defaults)

-- 检测是否有 pixi 环境
function M.has_pixi(root)
  root = root or require("users.rooter").find_project_root()
  return root ~= "" and vim.fn.glob(root .. "/.pixi") ~= ""
end

-- 给命令加上 pixi run 前缀
function M.pixify(cmd, root)
  root = root or require("users.rooter").find_project_root()
  if M.has_pixi(root) then
    local new_cmd = { "pixi", "run" }
    for _, v in ipairs(cmd) do table.insert(new_cmd, v) end
    return new_cmd
  end
  return cmd
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M
