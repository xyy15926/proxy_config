-- ============================================================
-- navigation.lua
--   which-key          替代 vim-which-key
-- ============================================================

return {
  -- -------------------- which-key（替代 vim-which-key）--------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        layout = { height = { min = 4, max = 25 }, width = { min = 20, max = 50 }, spacing = 2, align = "center" },
      })

      -- ================ Leader (;) Normal ================

      -- ;w windows（不变）
      wk.add({
        { "<leader>w",  group = "windows" },
        { "<leader>ww", "<C-W>w",    desc = "other-window" },
        { "<leader>wd", "<C-W>c",    desc = "delete-window" },
        { "<leader>w-", "<C-W>s",    desc = "split-below" },
        { "<leader>w|", "<C-W>v",    desc = "split-right" },
        { "<leader>w2", "<C-W>v",    desc = "double-columns" },
        { "<leader>wh", "<C-W>h",    desc = "window-left" },
        { "<leader>wj", "<C-W>j",    desc = "window-below" },
        { "<leader>wl", "<C-W>l",    desc = "window-right" },
        { "<leader>wk", "<C-W>k",    desc = "window-up" },
        { "<leader>wH", "<C-W>5<",   desc = "expand-left" },
        { "<leader>wJ", ":resize +5", desc = "expand-below" },
        { "<leader>wL", "<C-W>5>",   desc = "expand-right" },
        { "<leader>wK", ":resize -5", desc = "expand-up" },
        { "<leader>w=", "<C-W>=",    desc = "balance" },
        { "<leader>ws", "<C-W>s",    desc = "split-below" },
        { "<leader>wv", "<C-W>v",    desc = "split-right" },
        { "<leader>wm", "<C-W>m",    desc = "zoom" },
      })

      -- ;b buffer（不变）
      wk.add({
        { "<leader>b",  group = "buffer" },
        { "<leader>b1", ":b1",        desc = "buffer 1" },
        { "<leader>b2", ":b2",        desc = "buffer 2" },
        { "<leader>bd", ":bd",        desc = "delete-buffer" },
        { "<leader>bf", ":bfirst",    desc = "first-buffer" },
        { "<leader>bh", ":Alpha",     desc = "home-buffer" },
        { "<leader>bl", ":blast",     desc = "last-buffer" },
        { "<leader>bn", ":bnext",     desc = "next-buffer" },
        { "<leader>bp", ":bprevious", desc = "previous-buffer" },
      })

      -- ;n tree-content（NERDTree→nvim-tree, tagbar→aerial, Leaderf→telescope）
      wk.add({
        { "<leader>n",  group = "tree-content" },
        { "<leader>nn", "<cmd>NvimTreeToggle<cr>",       desc = "toggle-nvimtree" },
        { "<leader>nl", "<cmd>NvimTreeFindFile<cr>",     desc = "find-in-nvimtree" },
        { "<leader>nt", "<cmd>AerialToggle<cr>",         desc = "toggle-aerial" },
        { "<leader>nf", "<cmd>Telescope find_files<cr>", desc = "find-file" },
        { "<leader>nh", "<cmd>MundoToggle<cr>",          desc = "undo-tree" },
      })

      -- ;s send-source-fix（YCM/ALE→LSP/nvim-lint/conform）
      wk.add({
        { "<leader>s",  group = "send-source-fix" },
        { "<leader>sl", "<Plug>SlimeLineSend",   desc = "send-line" },
        { "<leader>sc", "<Plug>SlimeSendCell",   desc = "send-cell" },
        { "<leader>sm", "<Plug>SlimeCellsSendAndGoToNext",  desc = "send-cell-and-move" },
        { "<leader>sl", "<Plug>SlimeRegionSend`>", desc = "send-region", mode = "x" },

        { "<leader>sd", vim.diagnostic.open_float,        desc = "diagnostic" },
        { "<leader>sr", vim.lsp.buf.code_action,          desc = "code-action" },
        { "<leader>ss", function() require("lint").try_lint() end,                    desc = "lint" },
        { "<leader>sf", function() require("conform").format({ async = true }) end,   desc = "format" },
      })

      -- ;f find（LeaderF→telescope, gtags→LSP）
      wk.add({
        { "<leader>f",   group = "find" },
        { "<leader>fj",  "<cmd>Telescope resume<cr>",                desc = "telescope-resume" },
        { "<leader>ff",  "<cmd>Telescope find_files<cr>",            desc = "find-files" },
        { "<leader>fb",  "<cmd>Telescope buffers<cr>",               desc = "buffers" },
        { "<leader>fm",  "<cmd>Telescope oldfiles<cr>",              desc = "mru" },
        { "<leader>fl",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "line" },
        { "<leader>fq",  "<cmd>Telescope quickfix<cr>",              desc = "quickfix" },

        { "<leader>fc",  "<cmd>Telescope lsp_document_symbols<cr>",  desc = "lsp-symbols" },
        { "<leader>fd",  "<cmd>Telescope lsp_definitions<cr>",       desc = "lsp-definition" },
        { "<leader>fr",  "<cmd>Telescope lsp_references<cr>",        desc = "lsp-reference" },
        { "<leader>ft",  "<cmd>Telescope lsp_document_symbols<cr>",  desc = "buf-tag" },

        { "<leader>fg",  "<cmd>Telescope live_grep<cr>",             desc = "rg-global" },
        { "<leader>hd",  function()
            require("telescope.builtin").grep_string({ only_current_buffer = true })
          end, desc = "rg-cbuf" },
        { "<leader>fj",  function()
            require("telescope.builtin").grep_string({ default_text = vim.fn.expand("<cword>") })
          end, desc = "rg-selection" },

        { "<leader>fp",  function() vim.diagnostic.jump({ count = -1 }) end,  desc = "diag-prev" },
        { "<leader>fn",  function() vim.diagnostic.jump({ count = 1 }) end,   desc = "diag-next" },
      })

      -- ;g goto-desc（YCM→LSP）
      wk.add({
        { "<leader>g",   group = "goto-desc" },
        { "<leader>gg",  function()
            vim.cmd("tab split")
            vim.lsp.buf.definition()
          end, desc = "goto-def-tab" },
        { "<leader>gt",  function()
            vim.cmd("rightbelow vsplit")
            vim.lsp.buf.definition()
          end, desc = "goto-def-vsplit" },
        { "<leader>gdw", vim.lsp.buf.hover,  desc = "hover-doc" },
        { "<leader>gdp", vim.lsp.buf.hover,  desc = "hover-doc" },
      })

      -- ;m movement（NextError→vim.diagnostic）
      wk.add({
        { "<leader>m",  group = "movement" },
        { "<leader>mn", function() vim.diagnostic.jump({ count = 1 }) end,  desc = "next-diagnostic" },
        { "<leader>mp", function() vim.diagnostic.jump({ count = -1 }) end, desc = "prev-diagnostic" },
        { "<leader>mt", function() vim.diagnostic.open_float() end,         desc = "current-diagnostic" },
        { "<leader>me", "`.",  desc = "last-edit" },
        { "<leader>mm", "`m",  desc = "to-markm" },
        { "<leader>mc", "<Plug>SlimeCellsNext", desc = "next-cell" },
        { "<leader>mv", "<Plug>SlimeCellsPrev", desc = "prev-cell" },
      })

      -- ;c colorscheme
      wk.add({
        { "<leader>c",  group = "colorscheme" },
        { "<leader>cc", "<cmd>Telescope colorscheme<CR>", desc = "switch colorscheme" },
        { "<leader>ct", function() require("colorscheme_options").toggle_transparent() end, desc = "toggle transparent" },
      })

      -- ;x overseer tasks
      wk.add({
        { "<leader>x",  group = "build-run" },
        { "<leader>xx", desc = "toggle task-list" },
        { "<leader>xe", desc = "choose tasks" },
        { "<leader>xb", desc = "build" },
        { "<leader>xt", desc = "test" },
        { "<leader>xr", desc = "run" },
        { "<leader>xa", desc = "task action" },
      })

      -- ;a avante AI assistant（具体快捷键由 avante 默认、自行设置）
      wk.add({
        { "<leader>a", group = "avante" },
      })

      -- ;u tiny-func（不变）
      wk.add({
        { "<leader>u",  group = "tiny-func" },

        { "<leader>ur", "<cmd>Markview toggle<cr>", desc = "toggle render", },
        { "<leader>ut", "<cmd>Tableize<cr>", desc = "tableize", mode = "x", },
        { "<leader>ut", "<cmd>TableModeToggle<cr>", desc = "table-mode" },
        { "<leader>us", ":source $MYVIMRC<cr>", desc = "reload-config" },

        { "<leader>uq", function() vim.fn.setqflist({}) end, desc = "clean-qf" },

        { "<leader>up", "\"+p", desc = "paste from +"},
        { "<leader>uy", "\"+y", desc = "copy into +", mode = "x"},
        { "<leader>uyy", "\"+yy", desc = "copy curline into +"},
        -- { "<leader>uy", ":<C-u>'<,'>w !xargs -0 tmux set-buffer<CR><CR><C-b>:selectp -t", desc = "copy into tmux", mode = "x", silent = true },
      })
    end,
  },
}
