-- ==========================================================================
-- File    : editor_context.lua
-- Author  : xyy15926
-- Created : 2026-09-02 11:39:28
-- Updated : 2026-09-02 21:57:25
-- Desc    : Editor context subsystem.
--
-- 编辑器上下文：快速插入 buffer、lsp、clipboard 等编辑器状态相关内容
-- 
-- #### 预定义 editor_context
--
-- 1. `#{buffer}` 同步指定 buffer（作为上下文），缺省当前（上个）buffer
-- 1.1. 指定 buffer：通过 `#{buffer:<ptn>}` 指定包含、是特定 ptn 名称的 buffer
-- 1.2. buffer 变动之后会自动同步
-- 1.2.1. `#{buffer}{diff}` 只同步 buffer 变动
-- 1.2.2. `#{buffer}{all}` 全量同步 buffer 变动
--
-- 2. `#{buffers} 同步全部当前已打开 buffer
-- 2.1. 被排除的 bufyptes、filetypes 将被过滤不同步
-- 2.2. buffer 变动之后会自动同步
--
-- 3. `#{code_review}` 同步通过 `:CodeCompanionReview Comment` 记录的
--   code review 评论
-- 3.1. Code review 将和文件、行范围、代码一起同步至 LLM
--
-- 4. `#{diagnostics}` 同步当前 buffer 的、来自 LSP 服务器的 diagnostic 信息
--
-- 5. `#{diff}` 同步当前 `git diff` 变动，包括 staged、unstaged 的变动
--
-- 6. `#{messages}` 同步 `:messages` 历史信息
--
-- 7. `#{quickfix}` 同步 quickfix 列表
--
-- 8. `#{selection}` 同步当前、最近可视选区
-- 8.1. 打开、toggle chat buffer 时，可视选区将更新
--
-- 9. `#{terminal}` 同步上次 terminal buffer 的输出
-- 9.1. 常用于同步 test/build 或其他命令行输出
--
-- 10. `#{viewport}` 同步当前屏幕上除 chat buffer 之外的内容
-- ==========================================================================

return {
  buffer = {
    opts = {
      default_params = "diff",  -- `all` 则默认同步整个 buffer
    },
  },
  buffers = {
    opts = {
      excluded = {},
    },
  },
}
