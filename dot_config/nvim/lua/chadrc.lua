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

-- Click handler for the statusline diagnostics counts (called via %@...@ below).
-- Left click: current buffer's diagnostics. Right click: whole workspace.
_G.StDiagnosticsClick = function(_, _, button)
  if button == "r" then
    vim.cmd "Trouble diagnostics toggle"
  else
    vim.cmd "Trouble diagnostics toggle filter.buf=0"
  end
end

M.ui = {
  cheatsheet = { theme = "simple" }, -- "simple" is more compact than "grid"
  -- tabufline = { lazyload = false },

  statusline = {
    modules = {
      -- Same as NvChad's default diagnostics module, wrapped in a clickable region.
      diagnostics = function()
        local diag = require("nvchad.stl.utils").diagnostics()
        if diag:match "^%s*$" then
          return diag
        end
        return "%@v:lua.StDiagnosticsClick@" .. diag .. "%X"
      end,
    },
  },
}

return M
