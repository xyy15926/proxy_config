-- ==========================================================================
-- File    : file_link.lua
-- Author  : xyy15926
-- Created : 2026-09-11 18:48:49
-- Updated : 2026-09-11 18:48:49
-- Desc    : Tools to construct and file link.
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
--
--  PS.
-- - `vim.fn.findfile` 只可用于查找文件（对应 `vim.fn.finddir`)
-- - `vim.fn.findfile` 返回拼接结果，路径若有空字符串，则可能返回 “相对路径”
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

M.defaults = { }
M.opts = vim.deepcopy(M.defaults)

-- %% =======================================================================
--  公共路径模式
-- ==========================================================================
--- 配置路径补全模式：路径前缀、文件后缀
--- 需先选择是 global 还是 buffer local 的模式
function M.set_gx_pattern()
  local default_file_ptn = vim.b.gx_file_ptn
    or vim.gx_file_ptn
    or vim.fn.expand("%:p:h") .. "/{{}}"

  -- 先选择是 global 还是 buffer local 的模式
  vim.ui.input({
    prompt = "Scope (g)lobal or (b)uffer local: ",
    default = "g",
  }, function(scope_input)
    if not scope_input then return end
    local scope = scope_input:sub(1, 1):lower()

    -- 配置路径补全模式：路径前缀、文件后缀
    vim.ui.input({
      prompt = "File pattern: {{}} will be replaced: ",
      default = default_file_ptn
    }, function(ptn_input)
      if not ptn_input then return end
      if scope == "g" then
        vim.g.gx_file_ptn = ptn_input
      else
        vim.b.gx_file_ptn = ptn_input
      end
    end)
  end)
end


--- 根据已配置模式补全路径
--- @param url string
local function modify_url(url)
  local file_ptn = vim.b.gx_file_ptn or vim.g.gx_file_ptn
  if file_ptn then
    url = file_ptn:gsub("{{}}", url):gsub("//", "/", nil)
  end
  return url
end


-- %% =======================================================================
--  地址检查、补全
-- ==========================================================================
--- 检查并返回 web URL
--- @param url string
--- @return string?
function M.web_url(url)
  local web_suf3 = { ".com", ".org", ".xyz" }
  local web_suf2 = { ".cn" }
  if url:match("^https?://")
    or vim.tbl_contains(web_suf3, string.sub(url, 4))
    or vim.tbl_contains(web_suf2, string.sub(url, 3)) then
    return url
  end
  return nil
end


--- 检查并返回本地文件 **绝对路径**，链接将被解析
--- @param url string
--- @param tag string?
--- @param strict boolean? 不将 `/` 开头的绝对路径视为相对路径
--- @return string?, string?
function M.file_url(url, tag, strict)
  -- 本地文件则先尝试切分文件地址、文件内 tag
  if url then
    local parts = vim.split(url, "#")
    if #parts > 1 then
      url = parts[1]
      tag = parts[2]
    end
  end
  url = modify_url(url)

  local found = nil
  local candidate = nil
  -- `.`、`..` 开头路径视为相对路径，`findfile` 无法处理
  if url:match("^%.") then
    candidate = vim.fn.expand("%:p:h") .. "/" .. url
    if vim.fn.filereadable(candidate) then
      found = candidate
    end
  end
  -- `findfile` 查找
  if not found then
    candidate = vim.fn.findfile(url, vim.o.path, 0)
    if type(candidate) == "string" and candidate ~= "" then
      -- 转为绝对路径
      found = vim.uv.fs_realpath(candidate)
    elseif not strict then
      -- 将 `/` 开头的绝对路径视为相对路径
      candidate = vim.fn.findfile(url:gsub("^/", ""), vim.o.path, 0)
      if type(candidate) == "string" and candidate ~= "" then
        found = vim.uv.fs_realpath(candidate)
      end
    end
  end
  return found, tag
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  return M
end

return M
