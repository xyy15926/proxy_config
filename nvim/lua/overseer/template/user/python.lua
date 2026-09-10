-- ==========================================================================
-- File    : python.lua
-- Author  : xyy15926
-- Created : 2026-09-09 11:12:18
-- Updated : 2026-09-10 14:44:57
-- Desc    : Overseer task templates for python project.
--
-- Ref:
-- - lazy/overseer.nvim/doc/guides.md
-- - lazy/overseer.nvim/doc/guides.md#template-definition
-- - lazy/overseer.nvim/doc/guides.md#template-providers
--
-- ==========================================================================

local rooter = require("users.rooter")
local pyenv = require("users.pyenv")

return {
  generator = function(search)
    local root = rooter.find_project_root()

    local tasks = {}
    local abspath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")

    -- 1. Python Run
    table.insert(tasks, {
      name = "python run",
      desc = "Run current Python file (pixi-aware)",
      tags = { "RUN", "PYTHON" },
      builder = function()
      -- 注意：默认环境可能没有 `python`，只有 `python3`
      -- 若下述 `cmd` 使用 `python`，可能导致任务一直 PENDING
        return {
          cmd = pyenv.pixify({ "python3", abspath }, root),
          cwd = root,
          components = { "default", "diagnostics" },
        }
      end,
    })

    if root == "" then
      return tasks
    end

    -- 2. Python Build
    table.insert(tasks, {
      name = "python build",
      desc = "Build Python project with python -m build (pixi-aware)",
      tags = { "BUILD", "PYTHON" },
      builder = function()
        return {
          cmd = pyenv.pixify({ "python3", "-m", "build" }, root),
          cwd = root,
          components = { "default", "diagnostics" },
        }
      end,
    })

    -- 3. Python Test
    local target = filename:match("^test_") and abspath or pyenv.find_test_file(abspath)
    if target then
      table.insert(tasks, {
        name = "python test",
        desc = "Run pytest (pixi-aware, auto-discovers test files)",
        tags = { "TEST", "PYTHON" },
        builder = function()
          return {
            cmd = pyenv.pixify({ "pytest", "--tb=short", "-q", "--color=no", target }, root),
            components = {
              "default",
              -- 同名组件仅首个被应用
              { "on_output_parse", parser = function(line)
                  local fname, lnum, msg = line:match("^(.*):(%d+): (.*)$")
                  -- Return a table in the format of :help setqflist-what
                  -- or return nil if no match
                  if fname then
                    return {
                      filename = fname,
                      lnum = tonumber(lnum),
                      text = "pytest: error " .. msg
                    }
                  end
                end
              },
              "diagnostics",
            },
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
    --   return rooter.find_project_root() ~= ""
    -- end,
  },
}
