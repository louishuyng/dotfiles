local wezterm = require("wezterm")

local Theme = {}

function Theme.get_colors(config)
  wezterm.GLOBAL.is_dark = wezterm.gui.get_appearance():find("Dark")

  local palettes = {
    light = {
      rosewater = "#d73a49",
      flamingo = "#d73a49",
      red = "#d73a49",
      maroon = "#d73a49",
      pink = "#bf3989",
      mauve = "#6f42c1",
      peach = "#e36209",
      yellow = "#9a6700",
      green = "#22863a",
      teal = "#1b7c83",
      sky = "#1b7c83",
      sapphire = "#1b7c83",
      blue = "#005cc5",
      lavender = "#005cc5",
      text = "#24292e",
      subtext1 = "#24292f",
      subtext0 = "#32383f",
      overlay2 = "#424a53",
      overlay1 = "#57606a",
      overlay0 = "#6e7781",
      surface2 = "#8c8c8c",
      surface1 = "#d1d1d1",
      surface0 = "#e6e6e6",
      base = "#FFFFFF",
      mantle = "#f2f2f2",
      crust = "#ebebeb"
    },
    dark = {
      rosewater = "#f97583",
      flamingo = "#f97583",
      red = "#f97583",
      maroon = "#f97583",
      pink = "#f778ba",
      mauve = "#b392f0",
      peach = "#ffab70",
      yellow = "#d29922",
      green = "#85e89d",
      teal = "#76e3ea",
      sky = "#76e3ea",
      sapphire = "#76e3ea",
      blue = "#79b8ff",
      lavender = "#79b8ff",
      text = "#e1e4e8",
      subtext1 = "#f4f4f4",
      subtext0 = "#f0f6fc",
      overlay2 = "#c9d1d9",
      overlay1 = "#b1bac4",
      overlay0 = "#8b949e",
      surface2 = "#6e7681",
      surface1 = "#484f58",
      surface0 = "#262b33",
      base = "#0F0F0F",
      mantle = "#0a0d12",
      crust = "#000000"
    }
  }

  return wezterm.GLOBAL.is_dark and palettes.dark or palettes.light
end

function Theme.setup(config)
  local colors = Theme.get_colors()

  config.colors = {
    split = colors.surface0,
    foreground = colors.text,
    background = colors.base,
    cursor_border = colors.overlay2,
    cursor_fg = colors.base,
    selection_bg = colors.surface2,
    visual_bell = colors.surface0,
    indexed = {[16] = colors.peach, [17] = colors.rosewater},
    scrollbar_thumb = colors.surface2,
    compose_cursor = colors.flamingo,
    ansi = {
      colors.surface0, colors.red, colors.green, colors.yellow, colors.blue,
      colors.mauve, colors.teal, colors.subtext1
    },
    brights = {
      colors.surface2, colors.red, colors.green, colors.yellow, colors.blue,
      colors.mauve, colors.teal, colors.subtext0
    }
  }

  if wezterm.GLOBAL.is_dark == nil then
    config.colors.cursor_bg = colors.subtext0
    config.colors.tab_bar = {
      background = colors.mantle,
      active_tab = {
        bg_color = "none",
        fg_color = colors.subtext1,
        intensity = "Bold",
        underline = "None",
        italic = false,
        strikethrough = false
      },
      inactive_tab = {bg_color = colors.mantle, fg_color = colors.surface2},
      inactive_tab_hover = {bg_color = colors.base, fg_color = colors.subtext0},
      new_tab = {bg_color = colors.mantle, fg_color = colors.surface2},
      new_tab_hover = {bg_color = colors.base, fg_color = colors.surface2}
    }
  end
end

return Theme
