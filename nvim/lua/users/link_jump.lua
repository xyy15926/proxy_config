-- ==========================================================================
-- File    : link_jump.lua
-- Author  : xyy15926
-- Created : 2026-09-11 19:02:32
-- Updated : 2026-09-11 19:02:32
-- Desc    : Jump to the link.
-- ==========================================================================

local M = {}

M.defaults = {
  wsl_prefix = "file://wsl.localhost/ubuntu2404",
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
--  基本设置
-- ==========================================================================
local users_utils = require("users.utils")
local get_markdown_link = users_utils.get_markdown_link
local set_gx_pattern = users_utils.set_gx_pattern
local web_url = users_utils.web_url
local file_url = users_utils.file_url


--- 将 WSL 中本地文件路径转换为 Win GUI 可访问路径
local function wsl_file_url(url)
  return M.opts.wsl_prefix .. url
end


-- %% =======================================================================
--  Vim 内文件跳转、打开
-- ==========================================================================
--- Markdown 文件内形如 `#...` 的链接：直接跳转
--- 匹配时 `#...` 中空格、下划线、中划线均视为相同
--- @param tag string
--- @param bufnr number? 指定缓冲区，默认当前缓冲区
--- @return boolean
local function tag_jump(tag, bufnr)
  if tag:match("^#") then
    local target = bufnr or vim.api.nvim_get_current_buf()
    -- 将 `-_ ` 全部转换为空格再匹配
    local heading = tag:sub(2):lower():gsub("_", " "):gsub("-", " ")
    for i, l in ipairs(vim.api.nvim_buf_get_lines(target, 0, -1, false)) do
      local line = l:lower():gsub("_", " "):gsub("-", " ")
      if line:match("^#+%s+" .. heading) then
        local wins = vim.fn.win_findbuf(target)
        if #wins > 0 then
          vim.api.nvim_win_set_cursor(wins[1], { i, 0 })
        else
          vim.notify(
            "Buffer: " .. bufnr .. " could not be found.",
            vim.log.levels.WARN
          )
        end
        return true
      end
    end
    vim.notify("Tag: " .. tag .. " could not be found.", vim.log.levels.INFO)
  end
  return false
end


-- %% =======================================================================
--  GUI 跳转、打开
-- ==========================================================================
--- 网页链接使用 `open_cmd` 指定的命令打开
--- @param url string
--- @param forced boolean?
--- @return string?
function M.open_web(url, forced)
  vim.notify(
    "Try to open: " .. tostring(url) .. " in browser",
    vim.log.levels.TRACE
  )
  local parsed_url = web_url(url)

  -- 若强制要求使用 web 打开，则尝试获取 win 可用文件地址
  local parsed_tag = nil
  if parsed_url == nil and forced then
    parsed_url, parsed_tag = file_url(url, nil, false)
    if parsed_url ~= nil then
      parsed_url = parsed_tag and parsed_url .. "#" .. parsed_tag or parsed_url
      parsed_url = wsl_file_url(parsed_url)
    end
  end

  -- 用 web 打开
  if parsed_url then
    local open_cmd = vim.deepcopy(M.opts.web_browser)
    table.insert(open_cmd, parsed_url)
    vim.fn.jobstart(open_cmd, { detach = true })
  end
  return parsed_url
end


-- %% =======================================================================
--  Neovim 内跳转、打开
-- ==========================================================================
--- 尝试在 Neovim 新 tabpage 打开
--- @param url string
--- @return number
local function try_open_local(url)
  -- 若当前 buffer 即为目标目录则不新建窗口
  if url ~= vim.fn.expand("%:p") then
    vim.cmd.tabnew(url)
  end
  local bufnr = vim.api.nvim_get_current_buf()
  return bufnr
end


--- @param url string?
--- @param tag string?
--- @return string?
function M.open_local(url, tag)
  -- 纯 #tag 链接（url 以 # 开头），直接在当前缓冲区跳转
  if url == nil or url == "" then
    tag_jump("#" .. tag)
    return "#" .. tag
  else
    -- 检查并补全文件路径
    local parsed_url, parsed_tag = file_url(url, tag, false)
    if parsed_url then
      local bufnr = try_open_local(parsed_url)
      if parsed_tag then
        tag_jump("#" .. parsed_tag, bufnr)
      end
      return parsed_tag and parsed_url .. "#" .. parsed_tag or parsed_url
    end
  end
  return nil
end


-- %% =======================================================================
--  跳转、打开、分发
-- ==========================================================================
--- 覆盖原 `gx`, `gf` 按键功能
--- @param url string?
--- @param tag string?
--- @param depth integer? 递归调用深度
--- @return string? parsed_URL 解析后文件地址
function M.gx_jump(url, tag, depth)
  url = url or vim.fn.expand("<cfile>")
  depth = depth or 0
  vim.notify("Try to resolve: " .. tostring(url), vim.log.levels.TRACE)

  local parsed_url = M.open_web(url)
  if parsed_url then return parsed_url end
  parsed_url = M.open_local(url)
  if parsed_url then return parsed_url end

  -- Markdown 中链接尝试额外处理
  -- 只递归调用一次，避免死循环
  if vim.bo.filetype == "markdown" and depth < 1 then
    local old_url = tag and url .. "#" .. tag or url
    local new_url = get_markdown_link()
    if new_url ~= nil and new_url ~= old_url then
      return M.gx_jump(new_url, nil, 1)
    end
  end
  vim.notify(
    "URL: \"" .. tostring(url) .. "\" can't be resolved.",
    vim.log.levels.WARN
  )
  return nil
end


--- 强制在浏览器中打开当前文件
local function open_web_cur_file(file)
  file = file or vim.fn.expand("%:p")
  return M.open_web(file, true)
end


--- 强制在浏览器中打开地址
local function open_web_cur_url(url)
  url = url or vim.fn.expand("<cfile>")
  local parsed_url = M.open_web(url, true)
  if vim.bo.filetype == "markdown" and not parsed_url then
    parsed_url = get_markdown_link()
    if parsed_url then
      parsed_url = M.open_web(parsed_url, true)
    end
  end
  return parsed_url
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- 手动重置根目录（工作目录）
  vim.api.nvim_create_user_command("SetGXJumpPattern", set_gx_pattern, { })
  -- 更新 `find`, `gf` 等查找路径
  vim.opt.path:append(M.opts.find_path)
  -- 覆盖原 `gx` 按键
  vim.keymap.set("n", "gx", M.gx_jump, { desc = "Open URL"} )
  vim.keymap.set("n", "<leader>qf", open_web_cur_file, { desc = "Browse Current File"} )
  vim.keymap.set("n", "<leader>qa", open_web_cur_url, { desc = "Browse Current URL"} )
end

return M
