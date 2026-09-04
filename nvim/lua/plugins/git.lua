-- ==========================================================================
-- File    : git.lua
-- Author  : xyy15926
-- Created : 2026-08-27 18:23:45
-- Updated : 2026-09-03 22:44:23
-- Desc    : Plugins related to git.
-- ==========================================================================

return {
  -- -------------------- gitsigns（Git 状态标签）------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
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
          vim.keymap.set("n", "<leader>gr", gs.reset_hunk,    opts("Reset Hunk"))
          vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts("Undo Stage Hunk"))
          vim.keymap.set("n", "<leader>gb", gs.blame_line,    opts("Blame Line"))
          vim.keymap.set("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts("Stage Hunk Line"))
          vim.keymap.set("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts("Reset Hunk Line"))
        end,
      })
    end,
  },
}
