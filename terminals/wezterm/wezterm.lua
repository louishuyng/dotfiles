-- WezTerm
-- https://wezfurlong.org/wezterm/
local wezterm = require 'wezterm'

return {
  window_close_confirmation = "NeverPrompt",
  -- Smart tab bar [distraction-free mode]
  hide_tab_bar_if_only_one_tab = true,
  color_scheme = 'Edge Dark (base16)',
  colors = {
    background = "#0D1117",
    foreground = "#98c379",
    cursor_bg = "#48e566"
  },
  window_decorations = "NONE | RESIZE",
  window_padding = {left = 0, right = 0, top = 0, bottom = 0},
  -- Font configuration
  -- https://wezfurlong.org/wezterm/config/fonts.html
  font_rules = {
    {
      font = wezterm.font_with_fallback {
        {family = 'nonicons'}, {family = 'JetBrainsMono Nerd Font Mono'}
      }
    }
  },
  font_size = 10.0,
  -- Cursor style
  default_cursor_style = 'BlinkingBar',
  -- Enable CSI u mode
  -- https://wezfurlong.org/wezterm/config/lua/config/enable_csi_u_key_encoding.html
  enable_csi_u_key_encoding = true,
  -- avoiding changing size when using external screen
  dpi = 192.0
}
