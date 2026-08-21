-- ==================================================
-- yank2gclip.lua
--
-- 通过 win32yank.exe 与 Win 实现通信
-- 1. 一般将 win32yank.exe 绑定至 `vim.g.clipboard`，配合 `+`/`*` 寄存器，
--   实现粘贴板共享，此时修改 `+`/`*` 寄存器即将内容传递至 win32yank.exe
-- 2. 要求 WSL 可与 Win 正常通信
-- 3. win32yank.exe 目录位于 PATH、或直接绝对路径
-- Ref:
-- - https://github.com/equalsraf/win32yank/releases/
-- ==================================================


local M = {}
M.defaults = {
  win32yank = nil,
}
M.opts = vim.deepcopy(M.defaults)

-- 计算并移除前导缩进
function M.remove_indents(lines)
  -- 计算非空行的最小前导空白
  local min_indent = math.huge
  for _, line in ipairs(lines) do
    if line:find('%S') then
      local lead = #(line:match('^%s*') or '')
      min_indent = math.min(min_indent, lead)
    end
  end

  local text
  if min_indent == math.huge or min_indent == 0 then
    text = table.concat(lines, '\n')
  else
    local trimmed = {}
    for _, line in ipairs(lines) do
      table.insert(trimmed, line:sub(min_indent + 1))
    end
    text = table.concat(trimmed, '\n')
  end
  return text
end

-- 1. opfunc：同时支持 Normal(gyaw) 和 Visual(gy)
-- 2. 必须定义为全局函数 `_G` 前缀，放入 lua 的全局变量表
-- 2.1. `_G` 是 lua 语言自身的全局表
-- 2.2. 默认无 `local` 前缀也是全局变量，此处添加是为了避免 Warning
-- 3. `type` 由 Neovim 的 `g@` 机制自动传入
function _G.yank_smart(type)
  -- 1. opfunc 已经自动把范围写在 '[ 和 '] 标记里
  local start_pos = vim.fn.getpos("'[")
  local end_pos = vim.fn.getpos("']")

  -- 2. 直接按标记和类型取文本（Neovim 0.10+）
  -- 2.1 `V`: lines，行
  -- 2.2 `\22`/<C-V>: block，块
  -- 2.3 `v`：char，字符
  -- 不同的方式，决定读取、写入行为
  local region_type = type == 'line' and 'V'
                    or type == 'block' and '\22'
                    or 'v'
  local ok, lines = pcall(vim.fn.getregion, start_pos, end_pos, { type = region_type })
  if not ok or not lines or #lines == 0 then return end

  -- 3. 去缩进
  local text = M.remove_indents(lines)

  -- 4. 写寄存器，同样根据标记类型有不同写入行为
  -- 4.1 `V`: lines，粘贴时将自动换行
  -- 4.2 `\22`/<C-V>: block，粘贴时保持矩形形状
  -- 4.3 `v`：char，按普通字符流粘贴
  -- 此处 `regtype` 与 `region_type` 取值一致，即读、写行为一致
  -- 但，分开设置以应对后续可能的读、写不一致场合，如 `block` 读、`lines` 写
  local regtype = type == 'line' and 'V'
                  or type == 'block' and '\22'
                  or 'v'
  vim.fn.setreg('+', text, regtype)

  -- 5. 推给 win32yank
  -- `setup` 中已经将 `vim.g.clipboard` 绑定至 `win32yank.exe`，
  -- 所以设置 `+` 寄存器即可，否则需要手动调用
  -- vim.fn.system("win32yank.exe -i --crlf", text)

  -- 6. 手动高亮反馈（因为没执行原生 yank，需要自己画）
  local buf = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace('yank_smart_hl')
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local sr, sc = start_pos[2] - 1, start_pos[3] - 1
  local er, ec = end_pos[2] - 1, end_pos[3] - 1

  if type == 'line' then
    for r = sr, er do
      vim.api.nvim_buf_add_highlight(buf, ns, 'IncSearch', r, 0, -1)
    end
  elseif type == 'block' then
    -- block 高亮要处理从右往左选的情况，且 end_col 是 exclusive
    if sc > ec then
      sc, ec = ec, sc
    end
    -- '] 的列是 inclusive，高亮接口要 exclusive，所以 +1
    local hl_end = ec + 1
    for r = sr, er do
      vim.api.nvim_buf_add_highlight(buf, ns, 'IncSearch', r, sc, hl_end)
    end
  else
    -- char 模式用 range 处理跨行高亮
    vim.highlight.range(buf, ns, 'IncSearch', {sr, sc}, {er, ec}, {
      regtype = 'v', inclusive = true
    })
  end

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end, 150)

end

-- 允许自定义全局配置
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  local yank
  if M.opts.win32yank then
    yank = M.opts.win32yank
  else
    yank = "win32yank.exe"
  end

  -- 将寄存器绑定至 win32yank.exe
  vim.g.clipboard = {
    name = "win32yank",
    -- `*` X11 为鼠标中间粘贴内容；Win/MacOS 下同 `+`，似乎会与 `+` 自动同步
    copy = {
      ["+"] = yank .. " -i --crlf",
      ["*"] = yank .. " -i --crlf",
    },
    paste = {
      ["+"] = yank .. " -o --lf",
      ["*"] = yank .. " -o --lf",
    },
    cache_enabled = 0,
  }

  -- ==================================================
  -- g@` 是 Vim 内置的一个特殊命令，专门用来触发用户自定义的操作符
  --
  -- 1. `g@` 表示：现在要执行一个自定义 operator，请等待用户输入
  -- motion/text object，等输入完后去调用 opfunc 指定的函数
  --
  -- 2. `expr = true`：keymap 将函数返回的 `g@` 视为按键执行，否则默认
  --   `expr = false` 时将函数返回值直接忽略
  -- 2.1. `expr = false` 时，rhs 若为函数同样也会被执行，只是返回值被忽略
  -- 2.2. `expr = true` 仅在 rhs 时函数时有意义
  --
  -- 3. 执行流程
  -- 3.1. 按下 gy
  -- 3.2. Neovim 执行函数，设置 opfunc，得到返回值 g@
  -- 3.3. Neovim 模拟按下 g@，进入 Operator-pending 模式
  -- 3.4. 你输入 aw
  -- 3.5. Neovim 自动调用 yank_smart('char')
  --
  -- 4. `v:lua.` 是 Neovim 提供的特殊前缀，用来在 Vimscript 表达式中访问
  -- Lua 全局变量/函数
  -- 4.1. `v:` 是 Vimscript 的内置变量命名空间（如 v:count、v:register）
  -- 4.2. `yank_smart` 在 Lua 中定义的全局函数 `_G.yank_smart`
  -- 4.3. opfunc 这个选项只接受 Vimscript 函数名（字符串形式）
  -- ==================================================
  -- Normal 模式：gy + motion（gyaw, gyiw, gy$...）
  vim.keymap.set('n', '<leader>uy', function()
    vim.opt.opfunc = 'v:lua.yank_smart'
    return 'g@'
  end, { expr = true, silent = true, desc = "Yank To GClip" })

  -- Visual 模式：选中后按 gy（行为跟你原来的函数完全一致）
  vim.keymap.set('x', '<leader>uy', function()
    vim.opt.opfunc = 'v:lua.yank_smart'
    return 'g@'
  end, { expr = true, silent = true, desc = "Yank To GClip" })

end

return M
