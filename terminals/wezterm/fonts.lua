local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
	config.font = wezterm.font("Berkeley Mono")
	config.font_size = 14.0
	config.line_height = 1.0

	config.window_frame = {
		font = wezterm.font("Berkeley Mono"),
		font_size = 12.5,
	}
end

return Fonts
