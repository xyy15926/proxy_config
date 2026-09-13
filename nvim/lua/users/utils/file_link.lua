-- ==========================================================================
-- File    : file_link.lua
-- Author  : xyy15926
-- Created : 2026-09-11 18:48:49
-- Updated : 2026-09-13 20:48:02
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
--  其他杂项
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


--- 解析 `,` 分割的路径（默认为 vim.bo.path）为绝对路径列表，跳过含通配符的条目
--- @param paths string
--- @return string[] abs_dirs  去重后的绝对目录路径列表
local function collect_path_dirs(paths)
  paths = paths or vim.bo.path
  local seen = {}
  local dirs = {}
  for _, entry in ipairs(vim.split(paths, ',', { trimempty = true })) do
    entry = vim.trim(entry)
    -- 跳过含通配符的条目（* ? [）
    if entry:find('[*?%[]') then
      goto continue
    end
    -- 空串视为当前目录，`.` 是为 buffer 所在目录
    entry = entry == "." and vim.fn.epxand("%:p:h")
      or entry == "" and vim.fn.getcwd()
      or entry
    -- 转换为绝对路径，并解析符号链接
    local abs = vim.uv.fs_realpath(entry)
    -- local abs = vim.fn.fnamemodify(entry, ":p"):gsub("/$", "")
    if abs ~= nil and vim.fn.isdirectory(abs) == 1 and not seen[abs] then
      seen[abs] = true
      dirs[#dirs + 1] = abs
    end
    ::continue::
  end
  return dirs
end


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
--- 在路径表中寻找指定文件
--- @param url string
--- @param entrys string[]
--- @param count integer? 最多寻找的数量
--- @return string[]
function M.find_url_in_paths(url, entrys, count)
  count = count or 0
  local found = {}
  local candidate = nil
  for _, entry in ipairs(entrys) do
    entry = entry == "." and vim.fn.expand("%:p:h")
      or entry == "" and vim.fn.getcwd()
      or entry
    candidate = url:match("^/") and entry .. url
      or entry .. "/" .. url
    -- `vim.fn.filereadable` 返回 0, 1，但 0 是 true
    if vim.fn.filereadable(candidate) > 0 then
      table.insert(found, vim.fn.simplify(candidate))
    end
    -- 找到足够数量候选即返回
    if count > 0 and #found >= count then return found end
  end
  return found
end


--- 检查并返回本地文件 **绝对路径**，链接将被解析
--- `/` 开头绝对路径若不存在，可能被视为相对路径
--- @param url string
--- @param tag string?
--- @param entrys string[]?
--- @return string?, string?
function M.file_url(url, tag, entrys)
  -- 本地文件则先尝试切分文件地址、文件内 tag
  if url then
    local parts = vim.split(url, "#")
    if #parts > 1 then
      url = parts[1]
      tag = parts[2]
    end
  end
  url = modify_url(url)
  -- 尝试直接查找
  if vim.fn.filereadable(url) > 0 then
    return vim.uv.fs_realpath(url), tag
  end
  -- 默认在 vim.o.path 中寻找
  entrys = entrys == nil and collect_path_dirs(vim.bo.path) or entrys
  local found = M.find_url_in_paths(url, entrys, 1)
  if #found > 0 then
    return found[1], tag
  else
    return nil, tag
  end
end


-- %% =======================================================================
--  前缀匹配目录内项
-- ==========================================================================
--- 扫描单个目录，返回与 name_part 前缀匹配的文件/子目录条目。
--- @param base_dir string  路径根目录
--- @param dir_part string  已输入的子目录前缀
--- @param name_part string  已输入的文件名前缀
--- @return { name: string, is_dir: boolean, scan_dir: string }[] entries  匹配到的条目列表
function M.scan_directory(base_dir, dir_part, name_part)
  -- 根目录为空字符串表示当前工作目录
  local scan_dir = base_dir == "." and vim.fn.expand("%:p:h")
    or base_dir == "" and vim.fn.getcwd()
    or base_dir
  scan_dir = dir_part ~= "" and (scan_dir .. "/" .. dir_part) or scan_dir
  if vim.fn.isdirectory(scan_dir) ~= 1 then
    return {}
  end

  local ok, raw_entries = pcall(vim.fn.readdir, scan_dir)
  if not ok or not raw_entries then
    return {}
  end

  local results = {}

  for _, entry in ipairs(raw_entries) do
    if entry == "." or entry == ".." then
      goto skip
    end
    -- 文件名前缀过滤
    if name_part ~= "" and entry:sub(1, #name_part) ~= name_part then
      goto skip
    end

    local full   = scan_dir .. "/" .. entry
    local is_dir = vim.fn.isdirectory(full) == 1

    table.insert(results, {
      name = entry,
      is_dir = is_dir,
      scan_dir = scan_dir,
    })

    ::skip::
  end

  return results
end


--- 扫描多个目录，返回与 name_part 前缀匹配的文件/子目录条目。
--- @param base_dirs string[]  路径根目录
--- @param dir_part string  已输入的子目录前缀
--- @param name_part string  已输入的文件名前缀
--- @param count integer? 最大查找数量，默认全部
--- @return { name: string, is_dir: boolean, scan_dir: string}[] entries  匹配到的条目列表
function M.scan_directories(base_dirs, dir_part, name_part, count)
  count = count or 0
  local items = {}
  local seen  = {}

  for _, base_dir in ipairs(base_dirs) do
    if count > 0 and #items >= count then break end
    local entries = M.scan_directory(base_dir, dir_part, name_part)
    for _, entry in ipairs(entries) do
      if count > 0 and #items >= count then break end

      -- 拼接相对 base_dir 的路径，用于跨目录去重
      local rel = dir_part ~= "" and (dir_part .. "/" .. entry.name) or entry.name
      local label = rel .. (entry.is_dir and "/" or "")
      if seen[label] then goto skip end
      seen[label] = true

      table.insert(items, entry)

      ::skip::
    end
  end
  return items
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  return M
end

return M
