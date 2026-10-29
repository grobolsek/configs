-- nvim-tree (file explorer, <C-n>) options. See :help nvim-tree-setup.
local options = {
  actions = {
    open_file = {
      quit_on_open = false, -- keep the tree open after opening a file
      -- with several splits open, ask which one to open the file in
      window_picker = {
        enable = true,
        picker = "default",
        exclude = {
          filetype = { "notify", "NvimTree", "terminal" },
          buftype = { "terminal" },
        },
      },
    },
  },
}

return options
