return {
  {
    'louishuyng/fleet-theme-nvim',
    config = function()
      vim.cmd("colorscheme fleet")

      vim.cmd([[
        hi Normal guibg=#000000
        hi NormalNC guibg=#000000
        hi SignColumn guibg=#000000
      ]])
    end
  }
}
