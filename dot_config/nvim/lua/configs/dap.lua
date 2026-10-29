-- =============================================================================
-- Debuggers (nvim-dap). Every language's debug setup is in this file.
-- Keymaps are in plugins/dap.lua; start debugging with <leader>dc.
--
-- Adapter     = how Neovim talks to a language's debugger.
-- Configurations = the entries you pick from when you press <leader>dc.
-- =============================================================================

local dap = require "dap"
local mason = vim.fn.stdpath "data" .. "/mason"

-- -----------------------------------------------------------------------------
-- Python (debugpy via nvim-dap-python)
-- -----------------------------------------------------------------------------
-- debugpy runs from Mason's own venv; your program still runs with the project's
-- interpreter ($VIRTUAL_ENV, or .venv/venv in the project).
require("dap-python").setup(mason .. "/packages/debugpy/venv/bin/python")

-- -----------------------------------------------------------------------------
-- JavaScript / TypeScript (js-debug-adapter)
-- -----------------------------------------------------------------------------
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = mason .. "/bin/js-debug-adapter",
    args = { "${port}" },
  },
}

for _, lang in ipairs { "javascript", "typescript" } do
  dap.configurations[lang] = {
    {
      -- Node 23.6+ runs .ts files directly, so this works for both languages.
      type = "pwa-node",
      request = "launch",
      name = "Launch current file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      -- For apps already running with `node --inspect`.
      type = "pwa-node",
      request = "attach",
      name = "Attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

-- -----------------------------------------------------------------------------
-- Java (adapter comes from jdtls, see configs/lspconfig.lua)
-- -----------------------------------------------------------------------------
-- Main classes are offered automatically once jdtls is running.
-- This entry attaches to a JVM started with JDWP on port 5005, e.g.
--   java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 ...
dap.configurations.java = {
  {
    type = "java",
    request = "attach",
    name = "Attach to JVM (port 5005)",
    hostName = "127.0.0.1",
    port = 5005,
  },
}

-- -----------------------------------------------------------------------------
-- Rust
-- -----------------------------------------------------------------------------
-- Handled by rustaceanvim: it finds codelldb from Mason on its own.
-- Use <leader>rd in a Rust file to pick a binary or test to debug.
