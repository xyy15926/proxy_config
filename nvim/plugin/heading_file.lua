-- 自动添加文件头 + 保存时更新时间

local header_group = vim.api.nvim_create_augroup("heading_file", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
  group = header_group,
  pattern = { "*.py", "*.rs", "*.c", "*.cpp", "*.h", "*.sh", "*.java", "*.scala", "*.vim", "*.md" },
  callback = function()
    local file = vim.fn.expand("%:t")
    local xtime = os.date("%Y-%m-%d %H:%M:%S")
    local author = "xyy15926"
    local ft = vim.bo.filetype

    local lines = {}

    if ft == "python" then
      lines = {
        "#!/usr/bin/env python3",
        "# ---------------------------------------------------------",
        "#   Name: " .. file,
        "#   Author: " .. author,
        "#   Created: " .. xtime,
        "#   Updated: " .. xtime,
        "#   Description:",
        "# ---------------------------------------------------------",
      }
    elseif ft == "vim" then
      lines = {
        '" ---------------------------------------------------------',
        '"   Name: ' .. file,
        '"   Author: ' .. author,
        '"   Created: ' .. xtime,
        '"   Updated: ' .. xtime,
        '"   Description:',
        '" ---------------------------------------------------------',
      }
    elseif ft == "rust" then
      lines = {
        "// ---------------------------------------------------------",
        "//  Name: " .. file,
        "//  Author: " .. author,
        "//  Created: " .. xtime,
        "//  Updated: " .. xtime,
        "//  Description:",
        "// ---------------------------------------------------------",
      }
    elseif ft == "cpp" or ft == "c" or ft == "scala" or ft == "java" then
      lines = {
        "/*",
        " * ---------------------------------------------------------",
        " *  Name: " .. file,
        " *  Author: " .. author,
        " *  Created: " .. xtime,
        " *  Updated: " .. xtime,
        " *  Description:",
        " * ---------------------------------------------------------",
        " */",
      }
    elseif ft == "sh" then
      lines = {
        "#!/usr/bin/env shell",
        "# ---------------------------------------------------------",
        "#   Name: " .. file,
        "#   Author: " .. author,
        "#   Created: " .. xtime,
        "#   Updated: " .. xtime,
        "#   Description:",
        "# ---------------------------------------------------------",
      }
    elseif ft == "markdown" or ft == "pandoc" then
      lines = {
        "---",
        "title: ",
        "categories:",
        "  - ",
        "tags:",
        "  - ",
        "date: " .. xtime,
        "updated: " .. xtime,
        "toc: true",
        "mathjax: true",
        "description: ",
        "---",
      }
    end

    if #lines > 0 then
      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
  group = header_group,
  pattern = { "*.py", "*.rs", "*.c", "*.cpp", "*.h", "*.sh", "*.java", "*.scala", "*.vim", "*.md" },
  callback = function()
    local update_time = os.date("%Y-%m-%d %H:%M:%S")
    local lineno = 6
    while lineno < 100 do
      local ok, line = pcall(vim.api.nvim_buf_get_lines, 0, lineno - 1, lineno, false)
      if not ok or #line == 0 then break end
      line = line[1]
      if line:sub(5):match("Updated") then
        vim.api.nvim_buf_set_lines(0, lineno - 1, lineno, false, { line:sub(1, 4) .. "Updated: " .. update_time })
        break
      elseif line:match("updated") then
        vim.api.nvim_buf_set_lines(0, lineno - 1, lineno, false, { "updated: " .. update_time })
        break
      end
      lineno = lineno + 1
    end
  end,
})
