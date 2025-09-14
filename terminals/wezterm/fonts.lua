local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
	config.font = wezterm.font("Berkeley Mono", { weight = "Medium" })
	config.font_size = 12.5
	config.line_height = 1.3
end

return Fonts
