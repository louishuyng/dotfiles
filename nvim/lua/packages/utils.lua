return {
  {
    "windwp/nvim-autopairs",
    dependencies = {"nvim-cmp"},
    config = function()
      local present1, autopairs = pcall(require, "nvim-autopairs")
      local present2, cmp_autopairs = pcall(require,
                                            "nvim-autopairs.completion.cmp")

      if not (present1 or present2) then return end

      autopairs.setup()

      local cmp = require "cmp"
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  }, {'numToStr/Comment.nvim'}, {'tpope/vim-eunuch'}, {'justinmk/vim-sneak'},
  {'mg979/vim-visual-multi'}, {'tpope/vim-surround'}, {'chrisbra/NrrwRgn'}, {
    "andymass/vim-matchup",
    init = function() vim.g.matchup_matchparen_offscreen = {method = "popup"} end
  }, {'preservim/vimux'}, {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end
  }, {"folke/zen-mode.nvim"},
  {'krivahtoo/silicon.nvim', build = './install.sh'}, {'aklt/plantuml-syntax'},
  {'weirongxu/plantuml-previewer.vim'}, {'tyru/open-browser.vim'}
}
