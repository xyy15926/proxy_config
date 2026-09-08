-- ==========================================================================
-- File    : terminal.lua
-- Author  : xyy15926
-- Created : 2026-08-30 15:34:38
-- Updated : 2026-09-07 10:20:52
-- Desc    : Plugins for vim-terminal.
-- Plugins : 
--   vim-slime              文件、终端桥接
--   vim-slime-cells        配合 vim-slime 的 cells 定义、高亮、快速选区
--   vim-terminal-help      切换显示 terminal
-- ==========================================================================

return {
  -- ----------------------------- slime ------------------------------------
  {
    "jpalardy/vim-slime",
    -- `ft`、`cmd`、`event` 等字段只用于告知 lazyvim 加载插件的时点
    -- `keys` 除告知 lazyvim 相应快捷键按下后应加载此插件外，还会配置对应映射
    ft = { "python", "sh", "lua" },
    cmd = { "SlimeConfig" },
    keys = {
      -- `<Plug>` 可视为是 "虚拟目标按键“，插件内部将 `<Plug>xxxx` 绑定到某个函数、命令
      -- 后续，可以自由再将其他按键绑定到 `<Plug>xxxx`
      -- 故此时必须设置 `remap = true`？
      -- 但，事实上此处设置 `remap = false` 依然工作，之前在 Vim 中也是如此
      { "<leader>rs", "<Plug>SlimeLineSend", desc = "Slime: Send Line", remap = true },
      { "<leader>rs", "<Plug>SlimeRegionSend", desc = "Slime: Send Region", mode = "x", remap = true },
      { "<leader>rc", "<Plug>SlimeSendCell", desc = "Slime: Send Cell", mode = "n", remap = true },
      { "<leader>rm", function()
        vim.fn["slime#send_cell"]()
        require("users.mark_jump").next_mark()
      end, desc = "Sime: Send&Move", mode = "n" },
    },
    config = function()
      vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = 1
      -- 全局 cell 分隔符，故上述 `SlimeSendCell` 也配置有全局映射
      vim.g.slime_cell_delimiter = "^#\\s*%%"
      -- 同时，根据 `users.mark_jump` 获取块分割符
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("SetSlimeCellDelimiter", { clear = true }),
        pattern = { "python", "sh", "lua" },
        callback = function()
          local escaped = require("users.mark_jump").get_patterns()[1]
          -- 将 lua 已转义的匹配模式转换为普通字符串
          local plain = escaped:gsub("%%(.)", "%1")
          -- vim.notify("Set cell delimiter: " .. plain)
          vim.b.slime_cell_delimiter = plain
        end,
      })
      vim.g.slime_preserve_curpos = 1
      vim.g.slime_vimterminal_config = {
        term_name = "vterm",
        term_cols = 78,
        vertical = 2,
        norestore = 1,
      }
    end
  },

  ------------------------- vim-slime-cells ------------------------------
  {
    "Klafyvel/vim-slime-cells",
    requires = {
      { "jpalardy/vim-slime", opt = true }
    },
    ft = { "python", "sh" },
    enabled = false,
    -- cells 全局分隔符、keymapping 已在 vim-slime 中配置，此处仅保留局部
    keys = {
      { "<leader>rm", "<Plug>SlimeCellsSendAndGoToNext", desc = "Send Cell & Move", remap = true },
      { "<leader>mc", "<Plug>SlimeCellsNext", desc = "Next Cell", remap = true },
      { "<leader>mv", "<Plug>SlimeCellsPrev", desc = "Prev Cell", remap = true },
    },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("VimSlimeDelimiter", { clear = true }),
        pattern = "python",
        callback = function()
          -- buffer 局部分割符，相应也再配置一次映射
          vim.b.slime_cell_delimiter = "^#\\s*%%"
          vim.keymap.set("n", "<leader>rc", "<Plug>SlimeSendCell", { desc = "Send Cell", remap = true, buffer = true })
          vim.keymap.set("n", "<leader>rm", "<Plug>SlimeCellsSendAndGoToNext", { desc = "Send Cell & Move", remap = true, buffer = true})
        end,
      })
    end,
  },

  -- -------------------- vim-terminal-help ---------------------------------
  {
    "xyy15926/vim-terminal-help",
    lazy = false,
    config = function()
      vim.g.terminal_rootmarkers = require("users.rooter").opts.root_flags
      vim.g.terminal_key = "<m-=>"
      vim.g.terminal_default_mapping = 1
      vim.g.terminal_cwd = 2
      vim.g.terminal_vertical = 1
      vim.g.terminal_width = 78
      vim.g.terminal_close = 1

      -- SlimeOverrideConfig（保留原始 Vimscript）
      -- Ref:
      -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/advanced.md#advanced-configuration-overrides
      -- vim.cmd([[
      --   function! SlimeOverrideConfig(...)
      --     let target = slime#config#resolve("target")
      --     let bid = get(t:, "__terminal_bid__", -1)
      --     let alive = 0
      --     if bid > 0 && bufname(bid) != ""
      --       let alive = (bufwinnr(bid) > 0) ? 1 : 0
      --     endif
      --     if (target == "vimterminal" || target == "neovim") && bid > 0 && alive > 0
      --       if !exists("b:slime_config")
      --         let b:slime_config = {"bufnr": ""}
      --       endif
      --       let b:slime_config["bufnr"] = bid
      --     else
      --       return call("slime#targets#" . slime#config#resolve("target") . "#config", a:000)
      --     endif
      --   endfunction
      -- ]])
    end,
  },

}
