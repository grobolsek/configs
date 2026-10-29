-- =============================================================================
-- Entry point. Load order: lazy.nvim -> plugins -> theme -> options -> keymaps.
--
--   lua/options.lua, mappings.lua, autocmds.lua   editor settings
--   lua/chadrc.lua                                NvChad UI/theme settings
--   lua/plugins/*.lua                             which plugins to install (lazy.nvim specs)
--   lua/configs/*.lua                             larger plugin settings used by those specs
--   after/ftplugin/<filetype>.lua                 settings/keymaps for one filetype only
-- =============================================================================

-- where NvChad's theme engine (base46) writes compiled highlight files
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " " -- must be set before plugins define <leader> keymaps

-- bootstrap lazy.nvim (the plugin manager): clone it on first start
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load NvChad itself plus every spec in lua/plugins/
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- apply the theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

-- keymaps are deferred so they override any set while plugins load
vim.schedule(function()
  require "mappings"
end)
