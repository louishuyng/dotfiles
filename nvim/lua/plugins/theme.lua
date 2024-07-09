return {
  { "sainnhe/edge" },
  { "luisiacc/gruvbox-baby" },
  { "Yazeed1s/minimal.nvim" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        background = {
          dark = "mocha",
          light = "latte",
        },
        transparent_background = true,
        highlight_overrides = {
          all = function(colors)
            return {
              WinSeparator = { fg = "#141417" }
            }
          end,
        },
      })
    end,
  }
}
