-- ==========================================================================
-- File    : colorscheme_switch.lua
-- Author  : xyy15926
-- Created : 2026-08-28 10:51:21
-- Updated : 2026-09-04 09:22:22
-- Desc    : Switch colorscheme.
-- ==========================================================================

local M = {}

M.defaults = {
  save_path = vim.fn.stdpath("data") .. "/last_colorscheme",
  default_colorscheme = "catppuccin-mocha",
  transparent_enabled = true,
  set_keymap = true,
}
M.opts = vim.deepcopy(M.defaults)


-- %% =======================================================================
--  Colorscheme 存取
-- ==========================================================================
--- 保存当前配色至本地文件
--- @param name string
function M.save(name)
  local f = io.open(M.opts.save_path, "w")
  if f then
    f:write(name)
    f:close()
  end
end

--- 读取保存的配色
function M.load()
  local f = io.open(M.opts.save_path, "r")
  if not f then return nil end
  local saved = f:read("*a")
  f:close()
  if saved then
    saved = saved:gsub("%s+", "")
    if saved ~= "" then return saved end
  end
  return nil
end


-- %% =======================================================================
--  透明、高亮等选项恢复设置
-- ==========================================================================
--- 设置透明背景
local function set_transparent()
  if vim.g.transparent_enabled then
    local groups = {
      "Normal", "NormalNC", "NormalFloat",
      "FloatBorder", "EndOfBuffer",
    }
    for _, group in ipairs(groups) do
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
      if ok then
        hl.bg = nil
        vim.api.nvim_set_hl(0, group, hl)
      end
    end
  end
end

--- 设置其他模块的额外高亮配置
local function set_other_hls()
  -- 设置 rainbow-delimiters 括号颜色循环
  vim.api.nvim_set_hl(0, "RainbowDelimiterRed",    { fg = "#E06C75" })
  vim.api.nvim_set_hl(0, "RainbowDelimiterYellow",  { fg = "#E5C07B" })
  vim.api.nvim_set_hl(0, "RainbowDelimiterBlue",   { fg = "#61AFEF" })
  vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#D19A66" })
  vim.api.nvim_set_hl(0, "RainbowDelimiterGreen",  { fg = "#98C379" })
  vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#C678DD" })
  vim.api.nvim_set_hl(0, "RainbowDelimiterCyan",   { fg = "#56B6C2" })

  -- 设置 vim-slime Cells 分割线
  -- vim.api.nvim_set_hl(0, "CellBoundary", { underline = true, sp = "#E8A043" })
  -- 设置 user.utils.flashhl 高亮
  require("users.utils.flashhl").setup_highlight()
  require("users.mark_jump").setup_highlight()
end

--- 切换透明背景
function M.toggle_transparent()
  vim.g.transparent_enabled = not vim.g.transparent_enabled
  -- 切换背景之后之后要重新设置 colorscheme
  -- 设置 colorscheme 完成后，会触发事件监听、回调设置透明、高亮
  vim.cmd.colorscheme(vim.g.colors_name)
  vim.notify("Transparent BG: " .. (vim.g.transparent_enabled and "On" or "Off"))
end


-- %% =======================================================================
--  ColorScheme 载入
-- ==========================================================================
--- 载入 colorscheme
function M.load_colorscheme()
  -- 显式加载对应插件，colorscheme 插件均默认不加载
  local saved = M.load()
  if saved then
    -- `saved:match("^([^%-]+)")` 用以提取包含 flavour 的 colorscheme 
    -- 的模块名，如`catppuccin-mocha` 中模块名 `catppuccin`
    pcall(require, saved:match("^([^%-]+)"))
  else
    saved = M.opts.default_colorscheme
  end

  -- 设置 colorscheme
  local ok, err = pcall(vim.cmd.colorscheme, saved) -- pcall 捕获加载问题
  if not ok then
    vim.notify("Colorscheme " .. saved .. " failed: " .. err, vim.log.levls.ERROR)
  end

  -- 配置透明、高亮
  set_transparent()
  set_other_hls()
  -- 手动触发 `ColorScheme` 事件，确保 transparent_enabled 生效
  -- vim.cmd("doautocmd ColorScheme")
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

  vim.g.transparent_enabled = M.opts.transparent_enabled
  vim.api.nvim_create_user_command("ToggleTransparent", M.toggle_transparent, { desc = "Toggle Transparent" })
  if M.opts.set_keymap then
    vim.keymap.set("n", "<leader>uc", "<cmd>ToggleTransparent<cr>", { desc = "Toggle Transparent" })
  end

  local group = vim.api.nvim_create_augroup("colorscheme_switch", { clear = true })

  -- 自动保存 Colorscheme
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      vim.schedule(function()
        -- 保存 vim.g.colors_name 中颜色
        -- 不依赖事件监听的回调参数 `args.match`
        local name = vim.g.colors_name
        if name and name ~= "" then M.save(name) end
        set_transparent()
        set_other_hls()
      end)
    end,
  })

  -- 启动时恢复配色
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = M.load_colorscheme,
  })
end

return M
