return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      color_overrides = {
        latte = {
          rosewater = "#fdf7e8",
          flamingo = "#cb4b16",
          pink = "#d33682",
          mauve = "#6c71c4",
          red = "#dc322f",
          maroon = "#c03260",
          peach = "#cb4b1f",
          yellow = "#b58900",
          green = "#859900",
          teal = "#2aa198",
          sky = "#2398d2",
          sapphire = "#0077b3",
          blue = "#268bd2",
          lavender = "#7b88d3",
          text = "#657b83",
          subtext1 = "#586e75",
          subtext0 = "#073642",
          overlay2 = "#002b36",
          overlay1 = "#839496",
          overlay0 = "#93a1a1",
          surface2 = "#eee8d5",
          surface1 = "#ebecef",
          surface0 = "#ccd0da",
          base = "#fdf6e3",
          mantle = "#f7f1dc",
          crust = "#f5ecd7",
        },
      },
      highlight_overrides = {
        latte = function(C)
          return {
            FlashLabel = { fg = C.base, bg = C.red, style = { "bold" } },
          }
        end,
      },
    },
  },
  -- { 'NLKNguyen/papercolor-theme' },
}
