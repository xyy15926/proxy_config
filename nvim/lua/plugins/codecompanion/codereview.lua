-- ==========================================================================
-- File    : codereview.lua
-- Author  : xyy15926
-- Created : 2026-09-04 10:06:36
-- Updated : 2026-09-04 10:44:55
-- Desc    : Config for codereview.
-- ==========================================================================

local M = {}

-- 阈值:超过这个变更行数就开分屏对比
M.threshold = tonumber(vim.env.CODECOMPANION_DIFF_THRESHOLD) or 30

-- 用 git --numstat 估算 diff 体量
local function diff_size(target)
  local out = vim.fn.system({
    "git", "-C", target.root,
    "diff", "--numstat", target.baseline_ref, "--", target.path,
  })
  local added, removed = out:match("^(%d+)%s+(%d+)")
  return (tonumber(added) or 0) + (tonumber(removed) or 0)
end

-- 用 vim.diff 把统一 diff 解析成 hunks,看 hunk 个数 / 跨度
local function hunk_stats(target)
  local out = vim.fn.system({
    "git", "-C", target.root,
    "diff", target.baseline_ref, "--", target.path,
  })
  if vim.v.shell_error ~= 0 or out == "" then
    return 0, 0
  end
  local hunks = vim.diff(out, "", {
    result_type = "indices",
    algorithm = "myers",
  })
  if not hunks or #hunks == 0 then
    return 0, 0
  end
  local max_span = 0
  for _, h in ipairs(hunks) do
    max_span = math.max(max_span, (h[3] or 0) - (h[1] or 0) + 1)
  end
  return #hunks, max_span
end

-- 小 diff:Gitsigns 内嵌预览(不破坏窗口布局)
local function preview_in_place(target)
  -- 1) 打开工作文件
  local work = vim.fs.joinpath(target.root, target.path)
  vim.cmd("edit " .. vim.fn.fnameescape(work))

  -- 2) 让 gitsigns 知道 baseline 是哪个 ref
  vim.cmd("Gitsigns change_base " .. target.baseline_ref)

  -- 3) 触发 inline preview(只在当前 buffer 内显示,非 split)
  --    Gitsigns 默认不内嵌 diff,我们用 :Gitsigns preview_hunk_inline
  --    跳到 hunk 上再调用,会浮出一行预览
  local hunks = vim.api.nvim_exec2("Gitsigns nav_hunk next", { output = true }).output
  if hunks and hunks ~= "" then
    pcall(vim.cmd, "Gitsigns preview_hunk_inline")
  end
end

-- 大 diff:用 Gitsigns 的垂直/水平分屏对比
local function split_diff(target, layout)
  local work = vim.fs.joinpath(target.root, target.path)
  local opposite = (layout == "horizontal") and "split" or "vsplit"

  -- 1) 左侧/上方:工作文件
  vim.cmd("edit " .. vim.fn.fnameescape(work))

  -- 2) 右侧/下方:先开分屏,再让 Gitsigns 把对侧换成 baseline 版本
  vim.cmd(opposite)
  vim.cmd("Gitsigns change_base " .. target.baseline_ref)
  --    切到新分屏,打开同一文件,Gitsigns 会以 baseline 渲染
  vim.cmd("wincmd p") -- 切回工作文件侧
  vim.cmd("Gitsigns toggle_current_line_blame")
  --    在新分屏里打开文件
  vim.cmd("wincmd p")
  vim.cmd("edit " .. vim.fn.fnameescape(work))
  -- 强制让 gitsigns 用 baseline 渲染这一侧
  vim.cmd("Gitsigns change_base " .. target.baseline_ref)
  -- 切回工作文件侧,光标留在那里(评论从工作文件发起)
  vim.cmd("wincmd p")
end

function M.provider(target)
  -- target = { root, path, baseline_ref, line, id }
  local total = diff_size(target)
  local hunk_count = hunk_stats(target)

  -- 触发条件:行数少 或 仅单个 hunk
  local use_preview = total <= M.threshold or hunk_count <= 1

  if use_preview then
    preview_in_place(target)
  else
    split_diff(target, "vertical") -- 也可读 display.diff.layout
  end
end

return {
  enabled = true,
  -- 在 review quickfix 窗口的快捷键配置，默认如下
  keymaps = {
    accept = {
      modes = { n = "a" },
      callback = "keymaps.accept",
      description = "Accept the hunk under the cursor",
    },
    comment = {
      modes = { n = "c" },
      callback = "keymaps.comment",
      description = "Comment on the hunk under the cursor",
    },
    diff = {
      modes = { n = "d" },
      callback = "keymaps.diff",
      description = "Diff the hunk under the cursor against the baseline",
    },
    -- 禁用 ignore
    ignore = false,
    -- ignore = {
    --   modes = { n = "x" },
    --   callback = "keymaps.ignore",
    --   description = "Ignore the hunk's file until the baseline advances",
    -- },
  },
  display = {
    diff = {
      enabled = true,
      layout = "vertical",
      provider = "native",
    },
    virtual_text = {
      enabled = true, -- Show pending comments as virtual text in the buffer
      icon = "💬 ", -- The icon to use for virtual text
      overflow = "trunc", -- See `:h nvim_buf_set_extmark` for `virt_lines_overflow`
    },
  },
  opts = {
    storage_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "codecompanion", "code_review"),
  },
}
