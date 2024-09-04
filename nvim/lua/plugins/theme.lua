return {
  { "daschw/leaf.nvim" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        background = {
          dark = "frappe",
          light = "latte",
        },
      })
    end,
  }
}
