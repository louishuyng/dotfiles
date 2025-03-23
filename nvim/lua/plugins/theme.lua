return {
  {
    "EdenEast/nightfox.nvim",
    config = function()
      local Shade = require("nightfox.lib.shade")

      require("nightfox").setup({
        palettes = {
          duskfox = {
            black   = Shade.new("#393b44", 0.15, -0.15),
            red     = Shade.new("#c94f6d", 0.15, -0.15),
            green   = Shade.new("#81b29a", 0.10, -0.15),
            yellow  = Shade.new("#dbc074", 0.15, -0.15),
            blue    = Shade.new("#719cd6", 0.15, -0.15),
            magenta = Shade.new("#9d79d6", 0.30, -0.15),
            cyan    = Shade.new("#63cdcf", 0.15, -0.15),
            white   = Shade.new("#dfdfe0", 0.15, -0.15),
            orange  = Shade.new("#f4a261", 0.15, -0.15),
            pink    = Shade.new("#d67ad2", 0.15, -0.15),

            comment = "#738091",
          },
        },
      })
    end
  },
  {
    'NLKNguyen/papercolor-theme',
    event = "VeryLazy",
    priority = 1000,
    config = function()
      -- Blank to address startup error
    end,
    init = function()
      vim.cmd [[
        source $VIMRUNTIME/colors/vim.lua
      ]]
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'PaperColor'
    end,
  },
}
