return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "nvim-lua/plenary.nvim",       lazy = true },

  { import = "plugins.colorscheme" },
  { import = "plugins.treesitter" },
  { import = "plugins.ui" },
  { import = "plugins.sidebar" },
  { import = "plugins.navigation" },
  { import = "plugins.editing" },
  { import = "plugins.completion" },
  { import = "plugins.terminal" },
  { import = "plugins.overseer" },
  { import = "plugins.git" },
  { import = "plugins.whichkey" },
  { 
    dir = vim.env.HOME .. "/code/corse/sop.nvim",
    name = "sop.nvim",
    lazy = false
  },
}
