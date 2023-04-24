local linux = {
  white = "#abb2bf",
  black = "#282c34",
  pure_black = "#000000",
  bg = '#000000',
  fg = '#abb2bf',
  black2 = "#2b3b51",
  grey = "#5c6370",
  grey_fg = "#565c64",
  grey_fg2 = "#6f737b",
  red = "#b02626",
  black_red = "#be5046",
  green = "#60ff60",
  blue = "#40ffff",
  yellow = "#ffff60",
  purple = "#ff80ff",
  cyan = "#40ffff",
  orange = "#d19a66",
  winbar = "NONE",
  winbar_inactive = "NONE",
  statusline = "#000000",
  cursorline = "#323232"
}

local gruvbox = {
  name = "gruvbox",
  white = "#abb2bf",
  black = "#32302f",
  pure_black = "#000000",
  bg = '#1d2021',
  fg = "#ddc7a1",
  black2 = "#2b3b51",
  grey = "#5c6370",
  grey_fg = "#565c64",
  grey_fg2 = "#6f737b",
  red = "#ea6962",
  black_red = "#ea6962",
  green = "#a9b665",
  blue = "#7daea3",
  yellow = "#d8a657",
  purple = "#d3869b",
  cyan = "#89b482",
  orange = "#d8a657",
  winbar = "NONE",
  winbar_inactive = "NONE",
  statusline = "#282828",
  cursorline = "#323232"
}

local edge = {
  name = "edge",
  white = "#c5cdd9",
  black = "#3e4249",
  pure_black = "#000000",
  bg = '#000000',
  fg = "#c5cdd9",
  black2 = "#2b3b51",
  grey = "#5c6370",
  grey_fg = "#565c64",
  grey_fg2 = "#6f737b",
  red = "#ec7279",
  black_red = "#ec7279",
  green = "#a0c980",
  blue = "#6cb6eb",
  yellow = "#deb974",
  purple = "#d38aea",
  cyan = "#5dbbc1",
  orange = "#deb974",
  winbar = "NONE",
  winbar_inactive = "NONE",
  statusline = "#000000",
  cursorline = "#323232"
}

local catppuccin = {
  name = "catppuccin",
  white = "#BAC2DE",
  black = "#45475A",
  pure_black = "#000000",
  bg = '#1E1E2E',
  fg = '#CDD6F4',
  black2 = "#2b3b51",
  grey = "#5c6370",
  grey_fg = "#565c64",
  grey_fg2 = "#6f737b",
  red = "#F38BA8",
  black_red = "#F38BA8",
  green = "#A6E3A1",
  blue = "#89B4FA",
  yellow = "#F9E2AF",
  purple = "#F5C2E7",
  cyan = "#94E2D5",
  orange = "#F9E2AF",
  winbar = "NONE",
  winbar_inactive = "NONE",
  statusline = "#313343",
  cursorline = "#2A2B3B"
}

local dogrun = {
  name = "dogrun",
  white = "#BAC2DE",
  black = "#45475A",
  pure_black = "#000000",
  bg = '#222433',
  fg = '#CDD6F4',
  black2 = "#2b3b51",
  grey = "#5c6370",
  grey_fg = "#565c64",
  grey_fg2 = "#6f737b",
  red = "#CE747D",
  black_red = "#F38BA8",
  green = "#8ABC90",
  blue = "#689CC3",
  yellow = "#A8A386",
  purple = "#949BDF",
  cyan = "#85BFAA",
  orange = "#A78C84",
  winbar = "NONE",
  winbar_inactive = "NONE",
  statusline = "#313343",
  cursorline = "#2A2B3B"
}

local theme = {
  linux = linux,
  gruvbox = gruvbox,
  edge = edge,
  catppuccin = catppuccin,
  dogrun = dogrun
}

-- return theme for current theme
return theme[vim.g.main_theme] or linux
