-- Plugins that add extra support for a specific language, beyond its plain LSP.
-- Server settings for these languages still live in configs/lspconfig.lua.
return {
  -- Rust: starts rust-analyzer, adds runnables/debuggables and hover actions.
  -- Rust-only keymaps are in after/ftplugin/rust.lua.
  {
    "mrcjkb/rustaceanvim",
    lazy = false, -- the plugin lazy-loads itself on Rust buffers
  },

  -- Rust: crate versions, features and completion inside Cargo.toml.
  {
    "saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    opts = {
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
  },

  -- Java: jdtls extras, mainly debugging (setup_dap) and opening library sources
  -- (jdt:// links). The server itself is started from configs/lspconfig.lua.
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },
}
