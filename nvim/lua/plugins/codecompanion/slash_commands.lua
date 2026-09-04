-- ==========================================================================
-- File    : slash_commands.lua
-- Author  : xyy15926
-- Created : 2026-09-02 11:41:04
-- Updated : 2026-09-02 16:14:12
-- Desc    : Slash commands.
--
-- Slash commands：快速插入预定义 prompt、添加文件等（除 editor_context 外）
--   作为上下文，包括
--   - `interactions.chat.slash_commands` 表项
--   - `prompt_library` 中 `opts.is_slash_cmd = true` 表项
--
-- #### 预定定义 slash commands
--
-- - `/buffer` 添加已打开 buffer 至 chat buffer
--   - 支持 native, telescope, mini.pick, fzf.lua, snacks.nvim 作为 provider，
--     支持一次性添加多个 buffer
--   - 适用于 CLI 模式，但将插入 `@path` 引用而不是 buffer 内容
--
-- - `/file` 插入当前工作目录下指定文件，不局限于已打开 buffer
--   - 支持 native, telescope, mini.pick, fzf.lua, snacks.nvim 作为 provider
--   - 文件内容在插入前可通过 context formatters 处理
--   - PDF 文件将使用 base64 编码
--   - 适用于 CLI 模式，但将插入 `@path` 引用而不是文件内容
--
-- - `/fork` 复制当前 chat buffer、复制历史信息、保持工具和上下文
--   - 常用于设定会话分支起始点，用于探索不同 prompts
--
-- - `/image` 插入远程 URL 或文件系统内图片
--   - 可配置 `opts.dirs` 作为默认查找目录
--   - 只支持 `snacks.nvim`、`vim.ui.select` 作为 provider
--
-- - `/rules` 添加 rules 组
--
-- - `/fetch` 插入 URL 内容
--   - 默认使用 jina.ai 解析网页内容为纯文本，
--   - 为方便，输出将被缓存至磁盘
--
-- - `/quickfix` 插入 quickfix 列表内容
--
-- - `/symbols` 插入 treesitter 解析得到的符号定义
--
-- - `/mcp` 启动、关闭 MCP 服务
--   - 影响所有 chat buffer
--
-- - `/now` 插入当前日期时间戳
--
-- - `/rename` 重命名会话，方便通过 action palette 切换 chat
--
-- - `/compact` 清除 chat buffer 历史消息，仅保留 summary 作为上下文
--
-- - `/share` 通过 Github Gist 分享对话
--
-- #### 仅适用于 ACP 适配器的 slash commands
--
-- - `/acp_session_options` 调整 ACP specification 中的配置
-- - `/command` 切换不同的适配器命令
-- - `/mode` 切换 ACP 适配器工作模式
-- - `/resume` 恢复 ACP 适配器会话
-- ==========================================================================


return {
  file = {
    opts = {
      -- 会尝试 `telescope`、`fzf_lua`、`mini_pick`、`snacks`、`default` 等
      provider = "default",
      keymaps = {
        modes = { i = "<C-f>", n = { "<C-f>", "gf" }},
      },
    },
  },
  image = {
    enabled = function(opts)
      return opts.adapters.opts and opts.adapters.opts.visioin == true
    end,
    -- 默认查找目录
    opts = {
      dirs = {}
    },
  },
  share = {
    opts = {
      token = os.getenv("GITHUB_GIST_TOKEN"),
    },
  },
  -- 自定义 Slash Command
  ["git_files"] = {
    description = "List git files",
    callback = function(chat)
      local handle = io.popen("git ls-files")
      if handle ~= nil then
        local result = handle:read("*a")
        handle:close()
        -- 将内容添加进对话
        chat:add_context(
          { role = "user", content = result },
          "git",  -- _meta.tag
          "<git_files>"  -- context.id
        )
      else
        return vim.notify(
          "Not git files available",
          vim.log.levels.INFO,
          { title = "CodeCompanion" }
        )
      end
    end,
    opts = {
      contains_code = false,
    },
  },
}
