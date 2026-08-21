-- ============================================================
-- colorscheme_switch.lua
-- ============================================================
local M = {}

M.defaults = {
  save_path = vim.fn.stdpath("data") .. "/last_colorscheme",
  default_colorscheme = "catppuccin-mocha",
  transparent_enabled = true,
}

-- 保存当前配色
M.save = function(name)
  local f = io.open(M.opts.save_path, "w")
  if f then
    f:write(name)
    f:close()
  end
end

-- 读取保存的配色
M.load = function()
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

-- 切换透明背景
M.toggle_transparent = function()
  vim.g.transparent_enabled = not vim.g.transparent_enabled
  vim.cmd.colorscheme(vim.g.colors_name)
  vim.notify("Transparent BG: " .. (vim.g.transparent_enabled and "On" or "Off"))
end

-- 自动保存 Colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.schedule(function()
      -- 保存：只用 vim.g.colors_name，不依赖 args.match
      local name = vim.g.colors_name
      if name and name ~= "" then
        M.save(name)
      end

      -- 透明背景
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

      -- vim-slime-cells 分割线
      vim.api.nvim_set_hl(0, "CellBoundary", {
        underline = true,
        sp = 0xe8a043,
      })
    end)
  end,
})

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

  -- 启动时恢复配色
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      local saved = M.load()
      if saved then
        -- 显式加载模块，colorscheme 插件均默认不加载
        -- 1. `saved:match("^([^%-]+)")` 用以提取包含 flavour 的 colorscheme 
        --   的模块名，如`catppuccin-mocha` 中模块名 `catppuccin`
        pcall(require, saved:match("^([^%-]+)"))
      else
        saved = M.opts.default_colorscheme
      end
      -- vim.cmd.colorscheme(saved)
      local ok, err = pcall(vim.cmd.colorscheme, saved) -- pcall 捕获加载问题
      if not ok then
        vim.notify("Colorscheme " .. saved .. " failed: " .. err, vim.log.levls.ERROR)
      end
      -- 手动触发 `ColorScheme` 事件，确保 transparent_enabled 生效
      vim.cmd("doautocmd ColorScheme")
    end,
  })

  vim.g.transparent_enabled = M.opts.transparent_enabled
  -- vim.keymap.set("n", "<leader>cc", "<cmd>Telescope colorscheme<CR>", { desc = "🎨 Switch ColorScheme" })
  vim.keymap.set("n", "<leader>ct", M.toggle_transparent, { desc = "Toggle Transparent" })
end

return M
