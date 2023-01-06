return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git", "Gstatus", "Gcommit", "Gpush", "Gpull", "Gvdiff", "Gdiff",
      "Git blame", "Git mergetool"
    }
  }, {'lewis6991/gitsigns.nvim', dependencies = {'nvim-lua/plenary.nvim'}},
  {'akinsho/git-conflict.nvim'}, {'sindrets/diffview.nvim'}
}
