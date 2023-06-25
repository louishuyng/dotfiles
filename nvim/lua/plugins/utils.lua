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
  }, {'numToStr/Comment.nvim'}, {'tpope/vim-eunuch'}, {'phaazon/hop.nvim'},
  {'mg979/vim-visual-multi'}, {'tpope/vim-surround'}, {'chrisbra/NrrwRgn'}, {
    "andymass/vim-matchup",
    init = function() vim.g.matchup_matchparen_offscreen = {method = "popup"} end
  }, {'preservim/vimux'}, {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end
  }, {"folke/zen-mode.nvim"},
  {'narutoxy/silicon.lua', config = function() require('silicon').setup({}) end},
  {'tyru/open-browser.vim'}, {'windwp/nvim-spectre'}, {
    'norcalli/nvim-colorizer.lua',
    config = function() require'colorizer'.setup() end
  }, {
    'Wansmer/sibling-swap.nvim',
    dependencies = {'nvim-treesitter'},
    config = function()
      require('sibling-swap').setup({ --[[ your config ]] })
    end
  }, {'chentoast/marks.nvim', config = function() require'marks'.setup() end},
  {"rest-nvim/rest.nvim"},
  {'loishy/draft-buff', dependencies = {'MunifTanjim/nui.nvim'}},
  {'mbbill/undotree'}, {'famiu/nvim-reload'}, {'AndrewRadev/splitjoin.vim'}, {
    'glacambre/firenvim',
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    cond = not not vim.g.started_by_firenvim,
    build = function()
      require("lazy").load({plugins = "firenvim", wait = true})
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      vim.g.firenvim_config = {
        -- config values, like in my case:
        localSettings = {[".*"] = {takeover = "never"}}
      }
    end
  }
}
