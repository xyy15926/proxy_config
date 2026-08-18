-- ==============================================
-- Avante: emulate the behavior of the Cursor AI IDE
-- Ref:
-- - https://github.com/yetone/avante.nvim
-- ==============================================

return {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false,
  opts = {
    instructions_file = "avante.md",    -- file containing specific instructions for your project
    provider = "openrouter",
    auto_suggestions_provider = "openrouter",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
      },
      moonshot = {
        endpoint = "https://api.moonshot.ai/v1",
        model = "kimi-k2-0711-preview",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },
      openrouter = {
        __inherited_from = "openai",        -- 继承 OpenAI 协议
        endpoint = "https://openrouter.ai/api/v1",
        model = "cohere/north-mini-code:free",
        api_key_name = "OPENROUTER_API_KEY",
        timeout = 30000,    -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 8192,
        },
      },
    },
  },
  dual_boost = {
    enabled = false,
    first_provider = "deepseekv4",
    second_provider = "mimov2.5",
  },
  behaviour = {
    auto_suggestions = false,                           -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,                               -- Whether to remove unchanged lines when applying a code block
    enable_token_counting = true,                       -- Whether to enable token counting. Default to true.
    auto_add_current_file = true,                       -- Whether to automatically add the current file when opening a new chat. Default to true.
    auto_approve_tool_permissions = {"str_replace"},    -- Default: auto-approve all tools (no prompts)
    -- Examples:
    -- auto_approve_tool_permissions = false,           -- Show permission prompts for all tools
    -- auto_approve_tool_permissions = {"bash", "str_replace"}, -- Auto-approve specific tools only
    ---@type "popup" | "inline_buttons"
    confirmation_ui_style = "inline_buttons",
    --- Whether to automatically open files and navigate to lines when ACP agent makes edits
    ---@type boolean
    acp_follow_agent_locations = true,
  },
  prompt_logger = {                                     -- logs prompts to disk (timestamped, for replay/debugging)
    enabled = true,                                     -- toggle logging entirely
    log_dir = vim.fn.stdpath("cache") .. "/avante_prompts", -- directory where logs are saved
    fortune_cookie_on_success = false,                  -- shows a random fortune after each logged prompt (requires `fortune` installed)
    next_prompt = {
      normal = "<C-n>",                                 -- load the next (newer) prompt log in normal mode
      insert = "<C-n>",
    },
    prev_prompt = {
      normal = "<C-p>",                                 -- load the previous (older) prompt log in normal mode
      insert = "<C-p>",
    },
  },
  windows = {
    position = "right",
    wrap = true,
    width = 70,
    ask = {
      floating = false,
      start_insert = true,
      focus_on_apply = "ours",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    -- reader-markdown 效果不如 markview，此处删除对 markdown 文件支持
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "Avante" } },
      ft = { "Avante" },
    },
  },
}
