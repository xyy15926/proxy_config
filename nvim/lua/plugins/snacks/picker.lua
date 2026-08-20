-- =======================================================
-- snacks.picker config
-- =======================================================

-- 辅助函数：picker 中打开文件
-- local function open_file(cmd)
--   return function(picker)
--     local item = picker:current()
--     if item and item.file then
--       picker:close()
--       vim.cmd(cmd .. " " .. vim.fn.fnameescape(item.file))
--     end
--   end
-- end

-- 辅助函数：explorer 中打开文件
-- local function explorer_open(cmd)
--   return function(picker)
--     local item = picker:current()
--     if not item then return end
--
--     -- 目录：交给内置 confirm 处理（展开/折叠）
--     if item.dir then
--       picker:action("confirm")
--       return
--     end
--
--     -- 文件：用指定方式打开
--     if item.file then
--       picker:close()
--       vim.cmd(cmd .. " " .. vim.fn.fnameescape(item.file))
--     end
--   end
-- end


return {
  enabled = true,
  layout = { preset = "telescope" },
  -- 窗口配置
  -- 关于 pickcer 中 3 个窗口的说明：
  -- 1. snacks.picker 实际上由 input 搜索框、list 结果列表、preview 预览三个
  --   独立窗口组成
  -- 2. list.keys 中的绑定只在光标真正位于 list（结果列表）窗口时才生效
  --   2.1 而，实际当在 input 窗口按 <Esc> 进入 normal 模式后，虽然可用 j、k 
  --     上下移动列表项，但光标 ”焦点 focues" 仍在 input 窗口
  --   2.2 j、k 能导航列表是因为 input.keys 中把它们显式映射成了 list_down、
  --     list_up，并不是因为你已经在 list 窗口里
  win = {
    input = {
      keys = {
        -- 默认行为，无需配置
        -- ["/"] = "toggle_focus",
        ["<Tab>"] = { "select_and_next", mode = { "i", "n" } },
        ["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" } },
        ["<C-j>"] = { "list_down", mode = { "i", "n" } },
        ["<C-k>"] = { "list_up", mode = { "i", "n" } },
        ["<CR>"] = { "confirm", mode = { "n", "i" } },
        ["<C-s>"] = { "edit_split", mode = { "i", "n" } },
        ["<C-v>"] = { "edit_vsplit", mode = { "i", "n" } },
        ["<C-t>"] = { "tab", mode = { "n", "i" } },
        ["<C-q>"] = { "qflist", mode = { "i", "n" } },
        ["<C-c>"] = { "cancel", mode = "i" },
        ["<Esc>"] = "cancel",
        ["j"] = "list_down",
        ["k"] = "list_up",
        ["q"] = "cancel",
        ["?"] = "toggle_help_input",
        -- ["<M-w>"] = { "cycle_win", mode = { "n", "i", "x"}, desc = "Cycle window focus" },
        -- 新增映射
        ["s"] = { "edit_split", mode = { "n" }, desc = "edit_split" },
        ["v"] = { "edit_vsplit", mode = { "n" }, desc = "edit_vsplit" },
        ["t"] = { "tab", mode = { "n" }, desc = "edit_newtab" },
      },
    },
    list = {
      keys = {
        -- 默认行为，无需配置
        ["<2-LeftMouse>"] = "confirm",
        ["<CR>"] = "confirm",
        ["i"] = "focus_input",
        ["j"] = "list_down",
        ["k"] = "list_up",
        ["q"] = "cancel",
        ["<Tab>"] = { "select_and_next", mode = { "n", "x" } },
        ["<S-Tab>"] = { "select_and_prev", mode = { "n", "x" } },
        ["?"] = "toggle_help_list",
        -- ["<M-w>"] = { "cycle_win", mode = { "n", "i", "x"}, desc = "Cycle window focus" },
        -- 新增映射
        ["s"] = { "edit_split", mode = { "n" }, desc = "edit_split" },
        ["v"] = { "edit_vsplit", mode = { "n" }, desc = "edit_vsplit" },
        ["t"] = { "tab", mode = { "n" }, desc = "edit_newtab" },
      },
      wo = {
        conceallevel = 2,
        concealcursor = "nvc",
      },
    },
    preview = {
      keys = {
        -- 默认行为，无需配置
        ["<Esc>"] = "cancel",
        ["q"] = "cancel",
        ["i"] = "focus_input",
        ["<Tab>"] = "cycle_win",
        -- ["<M-w>"] = { "cycle_win", mode = { "n", "i", "x"}, desc = "Cycle window focus" },
      },
    },
  },

  -- 为 picker 的不同数据来源分别配置
  -- 所有和候选列表（即 pickcer）相关内容都位于此处，而不是分散在对应部件
  sources = {
    colorschemes = { preview = "colorscheme" },
    explorer = {
      replace_netrw = true,
      layout = {
        layout = {
          width = 30,
          min_width = 20,
          position = "left",
        },
      },
      win = {
        input = {
          keys = {
            [ "<C-t>" ] = { "tab", mode = { "i", "n" } },
            [ "w" ] = { function() vim.cmd("wincmd l") end, mode = "n", desc = "Right Window" },
            -- 新增映射
            ["s"] = { "edit_split", mode = { "n" }, desc = "edit_split" },
            ["v"] = { "edit_vsplit", mode = { "n" }, desc = "edit_vsplit" },
            ["t"] = { "tab", mode = { "n" }, desc = "edit_newtab" },
          },
        },
        list = {
          keys = {
            -- `explorer_open`：用文件管理器打开，在 WSL 应禁用此功能，或改映射
            -- [ "o" ] = false,
            [ "o" ] = "confirm",

            -- snacks 的 list 窗口设置 `buftype = "nofile" 和特殊的输入处理逻辑，
            -- 1. `<c-w>` 被视为普通序列
            -- 2. 在 snacks 的 list.keys 里，字符串会被当作内置 action 名去查找，而不是 Vim 命令，
            --   即必须使用 `function` 写法，不能 `<cmd> wincmd l`
            -- 3. 为实用，仅设置 `w` 将 list 焦点移至右侧
            --   3.1 一般情况下，不会在文件导航栏处使用 `w` 跳跃至下个单词
            [ "w" ] = { function() vim.cmd("wincmd l") end, mode = "n", desc = "Right Window" },
            -- 调换 `<C-t>` 和 `<M-t>`，保持 `<C-s>`、`<C=v>`、`<C-t>` 逻辑一致
            [ "<C-t>" ] = { "tab" , mode = "n", desc = "edit_newtab" },
            [ "<M-t>" ] = { "terminal", mode = "n", desc = "terminal" },
            -- 新增映射
            ["s"] = { "edit_split", mode = { "n" }, desc = "edit_split" },
            ["v"] = { "edit_vsplit", mode = { "n" }, desc = "edit_vsplit" },
            ["t"] = { "tab", mode = { "n" }, desc = "edit_newtab" },
          },
        },
      },
    },
  },
}
