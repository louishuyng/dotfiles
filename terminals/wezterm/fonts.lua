local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
	config.font = wezterm.font("JetBrainsMono Nerd Font Propo", { weight = "Regular" })
	config.font_size = 13.0
	config.line_height = 1.0

        config.window_frame = {
            font = wezterm.font("Berkeley Mono", { weight = "Bold" }),
            font_size = 13.0,
        }
end

return Fonts
