return {
  {
    'louishuyng/fleet-theme-nvim',
    config = function()
      vim.cmd("colorscheme fleet")

      vim.cmd([[
        hi NvimTreeNormal guibg=#0E1117
        hi NvimTreeNormalNC guibg=#0E1117
      ]])
    end
  }
}
