-- ==========================================================================
-- File    : git.lua
-- Author  : xyy15926
-- Created : 2026-08-27 18:23:45
-- Updated : 2026-09-05 22:24:13
-- Desc    : Plugins related to git.
-- ==========================================================================

return {
  -- %%------------------ gitsigns：git 状态标签 -------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "-" },
        topdelete    = { text = "-" },
        changedelete = { text = "~" },
        untracked    = { text = "│" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- 工厂函数帮忙补充 `desc`
        local function opts(desc)
          return { buffer = bufnr, silent = true, desc = desc }
        end

        -- 跳转 hunk
        vim.keymap.set("n", "<leader>mu", gs.prev_hunk,     opts("Prev Hunk"))
        vim.keymap.set("n", "<leader>mg", gs.next_hunk,     opts("Next Hunk"))

        -- 操作
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk,  opts("Preview Hunk"))
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk,    opts("Stage Hunk"))
        vim.keymap.set("n", "<leader>gS", gs.stage_buffer,  opts("Stage Buffer"))
        vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts("Unstage Hunk"))
        vim.keymap.set("n", "<leader>gU", function()
          vim.fn.system("git restore --stage " .. vim.fn.expand("%"))
          vim.cmd("Gitsigns refresh")
        end, opts("Unstage Buffer"))
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk,    opts("Reset Hunk"))
        vim.keymap.set("n", "<leader>gR", gs.reset_buffer,  opts("Reset Buffer"))
        vim.keymap.set("n", "<leader>gb", gs.blame_line,    opts("Blame Line"))
        vim.keymap.set("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts("Stage Hunk Line"))
        vim.keymap.set("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts("Reset Hunk Line"))
      end,
    },
  },

  -- %%------------------ diffview：文件 diff 检阅 ------------------------
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    lazy = true,
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen --<cr>", desc = "Diffview Stage" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff Hist File" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diff Hist Repo" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diff Close" },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,  -- 用竖线分隔左右面板
      view = {
        -- 普通 diff 场合
        default = {
          layout = "diff2_horizontal",  -- base, now 左右分屏（水平排列）
          -- layout = "diff2_vertical",  -- base, now 上下分屏（垂直排列）
        },
        -- 合并冲突场合
        merge_tool = {
          layout = "diff3_mixed",  -- ours, base, theirs 三路对比布局
        },
        -- 查看提交历史场合
        file_history = {
          layout = "diff2_vertical",
        },
      },
      -- diff 文件导航栏
      file_panel = {
        listing_style = "list",  -- "tree" 或 "list"
        win_config = {
          position = "left",
          width = 25,
        },
      },
      -- git history 导航栏
      file_history_panel = {
        win_config = {
          position = "bottom",
          height = 10,
        },
        -- git log 展示格式
        log_options = {
          git = {
            -- 单文件 git log 历史
            single_file = {
              follow = true,  -- 跟踪文件重命名
              diff_merges = "combined",  -- merge commit 合并 diff
            },
            -- 多文件 git log 历史
            mutil_file = {
              follow = false,
              diff_merges = "first-parent",  -- merge commit 只展示 merge 发起侧 diff
            },
          },
        },
      },
      -- diffview 内快捷键
      keymaps = {
        -- Diffview 导航栏内快捷键
        view = {
        },
        file_panel = {
        },
        file_history_panel = {
        },
      },
    },
  }
}
