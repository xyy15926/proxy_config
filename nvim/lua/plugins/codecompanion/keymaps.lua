-- ==========================================================================
-- File    : keymaps.lua
-- Author  : xyy15926
-- Created : 2026-09-01 22:35:08
-- Updated : 2026-09-03 17:33:13
-- Desc    : Keymaps for codecompanion buffer.
--
-- ==========================================================================

return {
  -- Ref:
  -- - codecompanion/doc/usage/chat-buffer/index.md#keymaps
  -- - codecompanion/lua/codecompanion/config.lua
  chat = {
    options = { modes = { n = "?" } },
    send = { modes = { n = "<C-s>", i = "<C-s>" } },
    close = { modes = { n = "<C-c>", i = "<C-c>" } },
    _btw = { modes = { n = "gm" } },  -- 在流式输出过程中插入消息（doc 中是 `btw` 错的）
    stop = { modes = { n = "q" } },  -- 停止请求
    change_adapter = { modes = { n = "ga" } },
    clear = { modes = { n = "gq" } },  -- 清空聊天历史
  },
  inline = {
    accept_change = {
      modes = { n = "gda" },
      description = "Accept the suggested change",
    },
    reject_change = {
      modes = { n = "gdr" },
      opts = { nowait = true },
      description = "Reject the suggested change",
    },
    stop = {
      callback = "keymaps.stop",
      description = "Stop Request",
      modes = { n = "q" },
    },
  },
  shared = {
    keymaps = {
      always_accept = {
        callback = "keymaps.always_accept",
        modes = { n = "g1" },
      },
      accept_change = {
        callback = "keymaps.accept_change",
        modes = { n = "g2" },
      },
      reject_change = {
        callback = "keymaps.reject_change",
        modes = { n = "g3" },
      },
      next_hunk = {
        callback = "keymaps.next_hunk",
        modes = { n = "}" },
      },
      previous_hunk = {
        callback = "keymaps.previous_hunk",
        modes = { n = "{" },
      },
    },
  },
}
