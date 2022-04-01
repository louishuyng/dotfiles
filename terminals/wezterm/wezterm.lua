-- WezTerm
-- https://wezfurlong.org/wezterm/

local wezterm = require 'wezterm'

return {
  window_close_confirmation = "NeverPrompt",
  -- Smart tab bar [distraction-free mode]
  hide_tab_bar_if_only_one_tab = true,

  colors = {
    background = "#0d0d0d",
    foreground = "#98c379",
    cursor_bg = "#48e566"
  },
  window_background_opacity = 0.8,
  window_decorations = "NONE | RESIZE",

  window_padding = {
    left = 0, right = 0,
    top = 0, bottom = 0,
  },

  -- Font configuration
  -- https://wezfurlong.org/wezterm/config/fonts.html
  font = wezterm.font_with_fallback({
    {
       family="Hack Nerd Font",
       weight="Medium",
       harfbuzz_features={"calt=0", "clig=0", "liga=0"}
    },
  }),
  font_size = 13.3,

  -- Cursor style
  default_cursor_style = 'BlinkingBar',

  -- Enable CSI u mode
  -- https://wezfurlong.org/wezterm/config/lua/config/enable_csi_u_key_encoding.html
  enable_csi_u_key_encoding = true
}