if vim.g.manual_set_background then
  -- Do nothing if manual trigger here
else
  local current_hour = tonumber(os.date("%H"))

  -- From 5am to 12pm, set light mode
  if current_hour >= 5 and current_hour <= 12 then
    vim.g.dark_mode = false
  else
    vim.g.dark_mode = true
  end
end

if vim.g.dark_mode then
  vim.cmd('set background=dark')
  vim.api.nvim_command("colorscheme edge")

  vim.cmd([[
    hi VertSplit guifg=grey guibg=NONE

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

    hi NvimTreeGitStaged guifg=#99cc99 guibg=NONE
    hi NvimTreeGitDirty guifg=#cc6666 guibg=NONE

    hi AlphaHeader guifg=#89b482
    hi AlphaButton guifg=#89b482
    hi AlphaFooter guifg=#89b482
  ]])
else
  -- Reset Highlight
  vim.cmd('hi clear')
  vim.cmd('set background=light')
  vim.cmd('colorscheme bamboo')
  vim.cmd("hi MatchParen guibg=NONE guifg=NONE gui=bold")
end
