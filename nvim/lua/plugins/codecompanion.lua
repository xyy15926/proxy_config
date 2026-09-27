-- ==========================================================================
-- File    : codecompanion.lua
-- Author  : xyy15926
-- Created : 2026-08-31 11:22:47
-- Updated : 2026-09-27 22:11:25
-- Desc    : Config of CodeCompanion.
--
-- Ref:
-- - lazy/codecompanion.nvim/lua/codecompanion/config.lua
-- - lazy/codecompanion.nvim/doc/usage/introduction.md
-- - lazy/codecompanion.nvim/doc/usage/chat-buffer/index.md
-- - lazy/codecompanion.nvim/doc/usage/inline.md
-- - lazy/codecompanion.nvim/doc/usage/action-palette.md
-- - lazy/codecompanion.nvim/doc/configuration/chat-buffer.md
-- - lazy/codecompanion.nvim/doc/configuration/inline.md
-- - lazy/codecompanion.nvim/doc/configuration/system-prompt.md
--
-- --------------------------------------------------------------------------
-- `adapters` 适配器：与 LLM, Agent 连接适配（调用、参数控制、报文解析等）
--
-- 1. `adapters.acp` ACP 适配器：连接 Agent CLI，仅适用于 `chat` 交互方式
-- 2. `adapters.http` HTTP 适配器：连接 LLM API
--
-- --------------------------------------------------------------------------
-- `interactions` 与 LLM, Agent 交互的方式
--
-- 1. `chat` 对话模式：通过编辑 chat buffer 作为对话的方式进行交互
-- 1.1. 对应 `CodeCompanionChat` 命令
--
-- 2. `inline` 行内模式：通过 Ex 命令行、或弹出的输入框直接输入 prompt 进行
--   交互
-- 2.1. inline 仅指首次交互时无需启动 chat buffer 进行对话，即可与 LLM 交互
-- 2.2. 模型的 response 将被分类为 replace, add, before, new, chat 5 种类别，
--   若分类为 chat，将打开 chat buffer 进行后续交互
--
-- 3. `cli` CLI 模式：Agent CLI 工具的封装
--
-- 4. `cmd` CMD 模式：neovim 命令的 shell 命令行封装
--
-- 5. `background` 后台模式：执行后台任务
-- 5.1. `background.chat` chat 回调：配置会话压缩、标题等 
-- 5.2. `background.gates` YOLO 许可：配置 YOLO 模式下使用额外 LLM 评估 tools
--   的使用许可
--
-- 6. `code_review` review 模式
-- 6.1. 包含独立的 display, keymaps
--
-- 7. `shared` 共享配置：除 inline 模式外的共享配置
-- 7.1. 目前仅包含 `shared.keymaps`, `shared.editor_context`
-- 7.2. 即 `shared` 中 keymaps, editor_context 在 inline 命令行、输入框中
--   不可用
--
-- --------------------------------------------------------------------------
-- `prompt_library` 提示词库
-- 1. `prompt_library` 仅包含快捷提示词，通过 action-palette、或 slash command
--   方式快速插入预定义提示词，类似 snippets
-- 1.1. prompt 中的提示词，可以包含 system 角色提示词，但与 chat、tool 中
--   `system_prompt` 配置无关
-- 1.2. 仅在 `ignore_system_prompt` 置位时，默认 `system_prompt` 不插入对话
--
-- --------------------------------------------------------------------------
-- `opts.triggers` 子系统触发器：通过引导字符快速插入预定义内容
--
-- 1. `acp_slash_commands = "\\"` ACP 适配器情况下，执行 Agent 命令
-- 2. `editor_context = "#"` 编辑器相关上下文，包括 buffer, diag, selection 等
-- 3. `slash_commands = "/"` 快速添加上下文，包括原生 slash command、prompts
--   两类
-- 4. `tools = "@"` 工具或工具集，供 LLM 选择、使用
-- ==========================================================================

require("plugins.codecompanion.addons").setup({ set_keymap = true })

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = true,
  cmd = {
    "CodeCompanionChat",
    "CodeCompanion",
    "CodeCompanionCLI",
    "CodeCompanionCmd",
  },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionAction<cr>", mode = { "n", "x" }, desc = "Prompt: Actions" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "x" }, desc = "Prompt: Input" },
    -- Chat
    { "<leader>an", "<cmd>CodeCompanionChat<cr>", mode = { "n", "x" }, desc = "Chat: New" },
    { "<leader>as", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "x" }, desc = "Chat: Toggle" },
    { "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", mode = "x", desc = "Chat: Add Code" },
    -- Code Review
    { "<leader>a+", "<cmd>CodeCompanionCodeReview Start<cr>", mode = "n", desc = "Review: Set Baseline" },
    { "<leader>ar", "<cmd>CodeCompanionCodeReview<cr>", mode = "n", desc = "Review: Start" },
    { "<leader>aR", "<cmd>CodeCompanionCodeReview All<cr>", mode = "n", desc = "Review: Start with All" },
    { "<leader>am", "<cmd>CodeCompanionCodeReview Comment<cr>", mode = "n", desc = "Review: Comment" },
    { "<leader>aS", "<cmd>CodeCompanionCodeReview Share<cr>", mode = "n", desc = "Review: Share" },
    -- Inline Prompt
    -- `:CodeCompanion` 命令直接执行
    { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = "x", desc = "Predef: Explain Code" },
    { "<leader>ar", "<cmd>CodeCompanion /review<cr>", mode = "x", desc = "Predef: Review Code" },
    { "<leader>af", "<cmd>CodeCompanion /fix_chat<cr>", mode = "x", desc = "Predef: Fix Chat" },
    { "<leader>aF", "<cmd>CodeCompanion /fix_inplace<cr>", mode = "x", desc = "Predef: Fix Inplace" },
    { "<leader>ah", "<cmd>CodeCompanion /lsp_explain<cr>", mode = "x", desc = "Predef: Explain Diag" },
  },
  opts = {
    opts = {
      log_level = "TRACE",
      language = "Chinese",
      per_project_config = {
        enabled = true, -- Enable per-project configuration?
        files = {}, -- Files in the cwd that contain project configuration
        paths = {}, -- Per-path config: { ["~/Code/myproject"] = { ... } }
      },
      send_code = true,  -- 复位时，所有标记 `contains_code` 的 prompt 将不会发送
      submit_delay = 500, -- Delay in milliseconds before auto-submitting the chat buffer
      -- 各子系统触发器
      triggers = {
        acp_slash_commands = "\\",
        editor_context = "#",
        slash_commands = "/",
        tools = "@",
      },
    },
    adapters = {
      acp = {},
      http = require("plugins.codecompanion.adapters_http"),
    },
    -- %% interactions 配置 =================================================
    interactions = {
      opts = {
        date_format = "%Y-%m-%d %A",
      },
      chat = {
        adapter = {
          name = "openrouter_free",
          model = "z-ai/glm-5.2:free",
          -- model = "minimax/minimax-m3:free",
          -- model = "nvidia/nemotron-3-ultra-550b-a55b:free",
          -- model = "nex-agi/nex-n2.5-pro:free",
        },
        roles = {
          llm = function(adapter)
            return "CodeCompanion(" .. adapter.name .. ")"
          end,
          user = os.getenv("USER") or "USER",             -- 用户显示的名称
        },
        opts = {
          completion_provider = "blink",
          -- 上下文管理
          context_management = {
            -- 移除历史工具输出
            editing = {
              trigger = 0.65,  -- 触发阈值
              execlude_tools = { "memory" },  -- 豁免指定工具输出
              keep_cycles = 3,  -- 保留最近 3 轮次工具输出
            },
            -- 总结、压缩会话
            compaction = {
              trigger = 0.85,  -- 触发阈值
              min_token_savings = 10000,  -- 压缩至少 tokens 数才执行
              adapter = nil,  -- 会话压缩适配器
              fallback_to_chat_adapter = false,
            },
            enabled = function(adapter)
              if adapter.type ~= "http" then
                return false
              end
              return true
            end,
          },
          -- 总是同步内容变动的文件类型（后缀）
          -- `#{buffer}` 只同步缓冲区的变动，但 `sync_diff` 支持同步 `/file` 添加的非缓冲区文件
          sync_diff = {
            ipynb = true,
            sqlite = true,
          },
          register = "\"",
          wait_timeout = 2e6,  -- 等待用户响应的时间
          system_prompt = require("plugins.codecompanion.system_prompts").system_prompt,
        },
        keymaps = require("plugins.codecompanion.keymaps").chat,
        slash_commands = require("plugins.codecompanion.slash_commands"),
        tools = require("plugins.codecompanion.tools"),
      },
      inline = {
        adapter = "openrouter_free",
        keymaps = require("plugins.codecompanion.keymaps").inline,
        editor_context = require("plugins.codecompanion.editor_context").inline,
      },
      cli = {
        agent = "opencode",
      },
      cmd = {
        adapter = "openrouter_free",
      },
      background = {
        adapter = "openrouter_free",
        chat = require("plugins.codecompanion.background").chat,
        gates = require("plugins.codecompanion.background").gates,
      },
      code_review = require("plugins.codecompanion.codereview"),
      shared = {
        keymaps = require("plugins.codecompanion.keymaps").shared,
        editor_context = require("plugins.codecompanion.editor_context").shared,
      },
    },
    display = require("plugins.codecompanion.display"),
    prompt_library = require("plugins.codecompanion.prompt_library"),
  },
}
