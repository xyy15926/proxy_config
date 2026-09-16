-- %% =======================================================================
-- File    : yank2gclip.lua
-- Author  : xyy15926
-- Created : 2026-08-28 11:31:39
-- Updated : 2026-09-16 10:24:48
-- Desc    : Yank to and paste from GClip.
--
-- 通过 win32yank.exe 与 Win 实现通信
-- 1. 一般将 win32yank.exe 绑定至 `vim.g.clipboard`，配合 `+`/`*` 寄存器，
--   实现粘贴板共享，此时修改 `+`/`*` 寄存器即将内容传递至 win32yank.exe
-- 2. 要求 WSL 可与 Win 正常通信
-- 3. win32yank.exe 目录位于 PATH、或直接绝对路径
-- Ref:
-- - https://github.com/equalsraf/win32yank/releases/
--
-- ------------------------------------------------------------------------
-- 通过将 opfunc 同时支持 Normal(gyaw) 和 Visual(gy) 的 yank
-- 1. 函数必须定义为全局函数，放入 lua 的全局变量表
-- 2. opfunc 接收单个参数 `type` 指示当前可视类型，由 Neovim 的 `g@` 机制
--   自动传入，取值
-- 2.1 line：行模式，对应 "V" 字符流，对应 `vim.fn.getregion` 中 `type = "V"`
-- 2.2 block：块模式，对应 "\22"/"<C-V>" 字符流 `vim.fn.getregion` 中 `type = "\22"`（即 `<C-V>` 转义）
-- 2.3 char：字符模式，对应 "v" 字符流 `vim.fn.getregion` 中 `type = "v"`
-- 3. `vim.fn.getregion`、`vim.setreg` 等函数中 `type` 参数即指定字符流类型
--   "V"、"\22"、"v"，确定如何处理换行
-- 3.1 "V": lines，粘贴时将自动换行
-- 3.2 "\22"/<C-V>: block，粘贴时保持矩形形状
-- 3.3 "v"：char，按普通字符流粘贴
-- 3.4 读、写字符流类型可以不一致，如 `block` 读、`lines` 写
--
-- ------------------------------------------------------------------------
-- 1. `g@` 是 Vim 内置的一个特殊命令，用于触发用户自定义的操作符
-- 1.1 `g@` 表示：现在要执行一个自定义 operator，请等待用户输入
--   motion/text object
-- 1.2 等输入完后去调用 `vim.opt.opfunc` 指定的函数
--
-- 2. `v:lua.` 是 Neovim 提供的特殊前缀，用来在 Vimscript 表达式中访问
--   Lua 全局变量/函数
-- 2.1. `v:` 是 Vimscript 的内置变量命名空间（如 v:count、v:register）
-- 2.2. `yank_smart` 在 Lua 中定义的全局函数 `_G.yank_smart`
-- 2.3. `vim.opt.opfunc` 这个选项只接受 Vimscript 函数名（字符串形式）
--
-- 3. `expr = true`：keymap 将函数返回的 `g@` 视为按键执行，否则默认
-- 3 `expr = false` 时将函数返回值直接忽略
-- 3.1. `expr = false` 时，rhs 若为函数同样也会被执行，只是返回值被忽略
-- 3.2. `expr = true` 仅在 rhs 时函数时有意义
--
-- 4. 自定义 opfunc 执行流程
-- 4.1. 按下 gy
-- 4.2. Neovim 执行函数，设置 opfunc，得到返回值 g@
-- 4.3. Neovim 模拟按下 g@，进入 Operator-pending 模式
-- 4.4. 你输入 aw
-- 4.5. Neovim 自动调用 yank_smart('char')
-- ===========================================================================

local M = {}

M.defaults = {
  win32yank = "win32yank.exe"
}
M.opts = vim.deepcopy(M.defaults)

local utils = require("users.utils")

-- %% =======================================================================
--  功能函数
-- ==========================================================================
--- 计算并移除前导缩进
--- @param lines { integer: string }
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


--- 自定义 opfunc 函数
--- @param type "line"|"block"|"char" Passed by vim opfunc callback
function _G.yank_smart(type)
  -- 1. opfunc 已经自动把范围写在 '[ 和 '] 标记里
  local start_pos = vim.fn.getpos("'[")
  local end_pos = vim.fn.getpos("']")

  -- 按标记和类型取文本（Neovim 0.10+）
  local region_type = type == 'line' and 'V'
                    or type == 'block' and '\22'
                    or 'v'
  local ok, lines = pcall(
    vim.fn.getregion,
    start_pos,
    end_pos,
    { type = region_type }
  )
  if not ok or not lines or #lines == 0 then return end

  local text = M.remove_indents(lines)

  -- 已经将 `vim.g.clipboard` 绑定至 `win32yank.exe`，
  -- 故，设置 `+` 寄存器即可，否则需要手动调用
  -- vim.fn.system("win32yank.exe -i --crlf", text)
  vim.fn.setreg("+", text, region_type)

  utils.flash_from_marks(0, start_pos, end_pos, region_type)
end


-- %% =======================================================================
--  配置 GClip
-- ==========================================================================
--- 设置 `vim.g.clipboard`，将 `+`, `*` 寄存器绑定至 win32yank.exe
local function set_gclip()
  local yank = vim.fn.exepath(M.opts.win32yank)
  if yank ~= "" then
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
  end
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  set_gclip()
  vim.keymap.set({ "n", "x" }, "<leader>cy", function()
    vim.opt.opfunc = "v:lua.yank_smart"
    return "g@"
  end, { expr = true, silent = true, desc = "Yank To GClip" })

  vim.keymap.set({ "n" }, "<leader>cm", function()
    local msg = vim.api.nvim_exec2("1messages", { output = true }).output
    -- 去掉开头多余换行
    msg = msg:gsub("^\n", "")
    vim.fn.setreg("+", msg)
  end, { desc = "GYank Last Msg" })
end

return M
