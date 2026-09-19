-- ==========================================================================
-- File    : terminal.lua
-- Author  : xyy15926
-- Created : 2026-09-19 15:17:43
-- Updated : 2026-09-19 15:17:43
-- Desc    : Neovim terminal.
--
-- --------------------------------------------------------------------------
-- Neovim 中窗口分割
--
-- 1. 分割方向
-- vertical/vert      垂直分割
-- horizontal/hor     水平分割
-- 1.1. 指定方向时，`split`, `vsplit` 行为一致
--
-- 2. 分割出的新、活动窗口位置
-- topleft/to         最上、最左
-- botright/bo        最下、最右
-- 2.1. 未指定时，在当前窗口右、或下方分割
-- ==========================================================================

local M = {}

M.defaults = {
  position = "vertical botright",
  size = nil,
  set_keys = true,
}
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  Toggle temrinal 窗口
-- ==========================================================================
--- 拼接分割窗口、打开 terminal 命令
local function split_cmd()
  local cmd = M.opts.size
    and M.opts.position .. " " .. M.opts.size .. "split | temrinal"
    or M.opts.position .. " split | terminal"
  return cmd
end


--- toggle 当前 tabpage terminal
--- @param tabpage integer
function M.toggle_terminal(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)

  -- 当前 tabpage 里有终端窗口，关掉它（隐藏）
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  -- 当前 tabpage 没有终端窗口，找已有的终端 buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_is_loaded(buf) then
      vim.cmd("vertical botright split")
      vim.api.nvim_win_set_buf(0, buf)
      return
    end
  end

  -- 真的没有任何终端，才新建
  vim.cmd(split_cmd())
end


--- @deprecated Use `snacks.picker.buffer({ filter = { buftype = "terminal" } })` instead.
--- 列出全部 terminal buffers
function M.list_terminals()
  local terms = {}
  -- 收集所有 terminals buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      local cmd = name:match("term://(.-):") or name
      table.insert(terms, {
        buf = buf,
        display = string.format("[%d] %s", buf, cmd),
      })
    end
  end

  if #terms == 0 then
    vim.notify("No terminal buffers found", vim.log.levels.INFO)
    return
  end

  vim.ui.select(terms, {
    prompt = "Select terminal:",
    format_item = function(item)
      return item.display
    end,
  }, function(choice)
    if choice then
      vim.api.nvim_win_set_buf(0, choice.buf)
    end
  end)
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  vim.api.nvim_create_user_command("TermToggle", M.toggle_terminal, { desc = "Toggle Terminal" })
  vim.api.nvim_create_user_command("TermNew", function() vim.cmd(split_cmd()) end, { desc = "New Terminal" })
  if M.opts.set_keys then
    vim.keymap.set({ "n", "t", "i" }, "<m-t>", M.toggle_terminal, { desc = "Toggle Terminal"})
    vim.keymap.set("n", "<m-T>", function() vim.cmd(split_cmd()) end, { desc = "New Terminal"})
    -- 直接用 snacks.picker 获取 buffers 即可
  end
end

return M
