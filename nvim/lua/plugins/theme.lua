return {
  'catppuccin/nvim',
  config = function()
    require("catppuccin").setup({
      no_italic = true,
      background = {light = "latte", dark = "mocha"},
      color_overrides = {
        latte = {
          rosewater = "#c14a4a",
          flamingo = "#c14a4a",
          red = "#c14a4a",
          maroon = "#c14a4a",
          pink = "#945e80",
          mauve = "#945e80",
          peach = "#c35e0a",
          yellow = "#b47109",
          green = "#6c782e",
          teal = "#4c7a5d",
          sky = "#4c7a5d",
          sapphire = "#4c7a5d",
          blue = "#45707a",
          lavender = "#45707a",
          text = "#654735",
          subtext1 = "#73503c",
          subtext0 = "#805942",
          overlay2 = "#8c6249",
          overlay1 = "#8c856d",
          overlay0 = "#a69d81",
          surface2 = "#bfb695",
          surface1 = "#d1c7a3",
          surface0 = "#e3dec3",
          base = "#f9f5d7",
          mantle = "#f0ebce",
          crust = "#e8e3c8"
        },
        mocha = {
          rosewater = "#ffc0b9",
          flamingo = "#f5aba3",
          pink = "#f592d6",
          mauve = "#c0afff",
          red = "#ea746c",
          maroon = "#ff8595",
          peach = "#fa9a6d",
          yellow = "#ffe081",
          green = "#99d783",
          teal = "#47deb4",
          sky = "#00d5ed",
          sapphire = "#00dfce",
          blue = "#00baee",
          lavender = "#abbff3",
          text = "#cccccc",
          subtext1 = "#bbbbbb",
          subtext0 = "#aaaaaa",
          overlay2 = "#999999",
          overlay1 = "#888888",
          overlay0 = "#777777",
          surface2 = "#666666",
          surface1 = "#555555",
          surface0 = "#444444",
          base = "#202020",
          mantle = "#222222",
          crust = "#333333"
        }
      }
    })
  end
}
