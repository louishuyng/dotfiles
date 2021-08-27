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

        use 'dracula/vim'

        use {
            "kyazdani42/nvim-web-devicons",
            config = function()
               require "plugins.icons"
            end,
         }

        use {
          'dense-analysis/ale',
          config = function()
            require "plugins.ale"
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
                require "plugins.bufferline"
            end
        }

        use {
           'famiu/feline.nvim',
           config = function()
              require "plugins.statusline"
           end
        }

        -- language related plugins
        use {
            "nvim-treesitter/nvim-treesitter",
            event = "BufRead",
            config = function()
                require "plugins.treesitter"
            end
        }

        use {
            "kabouzeid/nvim-lspinstall",
            event = "BufEnter"
        }

        use {
            "neovim/nvim-lspconfig",
            after = "nvim-lspinstall",
            config = function()
                require "plugins.lspconfig"
            end
        }

        use {
            "glepnir/lspsaga.nvim",
            event = "BufRead",
            config = function()
                require "plugins.lspsaga"
            end
        }

        use {
            "onsails/lspkind-nvim",
            event = "BufEnter",
            config = function()
                require("plugins.others").lspkind()
            end
        }

        -- load compe in insert mode only
        use {
            "hrsh7th/nvim-compe",
            event = "InsertEnter",
            config = function()
                require("plugins.compe").config()
            end,
            wants = {"LuaSnip"},
            requires = {
                {
                    "L3MON4D3/LuaSnip",
                    wants = "friendly-snippets",
                    event = "InsertCharPre",
                    config = function()
                        require("plugins.compe").snippets()
                    end
                },
                {
                    "rafamadriz/friendly-snippets",
                    event = "InsertCharPre"
                }
            }
        }

        use 'hrsh7th/vim-vsnip'
        use 'hrsh7th/vim-vsnip-integ'

        use {
            "windwp/nvim-autopairs",
            after = "nvim-compe",
            config = function()
                require("nvim-autopairs").setup()
                require("nvim-autopairs.completion.compe").setup(
                    {
                        map_cr = true,
                        map_complete = true -- insert () func completion
                    }
                )
            end
        }

        -- file managing , picker etc
        use {
            "kyazdani42/nvim-tree.lua",
            cmd = "NvimTreeToggle",
            config = function()
                require "plugins.nvimtree"
            end
        }

        use {
            "nvim-telescope/telescope.nvim",
            requires = { {"nvim-lua/plenary.nvim"} },
            cmd = "Telescope",
            config = function()
                require("plugins.telescope").config()
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


        use {
            "lewis6991/gitsigns.nvim",
            requires = {
              "nvim-lua/plenary.nvim"
            },
            config = function()
              require 'plugins.gitsigns'
            end
        }

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
        -----------------------------------------------------------------
        -- PROGRAMING LANGUAGE SUPPORT

        -- ROR
        use 'thoughtbot/vim-rspec'

        -----------------------------------------------------------------
        -- OTHERS PLUGS

        use 'kdheepak/lazygit.nvim'

        use {
            "jdhao/better-escape.vim",
            event = 'InsertEnter'
        }

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

        -- Edit text area in browser using nvim
        use {'glacambre/firenvim', run = function() fn['firenvim#install'](1) end}

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

        -- ViTmux
        use 'preservim/vimux'

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
