-- General editing helpers.
return {
  -- Project-wide list of diagnostics, references, etc. (:Trouble diagnostics)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
  },

  -- Renders headings, tables and checkboxes nicely inside markdown buffers
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  -- Session saving (:Obsession), pairs with tmux-resurrect
  {
    "tpope/vim-obsession",
    cmd = "Obsession",
  },
}
