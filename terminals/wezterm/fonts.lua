local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
	config.font = wezterm.font("JetBrainsMono Nerd Font Propo", { weight = "Regular" })
	config.font_size = 12.5
	config.line_height = 1.4
end

return Fonts
