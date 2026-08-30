-- ==========================================================================
-- File    : heading_file.lua
-- Author  : xyy15926
-- Created : 2026-08-28 10:39:09
-- Updated : 2026-08-28 17:26:53
-- Desc    : Add and update heading for scripts.
-- ==========================================================================

local M = {}

M.defaults = {
  auto_file_ptns = {
    "*.py",
    "*.rs",
    "*.lua",
    "*.md",
    "*.c", "*.cpp", "*.h",
    "*.sh",
  },
}
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  更新 heading
-- ==========================================================================
---检查文件前 lineno 行，更新 `Updated`、`updated` 引导的时间戳
---@param lineno integer
function M.update_timestamp(lineno)
  local buf = vim.api.nvim_get_current_buf()
  local total = vim.api.nvim_buf_line_count(buf)
  local limit = math.min(lineno or 30, total)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, limit, false)
  local now = os.date("%Y-%m-%d %H:%M:%S")
  local ts_pattern = "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d"

  for i, line in ipairs(lines) do
    if line:match("[Uu]pdated") and line:match(ts_pattern) then
      local new_line = line:gsub(ts_pattern, now, 1)
      vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { new_line })
      break
    end
  end
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  local header_group = vim.api.nvim_create_augroup("heading_file", { clear = true })

  vim.api.nvim_create_autocmd("BufNewFile", {
    group = header_group,
    pattern = M.opts.auto_file_ptns,
    callback = function()           -- Neovim 中 filetype 设置在此 autocmd 后执行，直接执行则 `ft` 为空值
      vim.schedule(function()       -- 故需再包装一层 `vim.schedule` 确保文件完全打开后执行
        local ls = require("luasnip")
        local ft = vim.bo.filetype  -- 所有文件类型的首个 snippets 均为文件模板
        if ls.get_snippets(ft)[1] then
          ls.snip_expand(ls.get_snippets(ft)[1])
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
    group = header_group,
    pattern = M.opts.auto_file_ptns,
    callback = function() M.update_timestamp(30) end,
  })

end

return M
