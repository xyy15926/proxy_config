-- ==========================================================================
-- File    : pyenv.lua
-- Author  : xyy15926
-- Created : 2026-08-28 17:28:54
-- Updated : 2026-09-16 09:10:49
-- Desc    : Settings for python env.
-- ==========================================================================

local M = {}
M.defaults = {
  set_keymap = true,
}
M.opts = vim.deepcopy(M.defaults)

-- %% =======================================================================
--  Pixi 相关设置
-- ==========================================================================
-- 检测是否有 pixi 环境
function M.has_pixi(root)
  root = root or require("users.rooter").find_project_root()
  return root ~= "" and vim.fn.glob(root .. "/.pixi") ~= ""
end

--- 给命令加上 pixi run 前缀
--- @param cmd table
--- @param root string?
--- @return table
function M.pixify(cmd, root)
  root = root or require("users.rooter").find_project_root()
  if M.has_pixi(root) then
    local new_cmd = { "pixi", "run" }
    for _, v in ipairs(cmd) do table.insert(new_cmd, v) end
    return new_cmd
  end
  return cmd
end


--- 给命令加上 pixi run 前缀
--- @param cmd string
--- @param root string?
--- @return string
function M.venv_cmd(cmd, root)
  root = root or require("users.rooter").find_project_root()
  local pixi_cmd = root .. "/.pixi/envs/default/bin/" .. cmd
  local venv_cmd = root .. "/.venv/bin/" .. cmd
  return vim.fn.filereadable(pixi_cmd) > 0 and pixi_cmd
    or vim.fn.filereadable(venv_cmd) > 0 and venv_cmd
    or vim.fn.exepath(cmd)
end


-- %% =======================================================================
--  项目结构相关
-- ==========================================================================
--- 查找对应单元测试文件
--- 支持 `foo.bar.mod` 对应 `foo/bar/test_mod.py`、`foo/test_mod.py`
---   等可能的单元测试文件
--- @param abspath string?
--- @param project_root string? 项目根目录
--- @return string?
function M.find_test_file(abspath, project_root)
  abspath = abspath or vim.fn.expand("%:p")
  local paths = vim.split(abspath, "/")
  local filename = paths[#paths]
  project_root = project_root or require("users.rooter").find_project_root()
  project_root = project_root:gsub("/+$", "") -- 去掉末尾 /

  local root_parts = vim.split(project_root, "/")
  local root_hier = #root_parts

  -- 提取项目内的相对路径部分（如 {"src", "module", "submod"}）
  local rel_parts = {}
  for i = root_hier + 1, #paths - 1 do
    rel_parts[#rel_parts + 1] = paths[i]
  end

  -- 从最完整的模块路径开始，逐级减少父包名
  -- 即，支持 `foo.bar.mod` 逐级查找 `foo/bar/test_mod.py`、`foo/test_mod.py`
  local n = #rel_parts
  -- 跳过 `src`：拼接从 2 开始、也跳过迭代
  for i = n, 2, -1 do
    -- `table.concat` 支持子表拼接
    local modname = table.concat(rel_parts, "/", 2, i)
    local testfile = project_root .. "/tests/" .. modname .. "/test_" .. filename
    if vim.fn.filereadable(testfile) == 1 then
      return testfile
    end
  end
  return nil
end


-- %% =======================================================================
--  模块初始化
-- ==========================================================================
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- 快速打开 python 单元测试文件
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("pyenv.test_file", { clear = true }),
    pattern = "python",
    callback = function(args)
      vim.api.nvim_buf_create_user_command(
        args.buf,
        "TabnewTestFile",
        function() vim.cmd.tabnew(M.find_test_file()) end,
        {}
      )
      if M.opts.set_keymap then
        vim.keymap.set("n", "<leader>ut", "<cmd>TabnewTestFile<cr>", { desc = "Tabnew Test File"} )
      end
    end,
  })
end

return M
