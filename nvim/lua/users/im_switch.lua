-- ==========================================================================
-- File    : im_switch.lua
-- Author  : xyy15926
-- Created : 2026-09-16 10:11:54
-- Updated : 2026-09-16 10:12:27
-- Desc    : Auto switch input method.
--
-- --------------------------------------------------------------------------
-- 自动切换中英文
--
-- 1. im-select.exe 能、只能用于切换输入法，不是用于切换输入法中英文模式
-- 2. 则，为中、英文分别添加输入法实现中英文切换
-- 2.1 似乎默认中文输入法都是 2052，英文输入法是 1033
-- 3. 为方便使用，同时建议开启 `设置-时间与语言-输入-高级键盘设置-允许我为每个应用窗口使用不同的输入法`
--
-- Ref:
-- - https://zhuanlan.zhihu.com/p/600565445
-- - https://github.com/daipeihust/im-select
-- - im-select.exe: https://raw.githubusercontent.com/daipeihust/im-select/master/win/out/x86/im-select.exe
-- ==========================================================================

local M = {}

M.defaults = {
  im_select = "im-select.exe",
}
M.opts = vim.deepcopy(M.defaults)


local function setup_im_select(im_select)
  im_select = vim.fn.exepath(im_select)
  if im_select ~= "" then
    vim.api.nvim_create_autocmd({ "VimEnter", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("autoswitch.chneng", { clear = true }),
      pattern = "*",
      callback = function()
        -- 切换至英文输入法
        vim.system({ im_select, "1033" })
      end,
    })
    vim.api.nvim_create_autocmd({ "VimLeave", "InsertEnter" }, {
      group = vim.api.nvim_create_augroup("autoswitch.engchn", { clear = true }),
      pattern = "*",
      callback = function()
        -- 切换至中文输入法
        vim.system({ im_select, "2052" })
      end,
    })
  end
end


function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
  setup_im_select(M.opts.im_select)
end

return M
