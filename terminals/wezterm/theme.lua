local wezterm = require("wezterm")

local Theme = {}

function Theme.setup(config)
  config.color_scheme = 'Edge Dark (base16)'
  config.colors = {background = "#191919"}
end

return Theme
