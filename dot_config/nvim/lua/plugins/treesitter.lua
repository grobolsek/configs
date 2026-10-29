-- Syntax parsers for highlighting, indenting and text objects.
-- Installed automatically on startup; add a language with :TSInstall <lang>
-- or by adding it here. (Requires the `tree-sitter` CLI.)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- extend NvChad's list (lua, vim, vimdoc, ...) instead of replacing it
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "toml",
        "python",
        "java",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "html",
        "css",
        "markdown",
        "markdown_inline",
      })
    end,
  },
}
