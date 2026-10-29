-- Moving around: fuzzy finding, file tree, split/tmux navigation.
return {
  -- Fuzzy finder (<leader>ff files, <leader>fw grep, <leader>fb buffers)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      -- faster, fzf-style sorting (compiled with make)
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    -- extend NvChad's defaults instead of replacing them
    opts = function(_, opts)
      -- search from the git repo root, not just the current directory
      opts.defaults.cwd = vim.fs.root(0, ".git") or vim.fn.getcwd()
      return opts
    end,
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
      telescope.load_extension "fzf"
    end,
  },

  -- File explorer (<C-n>); options in configs/nvimtree.lua
  {
    "nvim-tree/nvim-tree.lua",
    opts = require "configs.nvimtree",
  },

  -- Seamless <C-hjkl> between nvim splits and tmux panes (keymaps in lua/mappings.lua)
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
  },
}
