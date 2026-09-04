-- ==========================================================================
-- File    : interactions_opts.lua
-- Author  : xyy15926
-- Created : 2026-09-02 11:36:53
-- Updated : 2026-09-02 22:15:42
-- Desc    : Opts for chat, inline, cmd modes in interactions.
-- ==========================================================================

-- 非 prompt 内容相关整体配置
return {
  chat = {
    completion_provider = "blink",
    -- 4 个子系统触发器
    triggers = {
      acp_slash_commands = "\\",
      editor_context = "#",
      slash_commands = "/",
      tools = "@",
    },
    -- 上下文管理
    context_management = {
      -- 移除历史工具输出
      editing = {
        trigger = 0.65,  -- 触发阈值
        execlude_tools = { "memory" },  -- 豁免指定工具输出
        keep_cycles = 3,  -- 保留最近 3 轮次工具输出
      },
      -- 总结、压缩会话
      compaction = {
        trigger = 0.85,  -- 触发阈值
        min_token_savings = 10000,  -- 压缩至少 tokens 数才执行
        adapter = nil,  -- 会话压缩适配器
        fallback_to_chat_adapter = false,
      },
      enabled = function(adapter)
        if adapter.type ~= "http" then
          return false
        end
        return true
      end,
    },
    -- 系统 prompt
    -- system_prompt = function()
    --   return string.format(
    --     "你是一个在 Neovim 编辑器中运行的 AI 编程助手。"
    --     .. "你的当前工作目录是：%s。"
    --     .. "你正在使用的语言服务器(LSP)可能提供诊断信息，请结合这些信息理解代码问题。"
    --     .. "回答要简洁、准确、可直接使用。",
    --     vim.fn.getcwd()
    --   )
    -- end,
    -- 用户 prompt 额外装饰
    prompt_decorator = function(message, adapter, context)
      return string.format([[<prompt>%s</prompt>]], message)
    end,
    -- 总是同步内容变动的文件类型（后缀）
    -- `#{buffer}` 只同步缓冲区的变动，但 `sync_diff` 支持同步 `/file` 添加的非缓冲区文件
    sync_diff = {
      ipynb = true,
      sqlite = true,
    },
  },
}
