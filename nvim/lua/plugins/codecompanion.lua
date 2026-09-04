-- ==========================================================================
-- File    : codecompanion.lua
-- Author  : xyy15926
-- Created : 2026-08-31 11:22:47
-- Updated : 2026-09-04 10:40:51
-- Desc    : Config of CodeCompanion.
--
-- Ref:
-- - codecompanion.nvim/lua/codecompanion/config.lua
-- ==========================================================================

require("plugins.codecompanion.addons").setup()

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
  cmd = {
    "CodeCompanionChat",
    "CodeCompanion",
    "CodeCompanionCLI",
    "CodeCompanionCmd",
  },
  keys = {
    { "<leader>al", "<cmd>CodeCompanionAction<cr>", mode = { "n", "x" }, desc = "Actions" },
    -- Chat
    { "<leader>an", "<cmd>CodeCompanionChat<cr>", mode = { "n", "x" }, desc = "New Chat" },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "x" }, desc = "Toggle Chat" },
    { "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", mode = "x", desc = "Add Code" },
    -- Code Review
    { "<leader>a+", "<cmd>CodeCompanionCodeReview Start<cr>", mode = "n", desc = "Review: Set Baseline" },
    { "<leader>ar", "<cmd>CodeCompanionCodeReview<cr>", mode = "n", desc = "Review: Start" },
    { "<leader>al", "<cmd>CodeCompanionCodeReview All<cr>", mode = "n", desc = "Review: Start with All" },
    { "<leader>ac", "<cmd>CodeCompanionCodeReview Comment<cr>", mode = "n", desc = "Review: Comment" },
    { "<leader>as", "<cmd>CodeCompanionCodeReview Share<cr>", mode = "n", desc = "Review: Share" },
    -- Inline Prompt
    { "<leader>aa", "<cmd>CodeCompanion<cr>", mode = { "n", "x" }, desc = "Prompt" },
    -- { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = "x", desc = "Explain Code" },
    -- { "<leader>ar", "<cmd>CodeCompanion /review<cr>", mode = "x", desc = "Review Code" },
  },
  opts = {
    opts = {
      log_level = "TRACE",
      chat_buffer_name = "codecompanion",
      save_chat = true,
      language = "Chinese",
    },
    -- Adapters 适配器：与 LLM、Agent 的连接（适配调用、参数控制、报文解析等）
    adapters = {
      -- ACP 适配器：连接 Agent CLI，仅适用于 `chat` 交互方式
      acp = {},
      -- HTTP 适配器：连接 LLM API
      http = require("plugins.codecompanion.adapters_http"),
    },
    -- 与 LLM、Agent 交互的方式
    interactions = {
      -- `CodeCompanionChat`：通过 buffer 与 LLM 对话
      chat = {
        adapter = {
          name = "openrouter_free",
          -- model = "z-ai/glm-5.2:free",
          model = "minimax/minimax-m3:free",
          -- model = "nvidia/nemotron-3-ultra-550b-a55b:free",
        },
        roles = {
          llm = function(adapter)
            return "CodeCompanion(" .. adapter.name .. ")"
          end,
          user = os.getenv("USER") or "USER",             -- 用户显示的名称
        },
        opts = require("plugins.codecompanion.interactions_opts").chat,
        keymaps = require("plugins.codecompanion.keymaps").chat,
        editor_context = require("plugins.codecompanion.editor_context"),
        slash_commands = require("plugins.codecompanion.slash_commands"),
        tools = require("plugins.codecompanion.tools"),
      },
      -- `CodeCompanion`：行内交互，输出直接写入当前 buffer
      -- 只有 prompt 被分类为 replace, add, before, new 时将 inline 更新，
      -- 若被分类为 chat 依然将打开 chat buffer
      inline = {
        adapter = "openrouter_free",
        keymaps = require("plugins.codecompanion.keymaps").inline,
      },
      -- `CodeCompanionCLI`：Agent CLI 工具的命令行封装
      cli = {
        agent = "opencode",
      },
      -- `CodeCompanionCmd`：在命令行创建 neovim 命令
      cmd = {
        adapter = "openrouter_free",
      },
      -- 执行后台任务
      -- - chat 回调：会话压缩、生成标题等
      -- - YOLO 许可
      background = {
        adapter = "openrouter_free",
        chat = require("plugins.codecompanion.background").chat,
        gates = require("plugins.codecompanion.background").gates,
      },
      -- Code Review 配置，包含独立的 display, keymaps
      code_review = require("plugins.codecompanion.codereview"),
      -- 共享配置，只有 keymaps, editor_context 两部分
      shared = {
        keymaps = require("plugins.codecompanion.keymaps").shared,
        editor_context = nil,
      },
    },
    display = require("plugins.codecompanion.display"),
    prompt_library = require("plugins.codecompanion.prompt_library"),
  },
}
