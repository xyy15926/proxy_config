-- ============================================================
-- globals.lua — 用户命令和辅助函数
-- ============================================================

-- 格式化命令
vim.api.nvim_create_user_command("Jsonf", function(opts)
  local cmd = "python -c 'import json,sys,collections; sys.stdout.write(json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2, ensure_ascii=False))'"
  vim.cmd(opts.line1 .. "," .. opts.line2 .. " !" .. cmd)
end, { range = true })

vim.api.nvim_create_user_command("Xmllint", function(opts)
  vim.cmd(opts.line1 .. "," .. opts.line2 .. " !xmllint --format --encode utf8 -")
end, { range = true })

-- 切换窗口（替代原 ToggleWindows，适配 nvim-tree）
function _G.ToggleWindows()
  for nr = 1, vim.fn.winnr("$") do
    if vim.fn.getwinvar(nr, "&pvw") == 1 then
      vim.cmd("pclose"); return
    end
    if vim.fn.getwinvar(nr, "&syntax") == "qf" then
      vim.cmd("cclose"); vim.cmd("lclose"); return
    end
    if vim.fn.getwinvar(nr, "&buftype") == "help" then
      vim.cmd(nr .. " wincmd c"); return
    end
    if vim.fn.getwinvar(nr, "&buftype") == "terminal" then
      vim.cmd(nr .. " wincmd c"); return
    end
    local buf = vim.fn.winbufnr(nr)
    if vim.bo[buf].filetype == "NvimTree" then
      vim.cmd("NvimTreeClose"); return
    end
  end

  if vim.t.__terminal_bid__ and vim.t.__terminal_bid__ > 0 then
    vim.cmd("call TerminalToggle()"); return
  end

  if #vim.fn.getqflist() > 0 then
    vim.cmd("copen")
  elseif #vim.fn.getloclist(0) > 0 then
    vim.cmd("lopen")
  end
end

vim.keymap.set("n", "<F12>", ToggleWindows, { silent = true })

-- View 管理
vim.api.nvim_create_user_command("Delview", function()
  local path = vim.fn.fnamemodify(vim.fn.bufname("%"), ":p")
  path = path:gsub("=", "==")
  if vim.env.HOME and vim.env.HOME ~= "" then
    path = path:gsub("^" .. vim.pesc(vim.env.HOME), "~")
  end
  path = path:gsub("/", "=+") .. "="
  path = vim.o.viewdir .. "/" .. path
  vim.fn.delete(path)
  print("Deleted: " .. path)
end, {})
