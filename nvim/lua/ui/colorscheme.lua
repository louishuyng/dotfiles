--[[ if vim.g.manual_set_background then
  -- Do nothing if manual trigger here
else
  local current_hour = tonumber(os.date("%H"))

  -- From 5am to 6pm use light mode
  if current_hour >= 5 and current_hour <= 18 then
    vim.g.dark_mode = false
  else
    vim.g.dark_mode = true
  end
end

if vim.g.dark_mode then
  vim.cmd('set background=dark')
else
  vim.cmd('set background=light')
end ]]

vim.api.nvim_command("colorscheme catppuccin")
