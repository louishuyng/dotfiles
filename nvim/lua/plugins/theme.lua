return {
  {
    'louishuyng/fleet-theme-nvim',
    config = function()
      vim.cmd("colorscheme fleet")

      vim.cmd([[
        hi Normal guibg=#0F0F0F
        hi NormalNC guibg=#0F0F0F
        hi SignColumn guibg=#0F0F0F
        hi VertSplit guibg=#0F0F0F

        hi NvimTreeNormal guibg=#1C1C1C
        hi NvimTreeNormalNC guibg=#1C1C1C
      ]])
    end
  }
}
