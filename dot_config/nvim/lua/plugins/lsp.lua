-- LSP and formatting plugins. The actual settings live in:
--   configs/lspconfig.lua  (language servers)
--   configs/conform.lua    (formatters)
return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- load before the first save so format-on-save works
    cmd = "ConformInfo",
    opts = require "configs.conform",
  },

  -- Try blink.cmp instead of nvim-cmp for completion:
  -- { import = "nvchad.blink.lazyspec" },
}
