-- =======================================================
-- ~/.config/nvim/lua/overseer/template/user/python.lua
-- overseer 任务模板
-- =======================================================

local utils = require("_utils")
local pyenv = require("users.pyenv")

-- 查找对应测试文件（对应原 TestPython 的测试发现逻辑）
local function find_test_file(root, abspath)
  local paths = vim.split(abspath, "/")
  local filename = paths[#paths]
  local root_parts = vim.split(root, "/")
  local root_hier = #root_parts

  for cur_pos = 2, #paths - root_hier do
    local mod_parts = {}
    for i = #paths - cur_pos + 1, #paths - 1 do
      table.insert(mod_parts, paths[i])
    end
    local modname = table.concat(mod_parts, "/")
    local testfile = root .. "/tests/" .. modname .. "/test_" .. filename
    if vim.fn.filereadable(testfile) == 1 then
      return testfile
    end
  end
  return nil
end

-- ✅ 正确：返回 table，包含 generator 字段
-- 注意：默认环境可能没有 `python`，只有 `python3`，若下述 `cmd` 使用
--   `python`，可能导致任务一直 PENDING
return {
  generator = function(search)
    local root = utils.find_project_root()

    local tasks = {}
    local abspath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")

    -- 1. Python Run
    table.insert(tasks, {
      name = "Python Run",
      desc = "Run current Python file (pixi-aware)",
      tags = { "RUN", "PYTHON" },
      builder = function()
        local cmd = pyenv.pixify({ "python3", abspath }, root)
        return {
          cmd = cmd,
          cwd = root,
          components = { "default", "run" },
        }
      end,
    })

    if root == "" then
      return tasks
    end

    -- 2. Python Build
    table.insert(tasks, {
      name = "Python Build",
      desc = "Build Python project with python -m build (pixi-aware)",
      tags = { "BUILD", "PYTHON" },
      builder = function()
        local cmd = pyenv.pixify({ "python3", "-m", "build" }, root)
        return {
          cmd = cmd,
          cwd = root,
          components = { "default", "build" },
        }
      end,
    })

    -- 3. Python Test
    local target = filename:match("^test_") and abspath or find_test_file(root, abspath)
    if target then
      table.insert(tasks, {
        name = "Python Test",
        desc = "Run pytest (pixi-aware, auto-discovers test files)",
        tags = { "TEST", "PYTHON" },
        builder = function()
          local cmd = pyenv.pixify({ "pytest", target }, root)
          return {
            cmd = cmd,
            cwd = root,
            components = { "default", "test" },
          }
        end,
      })
    end

    return tasks
  end,

  -- 可选：condition 让 overseer 在扫描时快速过滤
  condition = {
    filetype = { "python" },
    -- callback = function(search)
    --   return utils.find_project_root() ~= ""
    -- end,
  },
}
