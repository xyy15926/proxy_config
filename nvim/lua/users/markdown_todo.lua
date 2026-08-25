-- ================================================
-- 快速切换 markdown 待办、切换待办
-- ================================================

local M = {}

M.defaults = {
  convert = true
}

M.opts = vim.deepcopy(M.defaults)

-- 将行文本转换为 `[]` todo 项、切换状态
function M.toggle_line_todo(line, convert)
  local new_line = line

  -- 1. 已有 checkbox 则切换：- [ ] <-> - [x]
  new_line = line:gsub("^([%s]*[-*+][%s]+)%[([ xX])%]", function(prefix, status)
    return prefix .. "[" .. (status == " " and "x" or " ") .. "]"
  end)

  -- 2. 有序列表 checkbox 切换：1. [ ] <-> 1. [x]
  if new_line == line then
    new_line = line:gsub("^([%s]*%d+%.[%s]+)%[([ xX])%]", function(prefix, status)
      return prefix .. "[" .. (status == " " and "x" or " ") .. "]"
    end)
  end

  if convert then
    -- 3. 普通列表项转 todo：- item -> - [ ] item
    if new_line == line then
      new_line = line:gsub("^([%s]*[-*+][%s]+)([^%[].*)$", function(prefix, content)
        return prefix .. "[ ] " .. content
      end)
    end

    -- 4. 有序列表转 todo：1. item -> 1. [ ] item
    if new_line == line then
      new_line = line:gsub("^([%s]*%d+%.[%s]+)([^%[].*)$", function(prefix, content)
        return prefix .. "[ ] " .. content
      end)
    end

    -- 5. 纯文本转 todo：item -> - [ ] item
    if new_line == line then
      local indent = line:match("^%s*") or ""
      local content = line:sub(#indent + 1)
      if content ~= "" then
        new_line = indent .. "- [ ] " .. content
      end
    end
  end
  return new_line
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("markdown_todo", { clear = true }),
    pattern = "markdown",
    callback = function(args)

      -- 绑定快捷键 toggle 当前行
      vim.keymap.set("n", "<leader>ud", function()
        local line = vim.api.nvim_get_current_line()
        local new_line = M.toggle_line_todo(line, M.opts.convert)
        if new_line ~= line then
          vim.api.nvim_set_current_line(new_line)
        end
      end, { buffer = args.buf, desc = "Toggle Markdown Todo" })

      -- 绑定快捷键 toggle 选取的每行
      -- vim.keymap.set("x", "<leader>ud", function()
      --   -- 获取可视选区范围（0-indexed）
      --   local start_line = vim.fn.line("v") - 1
      --   local end_line   = vim.fn.line(".") - 1
      --
      --   if start_line > end_line then
      --     start_line, end_line = end_line, start_line
      --   end
      --
      --   local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)
      --   local changed = false
      --
      --   for i, line in ipairs(lines) do
      --     local new_line = M.toggle_line_todo(line, M.opts.convert)
      --     if new_line ~= line then
      --       lines[i] = new_line
      --       changed = true
      --     end
      --   end
      --
      --   if changed then
      --     vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, lines)
      --   end
      --
      --   vim.api.nvim_feedkeys(
      --     vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false
      --   )
      -- end, { desc = "Toggle Markdown Todos" })

      -- neovim 0.11+ 新 API 实现：绑定快捷键 toggle 选取的每行
      vim.keymap.set("x", "<leader>ud", function()
        local region = vim.fn.getregionpos(
          vim.fn.getpos("v"), vim.fn.getpos("."), { type = "V", inclusive = true }
        )
        local start_line = region[1][1][2]      -- 第一个位置的行号
        local end_line   = region[#region][2][2] -- 最后一个位置的行号

        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

        for i, line in ipairs(lines) do
          lines[i] = M.toggle_line_todo(line, M.opts.convert)
        end

        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
        -- 手动退出可视状态
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false
        )
      end, { desc = "Toggle Markdown Todos" })
    end,

  })

end

return M
