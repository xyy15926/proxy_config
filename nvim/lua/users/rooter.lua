-- ==========================================================================
-- File    : rooter.lua
-- Author  : xyy15926
-- Created : 2026-08-27 17:35:17
-- Updated : 2026-09-09 18:18:14
-- Desc    : Find and set the root of the project as the working directory.
--
-- -------------------------------------------------------------------------
-- `vim.fn.findfile` 逻辑非常简单
-- 1. 若首个参数 `/` 开头，直接视为绝对路径查找
-- 2. 否则，将第二个参数逐个通过 `/` 与首个参数拼接、检查，但不处理 `..` 回退
-- 2.1. 查找路径使用 `,` 分割
-- 2.2. 路径后跟 `;` 则表示支持向上递归查找，即 `/a/b/c/d` 逐个回退至父目录
--   后拼接
-- 2.3. 特殊标记
--   - `.` 文件所在目录
--   - `..` 父目录
--   - `,` runtimepath 中目录
--   - 空字符串 当前工作目录（也是默认值）
-- `vim.fn.findfile` 只可用于查找文件（对应 `vim.fn.finddir`)
--
-- -------------------------------------------------------------------------
-- `vim.o.path` 被用于最基础的文件导航
-- 1. vim 内部应用
-- 1.1. `:find`, `:sfind`, `:tabfind` 文件查找
-- 1.2. `gf`, `gF`, `gF`, `<C-w>f`，`<C-w>gf` 光标下文件导航
-- 1.3. `:e **/` 下 tab 补全
-- 2. 默认取值一般为 `.,/usr/include`
-- 2.1 对 lua 类型文件，/usr/share/nvim/runtime/ftplugin/lua.vim 会将该默认值
--   清空（可通过 `:verbose set path?` 确认）
-- ==========================================================================

local M = {}

M.defaults = {
  root_flags = { ".root", ".svn", ".git", ".hg", ".project", "Makefile" },
  web_browser = {
    "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
    "--inprivate",
  },
  open_cmd = { "cmd.exe", "/c", "start" },
  find_path = {
    vim.fn.stdpath("config"),
    vim.fn.stdpath("data"),
    vim.fn.expand("~/code/pproxy"),
  }
}
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  根目录定位、设置
-- ==========================================================================
--- 向上搜索找到项目根目录
--- @return string
function M.find_project_root()
  -- vim.fs.root 自动向上查找，返回第一个匹配的目录
  vim.b.root_dir = vim.b.root_dir
    or vim.fs.root(0, M.opts.root_flags)
    or vim.fn.expand("%:p:h")
    or ""
  return vim.b.root_dir
end


-- %% =======================================================================
--  链接、文件跳转
-- ==========================================================================
--- Markdown 文件内形如 `#...` 的链接：直接跳转
--- @param link string
--- @param bufnr number? 指定缓冲区，默认当前缓冲区
--- @return boolean
local function tag_jump(link, bufnr)
  if link:match("^#") then
    local heading = link:sub(2):lower():gsub("-", " ")
    local target = bufnr or vim.api.nvim_get_current_buf()
    for i, l in ipairs(vim.api.nvim_buf_get_lines(target, 0, -1, false)) do
      if l:lower():match("^#+%s+" .. heading) then
        local wins = vim.fn.win_findbuf(target)
        if #wins > 0 then
          vim.api.nvim_win_set_cursor(wins[1], { i, 0 })
        end
        return true
      end
    end
  end
  return false
end


--- 文件：Neovim 新 tabpage 打开
--- @param url string
--- @param strict boolean? 不将 `/` 开头的绝对路径视为相对路径
--- @return string?, number?
local function open_local(url, strict)
  local found = nil
  -- `.`、`..` 开头路径视为相对路径，`findfile` 无法处理
  local tmp_target = vim.fn.expand("%:p:h") .. "/" .. url
  if url:match("^%.") and vim.fn.filereadable(tmp_target) then
    found = tmp_target
  else
    tmp_target = vim.fn.findfile(url, vim.o.path, 0)  --[[@as string]]
    if tmp_target ~= "" then
      found = tmp_target
    elseif not strict then
      -- 将 `/` 开头的绝对路径视为相对路径
      tmp_target = vim.fn.findfile(url:gsub("^/", ""), vim.o.path, 0)  --[[@as string]]
      if tmp_target ~= "" then
        found = tmp_target
      end
    end
  end
  if found then
    vim.cmd.tabnew(found)
    local bufnr = vim.api.nvim_get_current_buf()
    return found, bufnr
  else
    return nil, nil
  end
end


--- 网页链接使用 `open_cmd` 指定的命令打开
--- @param url string
--- @return boolean
local function open_web(url)
  local web_suf3 = { ".com", ".org", ".xyz" }
  local web_suf2 = { ".cn" }
  if url:match("^https?://")
    or vim.tbl_contains(web_suf3, string.sub(url, 4))
    or vim.tbl_contains(web_suf2, string.sub(url, 3)) then
    local open_cmd = vim.deepcopy(M.opts.web_browser)
    table.insert(open_cmd, url)
    vim.fn.jobstart(open_cmd, { detach = true })
    return true
  end
  return false
end


--- 覆盖原 `gx`, `gf` 按键功能
--- @param url string?
--- @param tag string?
--- @param depth integer? 递归调用深度
--- @return string? parsed_URL 解析后文件地址
function M.gx_jump(url, tag, depth)
  url = url or vim.fn.expand("<cfile>")
  depth = depth or 0
  vim.notify("Try to resolve: " .. tostring(url), vim.log.levels.TRACE)

  if open_web(url) then return url end

  -- 本地文件则先尝试切分文件地址、文件内 tag
  local parts = vim.split(url, "#")
  if #parts > 1 then
    url = parts[1]
    tag = parts[2]
  end

  -- 纯 #tag 链接（url 以 # 开头），直接在当前缓冲区跳转
  if url == "" then
    tag_jump("#" .. tag)
    return tag
  end

  local found, bufnr = open_local(url)
  if found then
    if tag then
      tag_jump("#" .. tag, bufnr)
    end
    return tag and url .. "#" .. tag or url
  end

  -- Markdown 中链接尝试额外处理
  -- 只递归调用一次，避免死循环
  if vim.bo.filetype == "markdown" and depth < 1 then
    url = require("users.utils").get_markdown_link()
    if url ~= nil then
      return M.gx_jump(url, nil, 1)
    end
  end
  vim.notify(
    "URL: \"" .. tostring(url) .. "\" can't be resolved.",
    vim.log.levels.WARN
  )
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- 更新 `find`, `gf` 等查找路径
  vim.opt.path:append(M.opts.find_path)
  -- 覆盖原 `gx` 按键
  vim.keymap.set("n", "gx", M.gx_jump, { desc = "Open URL"} )

  -- 手动重置根目录（工作目录）
  vim.api.nvim_create_user_command("ResetRooterHere", function()
    local root = M.find_project_root()
    if root ~= "" then
      vim.cmd("cd " .. root)
      vim.notify("Set root: " .. root, vim.log.levels.TRACE)
    end
  end, {})

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("users.rooter.set_root", { clear = true }),
    pattern = "*",
    callback = function(args)
      local root = M.find_project_root()
      if root ~= "" then
        vim.cmd("cd " .. root)
        vim.notify("Set root: " .. root, vim.log.levels.TRACE)
      end
    end,
    once = true,  -- 只执行设置一次
  })
end

return M
