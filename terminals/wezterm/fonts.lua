local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
	config.font = wezterm.font("JetBrainsMono Nerd Font Propo", { weight = "Regular" })
	config.font_size = 12.5
	config.line_height = 1.05

	config.window_frame = {
		font = wezterm.font("JetBrainsMono Nerd Font Propo", { weight = "Bold" }),
		font_size = 13.0,
	}
end

return Fonts
