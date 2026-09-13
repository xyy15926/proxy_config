-- ==========================================================================
-- File    : tools.lua
-- Author  : xyy15926
-- Created : 2026-09-02 11:42:06
-- Updated : 2026-09-10
-- Desc    : Tools
--
-- Ref:
-- - lazy/codecompanion.nvim/doc/extending/tools.md
-- - lazy/codecompanion.nvim/doc/usage/chat-buffer/agents-tools.md
--
-- Tools：工具、工具组
--
-- - CodeCompanion 中工具遵守 OpenAI's function calling specification for
--   defining functions.
-- - LLM 将按工具的 JSON schema 返回报文，插件解析报文再调用工具
--
-- ###  工具组
--
-- Tool Groups 工具组：即将多个工具组合，以通过单个 `@{group_name}` 引用
--
-- - 工具组可配置、提供自身独立的 `system_prompt` 作为独立的 agent
--   - 同时置位 `ignore_system_prompt`、`ignore_tool_system_prompt` 将完全
--     替代默认 system prompt
--
-- ### 工具
--
-- - 调用工具的 `@{tool}` 词句将被工具的 `opts.tool_replacement_messsage`
--   替代，以提升 prompt 对 LLM 的可读性
-- - 预定义工具：预定义工具在对应的 `interactions` 项中配置
-- - 适配器工具：适配器工具在适配器中 `available_tools` 表中配置
-- - MCP 工具：CodeCompanion 中配置的 MCP 服务启动后，其工具将可用
--   - 工具名称以 `mcp.` 开头
--
-- ###  工具许可
--
-- - CodeCompanion 的工具许可是针对逐 chat buffer、逐工具的
--   - 许可选项
--     - Allow always
--     - Allow once
--     - Reject
--     - Cancel
--   - 部分潜在危害较大的工具（`run_command`）在命令层面被许可，而不是工具层面
--   - 可通过 `gtx` 在 chat buffer 中重置许可
-- - YOLO 模式：自动允许大部分工具执行，可通过 `gty` 启用
--   - 但，以下工具 `allowed_in_yolo_mode` 复位，不被许可自动执行
--     - `run_command`
--     - `delete_file`
--   - 对排除工具，可配置 LLM judge 由后台运行的模型判断是否可自动执行
-- ==========================================================================

return {
  opts = {
    default_tools = nil,
    -- “工具调用” 子系统的 system_prompt 配置
    system_prompt = {
      enabled = true,
      replace_main_system_prompt = false,  -- 与主系统 prmompt 共存
    },
  },

  -- %% ===========================================================
  --  以下为预定义工具组
  -- ==============================================================
  groups = {
    -- CodeCompanion 的 agent 模式，包含大量工具、独立的 system prompt
    agent = {
      tools = nil,
      opts = {
        collapse_tools = false,  -- 展开包含的工具
      },
    },
    -- 包含用于在当前工作目录进行文件操作的工具
    files = {
      tools = nil,
      opts = {
        collapse_tools = false,
        ignore_system_prompt = false,
        ignore_tool_system_prompt = false,
      },
    },
  },

  -- %% ===========================================================
  --  以下为预定义工具
  -- ==============================================================
  ["read_file"] = nil,
  ["create_file"] = {
    opts = {
      require_approval_before = false,
      require_comfirmation_after = true,
    },
  },
  ["delete_file"] = {
    opts = {
      require_approval_before = true,
      -- 要求在命令而不是工具层面的许可
      require_cmd_approval = true,
      allowed_in_yolo_mode = false,
      -- 支持在 YOLO 模式下由 LLM judge 是否可自动执行
      -- 由后台运行的 LLM 判断是否在 YOLO 中要求确认
      judge_in_yolo_mode = true,
    },
  },
  ["run_command"] = {
    opts = {
      require_approval_before = true,
      require_cmd_approval = true,
      allowed_in_yolo_mode = false,
      judge_in_yolo_mode = true,
    },
  },
  -- 在 `/memories` 目录下存储、读取信息
  ["memory"] = {
    opts = {
      -- 指定其他可访问目录、文件，缺省只有 `/memories` 目录
      whitelist = {
        { path = "./notes", as = "/notes" },
        { path = "~/gtd/todo.md", as = "todo.md" },
      },
    },
  },
  -- 允许 LLM 在执行动作前提问以澄清问题
  -- 默认隐藏，只在 `@{agent}` 工具组中提供
  ["ask_questions"] = nil,
  ["fetch_webpage"] = {
    opts = {
      adpater = "jina",
    },
  },
  ["file_search"] = {
    opts = {
      max_results = 500,
    },
  },
  ["get_changed_files"] = {
    opts = {
      max_lines = 1000,
    },
  },
  ["get_diagnostics"] = {
    opts = {
      serverity = "WARNING",
    },
  },
  ["grep_search"] = {
    enabled = function(adapter)
      return vim.fn.executable("rg") == 1  -- 插件要求 ripgrep
    end,
    opts = {
      max_files = 100,
      respect_gitignore = true,
      require_approval_before = true,
      require_cmd_approval = true,
      allowed_in_yolo_mode = true,
      auto_submit_errors = true,
      auto_submit_success = true,
    },
  },
  ["insert_edit_into_file"] = {
    opts = {
      patching_algorithm = nil,
      ["require_approval_before.buffer"] = false,
      ["require_approval_before.file"] = true,
      ["require_comfirmation_after"] = true,
    },
  },
  -- 查询 CodeCompanion 的文档
  ["search_help"] = nil,
  ["web_search"] = nil,
}
