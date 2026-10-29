-- NvChad UI settings: theme, statusline, tabline, dashboard, cheatsheet.
-- Must follow the structure of nvconfig.lua, which lists every option:
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "noctalia", -- generated into lua/themes/; preview others with <leader>th

  -- hl_override = {
  --   Comment = { italic = true },
  --   ["@comment"] = { italic = true },
  -- },
}

-- M.nvdash = { load_on_startup = true }

M.ui = {
  cheatsheet = { theme = "simple" }, -- "simple" is more compact than "grid"
  -- tabufline = { lazyload = false },
}

return M
