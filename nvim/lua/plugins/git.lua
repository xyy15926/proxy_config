-- lua/plugins/ui.lua 或新建 lua/plugins/git.lua
return {
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
          local opts = { buffer = bufnr }

          -- 跳转 hunk
          vim.keymap.set("n", "]h", gs.next_hunk,     opts)
          vim.keymap.set("n", "[h", gs.prev_hunk,     opts)

          -- 操作
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk,  opts)
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk,    opts)
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk,    opts)
          vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, opts)
          vim.keymap.set("n", "<leader>hb", gs.blame_line,    opts)
          vim.keymap.set("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts)
          vim.keymap.set("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts)
        end,
      })
    end,
  },
}
