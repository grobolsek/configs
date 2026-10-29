-- Editor options. NvChad's defaults load first; anything below overrides them.
-- See :help options, or :help '<name>' for a single option.
require "nvchad.options"

local opt = vim.opt

-- opt.cursorlineopt = "both" -- to enable cursorline!

-- Command-line completion
opt.wildignorecase = true -- case-insensitive file completion
opt.wildignore = { -- skip these in :e completion
  "*.class",
  "*.jar",
  "*.pyc",
  "node_modules/*",
  "target/*",
  ".git/*",
}
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- Spelling
opt.spell = true
opt.spelllang = { "en" }
