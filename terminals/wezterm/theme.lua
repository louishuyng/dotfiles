local wezterm = require("wezterm")

local Theme = {}

function Theme.setup(config)
  config.color_scheme = 'Edge Dark (base16)'
  config.colors = {background = "#0F0F0F", foreground = "#98c379"}
end

return Theme
