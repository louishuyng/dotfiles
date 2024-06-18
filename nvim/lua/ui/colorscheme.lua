--[[ if vim.g.manual_set_background then
  -- Do nothing if manual trigger here
else
  local current_hour = tonumber(os.date("%H"))

  -- From 5am to 12pm, set light mode
  if current_hour >= 5 and current_hour <= 12 then
    vim.g.dark_mode = false
  else
    vim.g.dark_mode = true
  end
end ]]

if vim.g.dark_mode then
  vim.cmd('set background=dark')
else
  vim.cmd('set background=light')
end

vim.cmd("colorscheme catppuccin")
