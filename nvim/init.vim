"" ==================================================== Initialize
let mapleader=','
let g:python3_host_prog = '/usr/bin/python3'

" ==================================================== Plug-in
call plug#begin(expand('~/.config/nvim/plugged'))

""""""""""""""""""""""""""THEME""""""""""""""""""""""""""
Plug 'dense-analysis/ale'
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
Plug 'akinsho/nvim-bufferline.lua'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'norcalli/nvim-base16.lua'

""""""""""""""""""""""""""SOURCE CONTROL""""""""""""""""""""""""""
Plug 'jistr/vim-nerdtree-tabs'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'tpope/vim-fugitive'
"Fugitive Configuration
if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'lewis6991/gitsigns.nvim'
Plug 'brooth/far.vim'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'branch': 'release/0.x'
  \ }

""""""""""""""""""""""""""FILE SYSTEM""""""""""""""""""""""""""
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kevinhwang91/rnvimr'

""""""""""""""""""""""""""MOVEMENT""""""""""""""""""""""""""
Plug 'terryma/vim-multiple-cursors'

""""""""""""""""""""""""""LS-SERVER""""""""""""""""""""""""""
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'kabouzeid/nvim-lspinstall'

""""""""""""""""""""""""""RUBY""""""""""""""""""""""""""
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'
Plug 'thoughtbot/vim-rspec'

""""""""""""""""""""""""""TOOLS""""""""""""""""""""""""""
Plug 'Pocco81/TrueZen.nvim' "Focus Tool
Plug 'windwp/nvim-autopairs'
Plug 'wincent/scalpel' "Replace Text in Buffer
Plug 'tpope/vim-surround'
Plug 'kamykn/spelunker.vim' "Check Spell
Plug 'benmills/vimux' "Vi + Tmux
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'preservim/nerdcommenter' "Comment Support
Plug 'norcalli/nvim-colorizer.lua' "Colorizer text
Plug 'hrsh7th/vim-vsnip' "Snippets
Plug 'rafamadriz/friendly-snippets' "Collection Snippets

call plug#end()

" ==================================================== Plug-in Configuration
source ~/.config/nvim/config/ale.vim
source ~/.config/nvim/config/buffer.vim
source ~/.config/nvim/config/lsp.vim
source ~/.config/nvim/config/git.vim
source ~/.config/nvim/config/mappingkey.vim
source ~/.config/nvim/config/nerdtree.vim
source ~/.config/nvim/config/rails.vim
source ~/.config/nvim/config/scalpel.vim
source ~/.config/nvim/config/spelunker.vim
source ~/.config/nvim/config/tmux.vim
source ~/.config/nvim/config/rnvimr.vim
source ~/.config/nvim/config/telescope.vim
source ~/.config/nvim/config/truezen.vim
source ~/.config/nvim/config/wildmenu.vim
source ~/.config/nvim/config/folds.vim

lua require 'lsp-nvim'
lua require 'statusline'
lua require 'tabline'
lua require 'file-icons'
lua require 'treesitter-nvim'
lua require 'telescope-nvim'
lua require 'theme'
lua require 'gitsigns-nvim'
lua require 'ident-blankline-nvim'
lua require 'compe-completion-nvim'
lua require 'autopairs-nvim'
lua require 'misc-utils'
lua require 'colorizer-nvim'
