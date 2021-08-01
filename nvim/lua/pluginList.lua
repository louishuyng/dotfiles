local packer = require("packer")
local use = packer.use

packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float {border = "single"}
        end
    },
    git = {
        clone_timeout = 600 -- Timeout, in seconds, for git clones
    }
}

return packer.startup(
    function()
        use "wbthomason/packer.nvim"

        use {
            "norcalli/nvim-colorizer.lua",
            event = "BufRead",
            config = function()
                require("colorizer").setup()
                vim.cmd("ColorizerReloadAllBuffers")
            end
        }

        use "akinsho/nvim-bufferline.lua"

        use {
            "glepnir/galaxyline.nvim",
            config = function()
                require "plugins.statusline"
            end
        }

        -- language related plugins
        use {
            "nvim-treesitter/nvim-treesitter",
            event = "BufRead",
            config = function()
                require("plugins.treesitter").config()
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
                require("plugins.lspsaga").config()
            end
        }

        use {
            "onsails/lspkind-nvim",
            event = "BufEnter",
            config = function()
                require("lspkind").init()
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

        -- file managing , picker etc
        use {
            "kyazdani42/nvim-tree.lua",
            cmd = "NvimTreeToggle",
            config = function()
                require("plugins.nvimtree").config()
            end
        }

        use {
            "kyazdani42/nvim-web-devicons",
            config = function()
                require("plugins.icons").config()
            end
        }

        use {
            "nvim-telescope/telescope.nvim",
            requires = {
                {"nvim-lua/popup.nvim"},
                {"nvim-lua/plenary.nvim"}
            },
            cmd = "Telescope",
            config = function()
                require("plugins.telescope").config()
            end
        }

        -- misc plugins
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

        use {
            "terrortylor/nvim-comment",
            cmd = "CommentToggle",
            config = function()
                require("nvim_comment").setup()
            end
        }

        use {
            "glepnir/dashboard-nvim",
            cmd = {
                "Dashboard",
                "DashboardNewFile",
                "DashboardJumpMarks",
                "SessionLoad",
                "SessionSave"
            },
            setup = function()
                require("plugins.dashboard").config()
            end
        }

        use {"tweekmonster/startuptime.vim", cmd = "StartupTime"}

        -- load autosave only if its globally enabled
        use {
            "Pocco81/AutoSave.nvim",
            config = function()
                require("plugins.zenmode").autoSave()
            end,
            cond = function()
                return vim.g.auto_save == true
            end
        }

        use {
            "Pocco81/TrueZen.nvim",
            cmd = {"TZAtaraxis", "TZMinimalist", "TZFocus"},
            config = function()
                require("plugins.zenmode").config()
            end
        }

        --   use "alvan/vim-closetag" -- for html autoclosing tag

        use {
            "lukas-reineke/indent-blankline.nvim",
            event = "BufRead",
            setup = function()
                require("utils").blankline()
            end
        }

         use {
            "tpope/vim-fugitive",
            cmd = {
                "Git"
            }
        }
    end
)
