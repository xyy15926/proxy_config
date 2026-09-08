-- ==========================================================================
-- File    : rooter.lua
-- Author  : xyy15926
-- Created : 2026-08-27 17:35:17
-- Updated : 2026-09-08 15:25:28
-- Desc    : Find and set the root of the project as the working directory.
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
  return vim.fs.root(0, M.opts.root_flags)
    or vim.fn.expand("%:p:h")
    or ""
end


-- %% =======================================================================
--  链接、文件跳转
-- ==========================================================================
--- 覆盖原 `gx`, `gf` 按键功能
--- @param url string?
function M.gx_jump(url)
  url = url or vim.fn.expand("<cfile>")

  -- 网页链接使用 `open_cmd` 指定的命令打开
  local web_suf3 = { ".com", ".org", ".xyz" }
  local web_suf2 = { ".cn" }
  if url:match("^https?://")
    or vim.tbl_contains(web_suf3, string.sub(url, 4))
    or vim.tbl_contains(web_suf2, string.sub(url, 3)) then
    local open_cmd = vim.deepcopy(M.opts.web_browser)
    table.insert(open_cmd, url)
    vim.fn.jobstart(open_cmd, { detach = true })
    return
  end

  -- 文件 Neovim 内打开
  local found = vim.fn.findfile(url, vim.o.path)
  if found ~= "" then
    vim.cmd.tabnew(found)
  else
    vim.notify("URL: \"" .. url .. "\" can't be resolved.")
  end
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
  vim.api.nvim_create_user_command("ResetRooter", function()
    local root = M.find_project_root()
    if root ~= "" then
      vim.cmd("cd " .. root)
    end
  end, {})

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("SetRoot", { clear = true }),
    pattern = "*",
    callback = function(args)
      local root = M.find_project_root()
      if root ~= "" then
        vim.cmd("cd " .. root)
      end
    end,
  })
end

return M
