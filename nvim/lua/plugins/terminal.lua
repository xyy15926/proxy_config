-- ============================================================
-- terminal.lua
--   vim-slime              文件、终端桥接
--   vim-slime-cells        文件 cells 定义、高亮
--   vim-terminal-help      切换显示 terminal，配合 vim-slime
-- ============================================================

local root_flags = { ".root", ".svn", ".git", ".hg", ".project", "Makefile" }

return {

  -- -------------------- slime（保留）--------------------
  { "jpalardy/vim-slime", ft = { "python", "sh" }, pin = true,
    config = function()
      vim.g.slime_target = "neovim"
      vim.g.slime_cell_delimiter = "^#\\s*%%"
      vim.g.slime_preserve_curpos = 0
      vim.g.slime_vimterminal_config = {
        term_name = "vterm", term_cols = 70, vertical = 2, norestore = 1,
      }
      vim.g.slime_no_mappings = 1
    end },

  -- -------------------- vim-slime-cells（保留）--------------------
  { "Klafyvel/vim-slime-cells", ft = { "python", "sh" }, pin = true },

  -- -------------------- vim-terminal-help（保留）--------------------
  {
    "xyy15926/vim-terminal-help",
    pin = true,
    lazy = false,
    config = function()
      vim.g.terminal_rootmarkers = root_flags
      vim.g.terminal_key = "<m-=>"
      vim.g.terminal_default_mapping = 1
      vim.g.terminal_cwd = 2
      vim.g.terminal_vertical = 1
      vim.g.terminal_width = 78
      vim.g.terminal_close = 1

      -- SlimeOverrideConfig（保留原始 Vimscript）
      vim.cmd([[
        function! SlimeOverrideConfig(...)
          let target = slime#config#resolve("target")
          let bid = get(t:, "__terminal_bid__", -1)
          let alive = 0
          if bid > 0 && bufname(bid) != ''
            let alive = (bufwinnr(bid) > 0) ? 1 : 0
          endif
          if target == 'vimterminal' && bid > 0 && alive > 0
            if !exists("b:slime_config")
              let b:slime_config = {"bufnr": ""}
            endif
            let b:slime_config["bufnr"] = bid
          else
            return call("slime#targets#" . slime#config#resolve("target") . "#config", a:000)
          endif
        endfunction
      ]])
    end,
  },

  -- -------------------- asyncrun（保留）--------------------
  -- {
  --   "skywind3000/asyncrun.vim",
  --   ft = { "python", "cpp", "c", "rust" },
  --   config = function()
  --     vim.g.asyncrun_open = 8
  --     vim.g.asyncrun_bell = 0
  --     vim.g.asyncrun_rootmarks = root_flags
  --   end,
  -- },

}
