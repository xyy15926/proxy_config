-- ==================================================
-- pyenv.lua
-- Python 环境相关配置
-- ==================================================

local M = {}

-- 检测是否有 pixi 环境
function M.has_pixi(root)
  root = root or require("_utils").find_project_root()
  return root ~= '' and vim.fn.glob(root .. '/.pixi') ~= ''
end

-- 给命令加上 pixi run 前缀
function M.pixify(cmd, root)
  root = root or require("_utils").find_project_root()
  if M.has_pixi(root) then
    local new_cmd = { 'pixi', 'run' }
    for _, v in ipairs(cmd) do table.insert(new_cmd, v) end
    return new_cmd
  end
  return cmd
end

return M
