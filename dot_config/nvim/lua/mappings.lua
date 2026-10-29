-- General keymaps. NvChad's defaults load first (list them with <leader>ch).
require "nvchad.mappings"

-- Plugin-specific keymaps live in their plugin spec (`keys = { ... }`) under lua/plugins/.
-- Only general and NvChad-overriding keymaps belong here.

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>cs", function()
  vim.cmd("edit " .. vim.fn.stdpath "config" .. "/cheatsheet.md")
end, { desc = "Open vim cheatsheet" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Tmux-aware window navigation.
-- Kept here (not in the plugin spec) because these must run after nvchad.mappings,
-- which binds <C-hjkl> to plain window movement.
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Window: left (tmux-aware)" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Window: down (tmux-aware)" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Window: up (tmux-aware)" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Window: right (tmux-aware)" })
map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Window: previous (tmux-aware)" })
