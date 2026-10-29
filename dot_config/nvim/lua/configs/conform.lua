-- =============================================================================
-- Formatters (conform.nvim). Runs on save and with <leader>fm.
-- Install formatters with :MasonInstall <name>. Check what runs with :ConformInfo.
-- =============================================================================

-- Shared by every JS/TS-family filetype below.
local prettier = { "prettier" }

local options = {
  -- Formatters run in order. Filetypes not listed fall back to their LSP's formatter.
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" }, -- from rustup, not Mason
    python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    json = prettier,
    -- css = prettier,
    -- html = prettier,
  },

  default_format_opts = { lsp_format = "fallback" },

  -- Comment this out to only format manually with <leader>fm.
  format_on_save = {
    timeout_ms = 500,
  },
}

return options
