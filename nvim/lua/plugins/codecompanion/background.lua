-- ==========================================================================
-- File    : background.lua
-- Author  : xyy15926
-- Created : 2026-09-04 10:15:55
-- Updated : 2026-09-04 10:18:12
-- Desc    : Config for background.
--
-- 用于配置
-- - chat 下的针对 `on_ready`、`on_checkpoint` 的回调
-- - YOLO 下对命令执行的许可
-- ==========================================================================

return {
  chat = {
    callbacks = {
      ["on_ready"] = {
        actions = {
          "interactions.background.builtin.chat_make_title",
        },
      },
      enabled = true,
    },
    opts = {
      enabled = false,
    },
  },
  -- YOLO 许可审批
  gates = {
    judge = {
      enabled = true,
      opts = {
        system_prompt = nil,
        -- system_prompt = function(default) return default end,
      }
    },
  },
}
