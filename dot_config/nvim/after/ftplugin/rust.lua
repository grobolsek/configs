-- Runs for every Rust buffer. Keymaps are buffer-local, so they only exist in
-- Rust files and override the general LSP ones (K, <leader>ca) there.
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = "Rust: " .. desc })
end

map("<leader>ca", function()
  vim.cmd.RustLsp "codeAction" -- also shows rust-analyzer's grouped actions
end, "Code action")
map("K", function()
  vim.cmd.RustLsp { "hover", "actions" }
end, "Hover actions")
map("<leader>rr", function()
  vim.cmd.RustLsp "runnables"
end, "Runnables")
map("<leader>rt", function()
  vim.cmd.RustLsp "testables"
end, "Testables")
map("<leader>rd", function()
  vim.cmd.RustLsp "debuggables"
end, "Debuggables")
map("<leader>re", function()
  vim.cmd.RustLsp "explainError"
end, "Explain error")
map("<leader>rc", function()
  vim.cmd.RustLsp "openCargo"
end, "Open Cargo.toml")
