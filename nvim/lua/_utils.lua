local M = {}

local root_flags = { '.root', '.svn', '.git', '.hg', '.project', 'Makefile' }
M.root_flags = root_flags

function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  return vim.fs.root(0, root_flags) or ''
end

-- 检测是否有 pixi 环境
function M.has_pixi(root)
  return root ~= '' and vim.fn.glob(root .. '/.pixi') ~= ''
end

-- 给命令加上 pixi run 前缀
function M.pixify(cmd, root)
  if M.has_pixi(root) then
    local new_cmd = { 'pixi', 'run' }
    for _, v in ipairs(cmd) do table.insert(new_cmd, v) end
    return new_cmd
  end
  return cmd
end

return M
