return {
  "stevearc/overseer.nvim",
  lazy = false,
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerRun",
    "OverseerTaskAction",
    "OverseerShell",
  },
  keys = {
    { "<leader>xx", "<cmd>OverseerToggle!<cr>", desc = "Toggle task list" },
    { "<leader>xe", "<cmd>OverseerRun<cr>", desc = "Run task" },
    { "<leader>xa", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
  },
  opts = {
    -- 注册模板：builtin 包含 cargo/npm/make 等；user.python 是自定义 Provider
    templates = {
      "builtin",
      "user.python",
    },

    -- 执行策略
    strategy = "terminal",

    -- 任务列表面板
    task_list = {
      direction = "right",
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

    -- 弹窗样式
    form = {
      border = "rounded",
      win_opts = { winblend = 0 },
    },
    task_win = {
      border = "rounded",
      win_opts = { winblend = 0 },
    },

    -- 组件别名（组件是 overseer 执行任务的钩子动作，别名即打包）
    component_aliases = {
      default = {
        -- "unique",                -- Task list 只显示一个同名任务
        "on_exit_set_status",
        "on_complete_notify",
        "on_complete_dispose",
      },
      run = {
        "on_exit_set_status",
        "on_complete_notify",
        -- "restart_on_save",
      },
      build = {
        { "on_output_quickfix", open = true, open_height = 8 },
        "on_exit_set_status",
        "on_complete_notify",
      },
      test = {
        { "on_output_quickfix", open = true, open_height = 8 },
        "on_exit_set_status",
        "on_complete_notify",
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
        local map = function(lhs, template_name, desc)
          vim.keymap.set("n", lhs, function()
            overseer.run_task({ name = template_name })
          end, { buffer = args.buf, desc = desc })
        end
        map("<leader>xb", "Python Build", "Python Build")
        map("<leader>xt", "Python Test", "Python Test")
        map("<leader>xr", "Python Run", "Python Run")
      end,
    })

    -- Rust 快捷键（使用内置 cargo 模板）
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function(args)
        local map = function(lhs, template_name, desc)
          vim.keymap.set("n", lhs, function()
            overseer.run_task({ name = template_name })
          end, { buffer = args.buf, desc = desc })
        end
        map("<leader>xb", "cargo build", "Cargo Build")
        map("<leader>xt", "cargo test", "Cargo Test")
        map("<leader>xr", "cargo run", "Cargo Run")
      end,
    })
  end,
}
