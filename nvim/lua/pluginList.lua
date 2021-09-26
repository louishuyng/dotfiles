local present, _ = pcall(require, "packerInit")
local packer

if present then
    packer = require "packer"
else
    return false
end

local use = packer.use

return packer.startup{
    function()
        use {
            "wbthomason/packer.nvim",
            event = "VimEnter"
        }

        -----------------------------------------------------------------
        -- MAIN PLUGS

        use 'pacokwon/onedarkhc.vim'

        use 'nvim-lua/popup.nvim'
        use {
            'ThePrimeagen/harpoon',
            opt = true,
            event = { 'VimEnter' },
            setup = require('plugins.harpoon').setup,
            config = require('plugins.harpoon').config,
        }

        use {
            "kyazdani42/nvim-web-devicons",
            config = function()
               require "plugins.icons"
            end,
         }

        use {
          'dense-analysis/ale',
          config = function()
            require "cores.ale"
          end
        }

        use {
            "norcalli/nvim-colorizer.lua",
            event = "BufRead",
            config = function()
                require("plugins.others").colorizer()
            end
        }

        use {
            "akinsho/nvim-bufferline.lua",
            config = function()
                require "cores.bufferline"
            end
        }

        use {
           'glepnir/galaxyline.nvim',
           config = function()
              require "cores.statusline"
           end,
        }

        -- language related plugins
        use {
            "nvim-treesitter/nvim-treesitter",
            event = "BufRead",
            config = function()
                require "cores.treesitter"
            end
        }

       -- configuration for language servers
        use {
          "neovim/nvim-lspconfig",
          config = function()
            require "lsp"
          end,
        }

        -- linter and formatter
        use {
          "jose-elias-alvarez/null-ls.nvim",
          requires = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
          },
          config = function()
            require "plugins/null"
          end,
        }

        use {
          "folke/trouble.nvim",
          requires = "kyazdani42/nvim-web-devicons",
          config = function()
            require "plugins.trouble"
          end
        }
        
        -- luasnips + cmp
        use {
            "rafamadriz/friendly-snippets",
            event = "InsertEnter",
        }

        use {
            "hrsh7th/nvim-cmp",
            after = "friendly-snippets",
            config = function()
	 	require "cores.cmp"
	    end
        }

        use {
            "L3MON4D3/LuaSnip",
            wants = "friendly-snippets",
            after = "nvim-cmp",
            config = function()
                require("plugins.others").luasnip()
	    end
        }

        use {
            "saadparwaiz1/cmp_luasnip",
            after = "LuaSnip",
        }

        use {
           "hrsh7th/cmp-nvim-lua",
            after = "cmp_luasnip",
        }

        use {
            "hrsh7th/cmp-nvim-lsp",
            after = "cmp-nvim-lua",
        }

        use {
            "hrsh7th/cmp-buffer",
            after = "cmp-nvim-lsp",
        }

        use {
            "windwp/nvim-autopairs",
            after="nvim-cmp",
            config = function()
                require("nvim-autopairs").setup()
                require("nvim-autopairs.completion.cmp").setup({
                  map_cr = true, --  map <CR> on insert mode
                  map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
                  auto_select = true, -- automatically select the first item
                  insert = false, -- use insert confirm behavior instead of replace
                  map_char = { -- modifies the function or method delimiter by filetypes
                    all = '(',
                    tex = '{'
                  }
                })
            end
        }

        -- file managing , picker etc
        use {
            "kyazdani42/nvim-tree.lua",
            cmd = "NvimTreeToggle",
            config = function()
                require "cores.nvimtree"
            end
        }

        use {
            "nvim-telescope/telescope.nvim",
            requires = { {"nvim-lua/plenary.nvim"} },
            cmd = "Telescope",
            config = function()
                require("cores.telescope").config()
                require('telescope').load_extension('projects')
            end
        }

        use {
          "ahmedkhalf/project.nvim",
          config = function()
            require("plugins.projects_nvim")
          end
        }

        use {
            "terrortylor/nvim-comment",
            cmd = "CommentToggle",
            config = function()
                require("plugins.others").comment()
            end
        }

        use {"tweekmonster/startuptime.vim", cmd = "StartupTime"}

        -- load autosave only if its globally enabled
        use {
            "Pocco81/AutoSave.nvim",
            config = function()
                require "plugins.autosave"
            end,
            cond = function()
                return vim.g.auto_save == true
            end
        }

        use {
            "Pocco81/TrueZen.nvim",
            cmd = {"TZAtaraxis", "TZMinimalist", "TZFocus"},
            config = function()
                require "plugins.zenmode"
            end
        }

        use 'airblade/vim-gitgutter'

        use 'tveskag/nvim-blame-line'

        use {
            "tpope/vim-fugitive",
            cmd = {
                "Git",
                "Gstatus",
                "Gwrite",
                "Gcommit",
                "Gpush",
                "Gpull",
                "Git blame",
                "Gvdiff",
                "GBrowse",
            }
        }

        -- TERM
        use "voldikss/vim-floaterm"

        -----------------------------------------------------------------
        -- PROGRAMING LANGUAGE SUPPORT

        -- ROR
        use 'thoughtbot/vim-rspec'

        -----------------------------------------------------------------
        -- OTHERS PLUGS

        use 'kdheepak/lazygit.nvim'

        use {
            "andymass/vim-matchup",
            event = "CursorMoved"
        }

        -- Show match number for incsearch
        use 'osyo-manga/vim-anzu'

        -- Clear highlight search automatically for you
        use 'romainl/vim-cool'

        -- Show current search term in different color
        use 'PeterRincker/vim-searchlight'

        -- Swap Argument
        use 'machakann/vim-swap'

        -- Handy unix command inside Vim (Rename, Move etc.)
        use 'tpope/vim-eunuch'

        -- Show undo history visually
        use 'simnalamburt/vim-mundo'

        -- Super fast movement with vim-sneak
        use 'justinmk/vim-sneak'

        -- Move lines up/down/left/right
        use 'matze/vim-move'

        -- Replace all text with Far
        use 'brooth/far.vim'

        -- Multiple Cursor
        use 'terryma/vim-multiple-cursors'

        -- Support surround
        use 'tpope/vim-surround'

        -- Markdown Preview
        use {
            'iamcco/markdown-preview.nvim',
            run = function() vim.fn['mkdp#util#install']() end,
            ft = {'markdown'}
        }

        -- Dashboard vim
        use 'glepnir/dashboard-nvim'

        -- Prettier
        use 'prettier/vim-prettier'

        -- Vim wordmotion
        use 'chaoren/vim-wordmotion'

        -- Rest NVim
        use {
          'NTBBloodbath/rest.nvim',
          requires = { 'nvim-lua/plenary.nvim' },
          config = function()
            require("rest-nvim").setup({
              -- Open request results in a horizontal split
              result_split_horizontal = false,
              -- Skip SSL verification, useful for unknown certificates
              skip_ssl_verification = false,
            })
          end
        }

        -- Narrow Code Space
        use 'chrisbra/NrrwRgn'

        -- AutoTag
        use {
          'windwp/nvim-ts-autotag',
          after = "nvim-treesitter",
        }

        -- Range Highlight
        use 'winston0410/cmd-parser.nvim'
        use 'winston0410/range-highlight.nvim'
    end,
    config = {
      display = {
        open_fn = function()
          return require("packer.util").float({border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}})
        end,
        working_sym = "",
        error_sym = "",
        done_sym = "",
        moved_sym = ""
      }
    }
}
