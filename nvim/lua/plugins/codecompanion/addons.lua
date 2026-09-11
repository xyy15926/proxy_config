-- ==========================================================================
-- File    : utils.lua
-- Author  : xyy15926
-- Created : 2026-09-03 17:07:41
-- Updated : 2026-09-11 19:34:27
-- Desc    : Utils for CodeCompanion.
-- ==========================================================================

local M = {}
M.defaults = {
  set_keymap = true,
}
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  Open chat buffer list.
-- ==========================================================================
local function list_chats()
  local entries = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == "codecompanion" then
      local label = "Chat " .. buf local path = vim.api.nvim_buf_get_name(buf)
      if path == "" then path = "[No name]" end
      table.insert(entries, {
        bufnr = buf,
        label = label .. "  — " .. path,
      })
    end  end

  if #entries == 0 then
    vim.notify("CodeCompanion: no chat buffers open", vim.log.levels.INFO)
    return
  end

  vim.ui.select(entries, {
    prompt = "Open chats (" .. #entries .. ")",
    format_item = function(
item) return item.label end,
  }, function(choice)
    if choice then
      vim.cmd("buffer " .. choice.bufnr)
    end
  end)
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  vim.api.nvim_create_user_command("CodeCompanionListChats", list_chats, {})
  if M.opts.set_keymap then
    vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionListChats<cr>", { desc = "Chat: List" })
  end
end

return M
