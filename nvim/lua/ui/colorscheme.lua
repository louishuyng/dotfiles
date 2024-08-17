local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope

if vim.g.theme == "gruvbox" then
  vim.g.gruvbox_baby_transparent_mode = 1

  vim.cmd [[
    set background=dark
    colorscheme gruvbox-baby
  ]]

  highlight_telescope()
end

if vim.g.theme == "mocha" then
  vim.cmd [[
    set background=dark
    colorscheme catppuccin

    hi Normal guibg=#1e1e1e
    hi NormalNC guibg=#1e1e1e
    hi WinSeparator guifg=#1e1e1e
  ]]

  transaprent()
  highlight_telescope()
end

if vim.g.theme == 'edge' then
  vim.cmd [[
    set background=dark

    let g:edge_better_performance = 1

    colorscheme edge

    hi Normal guibg=#000000
    hi NormalNC guibg=#000000
    hi WinSeparator guifg=#000000
  ]]

  transaprent()
  highlight_telescope()
end

if vim.g.theme == 'edge-light' then
  vim.cmd [[
    set background=light

    let g:edge_better_performance = 1
    colorscheme edge
  ]]
end

if vim.g.theme == "minimal" then
  vim.cmd [[
    set background=dark

    colorscheme minimal-base16
  ]]

  gitTransparent()
  highlight_telescope()
end
