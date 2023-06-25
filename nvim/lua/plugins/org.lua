return {
  {
    'akinsho/org-bullets.nvim',
    config = function() require('org-bullets').setup() end
  }, {
    'lukas-reineke/headlines.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true -- or `opts = {}`
  }, {'michaelb/sniprun', build = 'sh install.sh'}, {'nvim-orgmode/orgmode'}
}
