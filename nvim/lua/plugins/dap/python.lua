-- ==========================================================================
-- File    : python.lua
-- Author  : xyy15926
-- Created : 2026-09-14 19:52:06
-- Updated : 2026-09-14 19:52:06
-- Desc    : Python DAP config.
--
-- Ref:
-- - lazy/nvim-dap-python/README.md
--
-- ==========================================================================
-- configurations 配置项
--
-- DAP 公共字段
-- -------------------------
-- type    = "python",      -- 对应 dap.adapters 里注册的 key
-- request = "launch",      -- "launch"（启动进程）或 "attach"（附加到已有进程）
-- name    = "Launch file", -- 按 <leader>dd 弹出选择器里显示的名字
--
-- launch 模式参数
-- -------------------------
-- program      = "${file}",              -- 要启动的程序入口文件
-- module       = "pytest",               -- 等价于 python -m pytest，与 program 二选一
-- args         = { "${file}", "-v" },    -- 传给程序的命令行参数
-- cwd          = "${workspaceFolder}",   -- 工作目录
-- env          = { FOO = "bar" },        -- 环境变量
-- envFile      = "${workspaceFolder}/.env",  -- 从 .env 文件读取环境变量
-- stopOnEntry  = true,                   -- 启动后在第一行暂停
-- noDebug      = false,                  -- true = 只运行不调试（等价于不启动 DAP）
--
-- attach 模式参数
-- -------------------------
-- connect  = { host = "127.0.0.1", port = 5678 },  -- 远程调试地址
-- processId = vim.fn.input("PID: "),               -- 或直接附加到本地进程 PID
--
-- 1. 5678 是 debugpy 启动时默认监听端口，configuration 要和服务器端实际一致
--   python -m debugpy --listen 5678 some_script.py
-- 2. 事实上，launch 模式 DAP 也是通过 socket 传递调试信息，只是此时
--   server(debugpy) 和 client(nvim-dap) 内部会自动处理
--
-- 通用调试行为
-- -------------------------
-- justMyCode  = false,    -- true = 只在你写的代码里断点，跳过标准库和第三方库
-- pathMappings = {        -- 远程/容器调试时的路径映射
--   { localRoot = "${workspaceFolder}", remoteRoot = "/app" },
-- },
--
-- nvim-dap 额外（非 DAP）配置
-- -------------------------
-- preLaunchTask  = function() os.execute("make build") end,  -- 启动调试前执行
-- postDebugTask  = function() os.execute("rm -f tmp") end,   -- 调试结束后执行
--
-- debugpy 私有字段
-- -------------------------
-- pythonPath     = "/usr/bin/python3",  -- 指定解释器路径
-- python         = "/usr/bin/python3",  -- 同上，优先级略低
-- subProcess     = true,                -- true = 调试子进程（multiprocessing 等场景）
-- django         = true,                -- 启用 Django 模板调试
-- flask          = true,                -- 启用 Flask/Jinja 模板调试
-- jinja          = true,                -- 同上
-- pyramid        = true,                -- 启用 Pyramid 模板调试
-- sudo           = true,                -- 用 sudo 启动
-- pyqtWatches    = true,                -- 支持 PyQt 变量查看
--
-- codelldb 私有字段
-- -------------------------
-- program = function()
--   return vim.fn.input("Path: ", vim.fn.getcwd() .. "/target/debug/", "file")
-- end,
-- sourceLanguages = { "rust" },
--
-- ==========================================================================
-- nvim-dap 自动展开以下变量
-- 变量	                        展开结果
-- ${file}                      当前文件绝对路径
-- ${fileBasename}              文件名（含扩展名）
-- ${fileBasenameNoExtension}   文件名（不含扩展名）
-- ${fileDirname}               文件所在目录
-- ${fileExtname}               扩展名（含点）
-- ${workspaceFolder}           nvim 的工作目录
-- ${workspaceFolderBasename}   工作目录名
-- ${funcName}                  光标所在函数名
-- ${lineNumber}                当前行号
-- ${selectedText}              选中的文本
-- ${env:HOME}                  读取环境变量
-- ==========================================================================

local pyenv = require("users.pyenv")

return {
  -- 启动 DAP server 的配置，其中 command, args 即指定如何启动 debugpy
  -- 即，其中 command 应为 debugpy 所属的 python 环境
  -- Ref:
  -- - lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/adapters/python.lua
  adapters = {
    type = "executable",
    -- 新版 debugpy 会直接注册 debugpy-adapter 命令
    command = pyenv.venv_cmd("debugpy-adapter"),
    -- 无需通过 command, args 分别指定
	  -- command = vim.fn.exepath("python"),
	  -- args = { "-m", "debugpy.adapters" },
  },
  -- debugpy 启动调试任务的配置
  -- 即，其中 pythonPath 应为待执行文件所需的 python 环境
  -- 大部分情况下可与 debugpy 所在 python 环境不同
  -- Ref:
  -- - lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/configurations.lua
  configurations = {
    {
      name = "Python: Current File",
      type = "python",
      request = "launch",
      program = "${file}",
      args = function()                               -- 支持运行时输入参数
        local args = vim.fn.input("Args: ")
        return vim.split(args, " ")
      end,
      cwd = "${workspaceFolder}",
      env = { PYTHONDONTWRITEBYTECODE = "1" },
      pythonPath = pyenv.venv_cmd("python3"),
      justMyCode = true,
      stopOnEntry = false,
      subProcess = false,
      console = "integratedTerminal",
    },
    {
      name = "Pytest: Current Test File",
      type = "python",
      request = "launch",
      module = "pytest",
      args = function()
        local abspath = vim.fn.expand("%:p")
        local filename = vim.fn.expand("%:t")
        local target = filename:match("^test_") and abspath
          or pyenv.find_test_file(abspath)
        return { target, "-v", "--no-header", "--tb=short" }
      end,
      cwd = "${workspaceFolder}",
      pythonPath = pyenv.venv_cmd("python3"),
      justMyCode = false,
      console = "integratedTerminal",
    },
    {
      name = "Pytest: Current Function",
      type = "python",
      request = "launch",
      module = "pytest",
      -- #TODO
      args = { "${file}::${funcName}", "-v" },
      pythonPath = pyenv.venv_cmd("python3"),
      justMyCode = false,
      console = "integratedTerminal",
    },
    {
      name = "Attach: Remote (5678)",
      type = "python",
      request = "attach",
      connect = { host = "127.0.0.1", port = 5678 },
      pathMappings = {
        { localRoot = "${workspaceFolder}", remoteRoot = "/app" },
      },
      justMyCode = false,
    },
    {
      name = "Attach: Remote",
      type = "python",
      request = "attach",
      connect = function()
        local host = vim.fn.input("Host: ", "127.0.0.1")
        local port = tonumber(vim.fn.input("Port: ", "5678"))
        return { host = host, port = port }
      end,
      pathMappings =  function()
        local localRoot = vim.fn.input("Local root: ", vim.fn.getcwd())
        local remoteRoot = vim.fn.input("Remote root: ", "/app")
        return {
          { localRoot = localRoot, remoteRoot = remoteRoot }
        }
      end,
      justMyCode = function()
        return vim.fn.input("Just my code? (y/n): ", "y") == "y"
      end,
    },
  },
}
