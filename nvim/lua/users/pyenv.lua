-- ==========================================================================
-- File    : pyenv.lua
-- Author  : xyy15926
-- Created : 2026-08-28 17:28:54
-- Updated : 2026-09-17 22:22:03
-- Desc    : Settings for python env.
-- ==========================================================================

local M = {}
M.defaults = {
  set_keymap = true,
}
M.opts = vim.deepcopy(M.defaults)
local utils = require("users.utils")
local rooter = require("users.rooter")


-- %% =======================================================================
--  Pixi 相关设置
-- ==========================================================================
-- 检测是否有 pixi 环境
function M.has_pixi(root)
  root = root or rooter.find_project_root()
  return root ~= "" and vim.fn.glob(root .. "/.pixi") ~= ""
end


--- 给命令加上 pixi run 前缀
--- @param cmd table
--- @param root string?
--- @return table
function M.pixify(cmd, root)
  root = root or rooter.find_project_root()
  if M.has_pixi(root) then
    local new_cmd = { "pixi", "run" }
    for _, v in ipairs(cmd) do table.insert(new_cmd, v) end
    return new_cmd
  end
  return cmd
end


--- 查找、尝试获取虚拟环境的命令绝对路径
--- @param cmd string
--- @param root string?
--- @return string
function M.venv_cmd(cmd, root)
  root = root or rooter.find_project_root()
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
--- @param srcfile string? 源文件路径
--- @param project_root string? 项目根目录
--- @return string?
function M.find_test_file(srcfile, project_root)
  local abspath = srcfile and vim.fn.fnamemodify(srcfile, ":p")
    or vim.fn.expand("%:p")
  local paths = vim.split(abspath, "/")
  local filename = paths[#paths]
  project_root = project_root
    or vim.fs.root(abspath, rooter.opts.root_flags)
    or vim.fn.fnamemodify(abspath, ":h")
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
--  测试文件解析、测试函数收集
-- ==========================================================================
--- 获取指定节点所属的函数名、类名
--- @param node TSNode?
--- @param source string|integer?
--- @return string? func_name, string? class_name
function M.get_enclosing_name(node, source)
  node = node or vim.treesitter.get_node()
  source = source or 0
  local class_name, func_name

  while node do
    local t = node:type()

    -- function_definition 节点的 name 子节点就是函数名
    if t == "function_definition" and not func_name then
      local name_node = node:field("name")[1]
      if name_node then
        func_name = vim.treesitter.get_node_text(name_node, source)
      end

    -- class_definition 节点的 name 子节点就是类名
    elseif t == "class_definition" and not class_name then
      local name_node = node:field("name")[1]
      if name_node then
        class_name = vim.treesitter.get_node_text(name_node, source)
      end
    end
    node = node:parent()
  end
  return func_name, class_name
end


--- 遍历节点获取节点下所有测试函数（包括测试类中测试函数）
--- @param node TSNode Root node
--- @param source string|integer
--- @param class_ctx string? Parent class name
--- @return string[]
function M.collect_tests(node, source, class_ctx)
  local tests = {}

  for child in node:iter_children() do
    local t = child:type()

    if t == "class_definition" then
      local name_node = child:field("name")[1]
      if name_node then
        local cname = vim.treesitter.get_node_text(name_node, source)
        -- pytest 约定：Test 开头的类才会被收集
        if cname:match("^Test") then
          -- 递归进入类体，传入类名作为上下文（一般应只最多递归调用一次）
          local inner = M.collect_tests(child, source, cname)
          for _, item in ipairs(inner) do
            table.insert(tests, item)
          end
        end
      end
    elseif t == "function_definition" then
      local name_node = child:field("name")[1]
      if name_node then
        local fname = vim.treesitter.get_node_text(name_node, source)
        -- pytest 约定：test_ 开头的函数才会被收集
        if fname:match("^test_") then
          -- 有类上下文就拼成 Class::method，否则只保留函数名
          local full = class_ctx and (class_ctx .. "::" .. fname) or fname
          table.insert(tests, full)
        end
      end
    end
  end

  return tests
end


-- %% =======================================================================
--  获取测试函数
-- ==========================================================================
--- 获取测试文件中所有测试函数
--- @param testfile string 测试文件路径
--- @return string[]?
local function get_all_test_functions_from_tests(testfile)
  local source = utils.read_source(testfile)
  local parser = type(source) == "number"
    and vim.treesitter.get_parser(source, "python")
    or vim.treesitter.get_string_parser(source, "python")
  if parser == nil then return nil end
  local root = parser:parse()[1]:root()
  return M.collect_tests(root, source)
end


--- 获取文件或对应测试文件中所有测试函数
--- @param filepath string? 源文件、或测试文件路径
--- @return string[]? tests, string target
function M.get_all_test_functions(filepath)
  -- 确定查找测试函数的文件绝对路径
  local abspath = filepath and vim.fn.fnamemodify(filepath, ":p")
    or vim.fn.expand("%:p")
  local filename = vim.fn.fnamemodify(abspath, ":t")
  local target = filename:match("^test_") and abspath
    or M.find_test_file(abspath)
  return get_all_test_functions_from_tests(target), target
end


--- 尝试获取源文件中函数对应的测试函数
--- 若对应测试文件不存在则返回 nil
--- 若测试文件存在，但是默认测试函数不存在，则要求客户手动选择
--- @param func_name string? 默认当前函数
--- @param class_name string? 默认当前类
--- @param srcfile string? 默认当前源文件
--- @return string?
function M.find_test_function_for_src(func_name, class_name, srcfile)
  if func_name == nil then func_name, class_name = M.get_enclosing_name() end
  local testfile = M.find_test_file(srcfile)
  if testfile == nil or func_name == nil then return nil end

  -- 拼接默认测试函数
  local testfunc = "test_" ..
    (class_name and class_name .. "::" .. func_name or func_name)

  local all_tests = get_all_test_functions_from_tests(testfile)
  if all_tests == nil or #all_tests == 0 then return nil end

  -- 默认测试函数存在，则直接作为测试目标
  if not vim.tbl_contains(all_tests, testfunc) then
    local menu = { "Select test function:" }
    for i, item in ipairs(all_tests) do
      menu[#menu + 1] = i .. ") " .. item
    end
    local choice = vim.fn.inputlist(menu)
    testfunc = choice > 0 and all_tests[choice] or ""
  end

  -- 指定测试函数或整个测试文件
  if testfunc == "" then
    return nil
  else
    return testfile .. "::" .. testfunc
  end
end


--- 在测试文件中拼接测试函数
--- @return string?
function M.concat_test_function()
  local func_name, class_name = M.get_enclosing_name()
  local base = vim.fn.expand("%:p")
  local target = class_name and class_name:match("^Test")
    and base .. "::" .. class_name
    or base
  target = func_name and func_name:match("^test_")
    and target .. "::" .. func_name
    or target
  if target == base then return nil else return target end
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
