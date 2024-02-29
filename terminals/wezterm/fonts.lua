local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
  config.font = wezterm.font('JetBrainsMono Nerd Font', {weight = 'Medium'})
  config.font_size = 11
end

return Fonts
