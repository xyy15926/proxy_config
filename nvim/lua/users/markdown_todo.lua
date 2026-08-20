-- ================================================
-- 快速切换 markdown 待办、切换待办
-- ================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<leader>ud", function()
      local line = vim.api.nvim_get_current_line()
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

      if new_line ~= line then
        vim.api.nvim_set_current_line(new_line)
      end
    end, { buffer = args.buf, desc = "Toggle Markdown Todo" })
  end,
})
