-- =============================================================================
-- Language servers: every LSP in this config is set up in this file.
--
-- Adding a language usually takes two steps:
--   1. Install the server: :MasonInstall <name>   (browse them with :Mason)
--   2. Add its lspconfig name to `servers` below  (list: :help lspconfig-all)
-- Server-specific settings go in a vim.lsp.config("<name>", { ... }) block.
-- Formatters live in configs/conform.lua, debuggers in configs/dap.lua.
-- =============================================================================

-- NvChad defaults: LSP keymaps (gd, K, <leader>ra, ...), completion capabilities,
-- and lua_ls preconfigured for editing Neovim config.
require("nvchad.configs.lspconfig").defaults()

local mason = vim.fn.stdpath "data" .. "/mason"

-- Servers started by Neovim whenever a file of their language is opened.
local servers = {
  "lua_ls", -- Lua
  "html", -- HTML
  "cssls", -- CSS
  "pyright", -- Python: types, completion, go-to-definition
  "ruff", -- Python: linting and quick fixes
  "ts_ls", -- JavaScript / TypeScript
  "jdtls", -- Java
  -- Rust is not listed here: rustaceanvim starts rust-analyzer itself (see below).
}

-- -----------------------------------------------------------------------------
-- Python
-- -----------------------------------------------------------------------------
-- pyright and ruff both run on Python files; let pyright answer hover (K)
-- so you don't get two popups.
vim.lsp.config("ruff", {
  on_init = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

-- -----------------------------------------------------------------------------
-- Java
-- -----------------------------------------------------------------------------
vim.lsp.config("jdtls", {
  -- Load the java-debug extension so jdtls can start debug sessions.
  init_options = {
    bundles = vim.fn.glob(
      mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
      true,
      true
    ),
  },
  settings = {
    java = {
      project = { sourcePaths = { "src" } }, -- plain projects without Maven/Gradle
      configuration = { updateBuildConfiguration = "automatic" },
    },
  },
  -- Register jdtls as a debug adapter (nvim-jdtls), with hot code reload.
  on_attach = function()
    require("jdtls").setup_dap { hotcodereplace = "auto" }
  end,
})

-- -----------------------------------------------------------------------------
-- Rust
-- -----------------------------------------------------------------------------
-- Settings only. rustaceanvim (plugins/lang.lua) starts the server and reads this
-- block. Note the name is "rust-analyzer" (hyphen), not lspconfig's "rust_analyzer".
vim.lsp.config("rust-analyzer", {
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" }, -- show clippy lints, not just compiler errors
      cargo = { allFeatures = true }, -- analyse code behind every cargo feature
    },
  },
})

vim.lsp.enable(servers)
