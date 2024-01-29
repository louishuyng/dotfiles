local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
  config.font = wezterm.font('Hack', {weight = 'Medium'})
  config.font_size = 12
  config.enable_csi_u_key_encoding = true
end

return Fonts
