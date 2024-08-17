local function transaprent(opts)
  if opts == nil then
    opts = {}
  end

  if opts.background == "transparent" then
    vim.cmd [[
      hi Normal guibg=NONE
      hi NormalNC guibg=NONE
    ]]
  end

  vim.cmd [[
    hi SignColumn guibg=NONE
    hi LineNr guibg=NONE
    hi WinSeparator guifg=#000000
    hi MsgArea guibg=NONE
  ]]
end

local function gitTransparent()
  vim.cmd [[
    hi GitSignsAdd guibg=NONE
    hi GitSignsChange guibg=NONE
    hi GitSignsDelete guibg=NONE
    hi GitSignsChangeDelete guibg=NONE
    hi GitSignsStagedAdd guibg=NONE
    hi GitSignsStagedChange guibg=NONE
    hi GitSignsStagedDelete guibg=NONE
    hi GitSignsStagedChangeDelete guibg=NONE
  ]]
end

local function highlight_telescope()
  vim.cmd [[
    hi TelescopePreviewBorder guibg=#21252E guifg=#21252E
    hi TelescopePreviewNormal guibg=#21252E
    hi TelescopePreviewTitle guibg=#21252E guifg=#21252E
    hi TelescopePromptBorder guibg=#2E323B guifg=#2E323B
    hi TelescopePromptCounter guifg=#c0afff gui=bold
    hi TelescopePromptNormal guibg=#2E323B
    hi TelescopePromptPrefix guibg=#2E323B
    hi TelescopePromptTitle guifg=#2E323B guibg=#2E323B
    hi TelescopeResultsBorder guibg=#222222 guifg=#222222
    hi TelescopeResultsNormal guibg=#222222
    hi TelescopeResultsTitle guibg=#222222 guifg=#222222
    hi TelescopeSelection guibg=#2E323B
  ]]
end

return {
  transaprent = transaprent,
  gitTransparent = gitTransparent,
  highlight_telescope = highlight_telescope,
}
