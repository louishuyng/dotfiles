local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope

if vim.g.theme == 'leaf' then
  require("leaf").setup({
    theme = "dark",      -- default, based on vim.o.background, alternatives: "light", "dark"
    contrast = "medium", -- default, alternatives: "medium", "high"
    overrides = {
      Normal = { bg = "#181818" },
      WinSeparator = { fg = "#181818" },
      NvimTreeNormal = { bg = '#282828' }
    }
  })

  vim.cmd [[
    colorscheme leaf
  ]]

  highlight_telescope()
end

if vim.g.theme == "mocha" then
  vim.cmd [[
    set background=dark
    colorscheme catppuccin

    hi Normal guibg=#131416
    hi NormalNC guibg=#131416
    hi WinSeparator guifg=#131416

    hi NvimTreeNormal guibg=#1A1C1E
  ]]

  transaprent()
  highlight_telescope()
end
