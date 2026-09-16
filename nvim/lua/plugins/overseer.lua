-- ==========================================================================
-- File    : overseer.lua
-- Author  : xyy15926
-- Created : 2026-09-09 10:14:05
-- Updated : 2026-09-15 11:20:16
-- Desc    : Configs for overseer to run predefined tasks.
--
-- Ref:
-- - lazy/overseer.nvim/doc/guides.md
-- - lazy/overseer.nvim/doc/reference.md
-- - lazy/overseer.nvim/lua/overseer/config.lua
--
-- --------------------------------------------------------------------------
-- Template 和 Task
-- 1. `overseer.run_template(opts, callback)` 根据模板创建、运行任务
-- 2. `overseer.run_task(opts)` 直接创建、运行任务（跳过模板系统）
--
-- --------------------------------------------------------------------------
-- 注册模板
-- 1. 手动注册：`require("overseer").register_template({})`
-- 2. 自动发现：位于 <RTP>/lua/overseer/template 目录下文件将被自动加载
-- 2.1. 额外目录需要在 `template_dirs` 中以相对于 <RTP>/lua/ 的路径注册
-- 2.2. 可通过 `disable_template_modules` 禁用模板模块（包括内置模板模块）
-- 2.3. 内置模板模块位置逻辑一致，可通过 `:checkhealth overseer` 查看全部模块、
--   以及模板适用性
-- 3. 模板定义有两种类型
-- 3.1. template definition 表：定义单个模板
-- 3.2. template provider 表：动态生成多个模板
--
-- Ref:
-- - lazy/overseer.nvim/doc/guides.md#template-definition
-- - lazy/overseer.nvim/doc/guides.md#template-providers
--
-- --------------------------------------------------------------------------
-- Component 组件：挂载到 task 上的功能模块，监听 task 生命周期各阶段事件、
--   并执行动作
-- 1. task 本质上就是 cmd + 一组监听 components
-- 1.1. 若 template(task) 中包含同名组件，仅首个同名组件生效
-- 2. 内置组件包括任务标准输出解析、结果解析、清理等
-- 3. component aliases 即多个组件的打包，内置有 `default` 别名
--
-- Ref:
-- - lazy/overseer.nvim/doc/guides.md#custom-components
-- - lazy/overseer.nvim/doc/guides.md#component-aliases
-- - lazy/overseer.nvim/doc/components.md
--
-- -------------------------------------------------------------------------
-- 内置组件说明
-- 1. 内置组件主要包括
-- 1. `on_output` 处理、展示标准输出组件
-- 1.1 输出方式包括 temrinal, quickfix, file 等
-- 2. `on_result` 处理、监控 result 组件
-- 2.1. result 主要依赖 `on_output_parse` 将 output 转换为 result
-- 3. `on_result_diagnostics` 处理 result.diagnostics
-- 4. `run_after`, `dependecies` 任务依赖管理组件
-- 5. notify, dispose, restart 等通知、清理组件
--
-- Ref:
-- - lazy/overseer.nvim/doc/guides.md#parsing-output
--
-- --------------------------------------------------------------------------
-- 注册组件、组件别名
-- 1. 手动注册：`require("overseer").register_component()`
-- 2. 自动发现：位于 $RTP/lua/overseer/component 目录下文件将被自动加载
-- 3. 组件别名直接通过 `component_aliases` 添加即可
--
-- --------------------------------------------------------------------------
-- `on_output_parse` Parser
-- 1. `on_output_parse` 即用于解析 output 的核心组件
-- 1.1. 其中，`errorformat`、`parser`、`problem_matcher` 仅能有单个参数被设置
-- 2. `errorformat` 即 vim scanf 内置的从 output 从获取 diagnostics 信息
--   规范（可 `:help errorformat` 查看）
-- 2.1. 若仅仅需设置 quickfix，可直接使用 `on_output_quickfix`，而无需组合
--   `on_output_quickfix`、`on_result_diagnostics_quickfix`
-- 3. `parser` 可为逐行处理 output 的函数、或更复杂的类
-- 3.1. 逐行处理函数时，应返回满足 `:help setqflist-what`、至少包含
--   `filename`、`lnum`、`text` 字段的表，被作为 `task.result.diagnostics` 
--   中元素
-- 3.2. 处理复杂的类时，类需包含 `parse`、`get_result`、`reset` 方法，
--   `get_result` 返回表即 `task.result`，即可任意设置 `task.result`，而
--   不仅仅是设置 `task.result.diagnostics`
--
-- PS:
-- 可通过 `=require("overseer").list_task()[1]` 查看某 task 细节
-- - `.result` 查看 task.result 内容
-- - `.components` 查看关联组件
--
-- Ref:
-- - lazy/overseer.nvim/doc/parsers.md
-- ==========================================================================

--- keymap 注册工厂函数
--- @param lhs string keys
--- @param template_name string
--- @param desc string? template name will be used as default
--- @param args table? args of the `vim.api.nvim_create_autocmd` callback
local tmpl_map = function(lhs, template_name, desc, args)
  -- 默认为当前 buffer
  local bufnr = args and args.buf or 0
  desc = desc or template_name
  vim.keymap.set("n", lhs, function()
    require("overseer").run_task({ name = template_name })
  end, { buffer = bufnr, desc = desc })
end

return {
  "stevearc/overseer.nvim",
  lazy = true,
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerRun",
    "OverseerTaskAction",
    "OverseerShell",
  },
  keys = {
    { "<leader>nx", "<cmd>OverseerToggle<cr>", desc = "Task: Task List" },
    { "<leader>xx", "<cmd>OverseerRun<cr>", desc = "Task: Choose&Run Task" },
    { "<leader>xl", "<cmd>OverseerTaskAction<cr>", desc = "Task: Check Task" },
  },
  opts = {
    template_dirs = {},  -- 额外模板文件目录
    disable_template_modules = {},  -- 禁用模板模块
    -- 任务列表面板
    task_list = {
      direction = "right",
      min_width = { 40, 0.1 },
      max_width = { 100, 0.2 },
      bindings = {
        ["?"] = "ShowHelp",
        ["q"] = "Close",
        ["<CR>"] = "RunAction",
        ["<C-e>"] = "Edit",
        ["o"] = "Open",
        ["r"] = "Restart",
        ["x"] = "Cancel",
        ["d"] = "Dispose",
      },
    },
    -- 任务输入、编辑的交互弹窗样式
    form = {
      border = "rounded",
      win_opts = { winblend = 0 },
    },
    task_win = {
      border = "rounded",
      win_opts = { winblend = 0 },
    },

    -- 组件别名：组件是 overseer 执行任务的钩子动作，别名即打包
    -- 用于 task 创建时指定 `components`
    component_aliases = {
      -- Ref: lazy/overseer.nvim/doc/components.md
      default = {
        -- 标准输出处理
        -- { "open_output", direction = "dock", focues = "false", on_complete = "failure", on_result = "if_diagnostics", on_start = "never" },
        -- { "on_output_otify", delay_ms = 2000, trim = true },
        -- { "on_output_quickfix", close = true, focus = false },
        -- { "on_output_write_file", filename = "overseer.log" },

        -- 设置 result：调用 `task:set_result()` 的组件
        -- { "on_output_parse" },  -- 标准输出解析，需要根据不同类型任务配置
        { "on_exit_set_status", success_codes = { 0 } },  -- 设置 `result.exit_code`，代码里默认会插入 0

        -- result 处理：设置、修改 result（或其中部分字段）后被触发
        -- { "on_result_notify", infer_status_from_diagnostics = true, on_change = true, },  -- 任务完成前即可能因 `set_result` 被触发
        -- { "on_result_diagnostics", remove_on_restart = true },  -- 要求 `result.diagnostics` 字段表
        -- { "on_result_diagnostics_quickfix", close = true, open = true },
        -- { "on_result_diagnostics_trouble" },

        -- 依赖相关组件
        -- { "run_after", tasks = {}, status = { "SUCCESS" } },
        -- { "dependecies", tasks = {} },

        -- 重启、清理等组件
        -- { "restart_on_save", delay = 500 },
        -- { "on_complete_restart", status = { "FAILUARE" }, delay = 5000 },
        { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE", "CANCELED" }, statuses = { "SUCCESS", "FAILUARE", "CANCELED" }, timeout = 300 },
        { "on_complete_notify", statues = { "FAILURE", "SUCCESS" }, system = "unfocused" },

        -- 其他
        { "timeout", timeout = 100 },
        { "unique", replace = true, soft = true },
      },
      diagnostics = {
        { "on_output_parse", errorformat = "%f:%l: %m" },
        { "on_result_diagnostics", remove_on_restart = true },  -- 要求 `result.diagnostics` 字段表
        { "on_result_diagnostics_quickfix", close = true, open = true },
      },
    },

    default_template_prompt = "allow",
  },
  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)

    -- Python 快捷键（对应原 vimscript 的 xb/xr/xt）
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "python",
      callback = function(args)
        tmpl_map("<leader>xb", "python build", "python build")
        tmpl_map("<leader>xt", "python test", "python test")
        tmpl_map("<leader>xr", "python run", "python run")
      end,
    })

    -- Rust 快捷键（使用内置 cargo 模板）
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function(args)
        tmpl_map("<leader>xb", "cargo build", "Cargo Build")
        tmpl_map("<leader>xt", "cargo test", "Cargo Test")
        tmpl_map("<leader>xr", "cargo run", "Cargo Run")
      end,
    })
  end,
}
