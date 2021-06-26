"" ==================================================== Initialize
let g:python3_host_prog = '/usr/bin/python3'
let mapleader=','

set termguicolors

" ==================================================== Plug-in
call plug#begin(expand('~/.config/nvim/plugged'))

""""""""""""""""""""""""""THEME""""""""""""""""""""""""""
Plug 'akinsho/nvim-bufferline.lua'
Plug 'dense-analysis/ale'
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'ryanoasis/vim-devicons'
Plug 'glepnir/dashboard-nvim'
Plug 'sainnhe/edge'

""""""""""""""""""""""""""SOURCE CONTROL""""""""""""""""""""""""""
Plug 'brooth/far.vim'
Plug 'kdheepak/lazygit.nvim'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'airblade/vim-gitgutter'
Plug 'tveskag/nvim-blame-line'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'branch': 'release/0.x',
  \ }
Plug 'tpope/vim-fugitive'
if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif

""""""""""""""""""""""""""FILE SYSTEM""""""""""""""""""""""""""
Plug 'kevinhwang91/rnvimr'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'

""""""""""""""""""""""""""MOVEMENT""""""""""""""""""""""""""
Plug 'terryma/vim-multiple-cursors'

""""""""""""""""""""""""""LS-SERVER""""""""""""""""""""""""""
Plug 'glepnir/lspsaga.nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'

""""""""""""""""""""""""""RUBY""""""""""""""""""""""""""
Plug 'thoughtbot/vim-rspec'
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'

""""""""""""""""""""""""""TOOLS""""""""""""""""""""""""""
Plug '907th/vim-auto-save'
Plug 'Pocco81/TrueZen.nvim' "Focus Tool
Plug 'benmills/vimux' "Vi + Tmux
Plug 'hrsh7th/vim-vsnip' "Snippets
Plug 'kamykn/spelunker.vim' "Check Spell
Plug 'norcalli/nvim-colorizer.lua' "Colorizer text
Plug 'preservim/nerdcommenter' "Comment Support
Plug 'rafamadriz/friendly-snippets' "Collection Snippets
Plug 'tpope/vim-surround'
Plug 'wincent/scalpel' "Replace Text in Buffer
Plug 'windwp/nvim-autopairs'

call plug#end()

" ==================================================== Plug-in Configuration
source ~/.config/nvim/config/abbreviations.vim
source ~/.config/nvim/config/ale.vim
source ~/.config/nvim/config/buffer.vim
source ~/.config/nvim/config/dashboard.vim
source ~/.config/nvim/config/folds.vim
source ~/.config/nvim/config/git.vim
source ~/.config/nvim/config/lsp.vim
source ~/.config/nvim/config/lspsaga.vim
source ~/.config/nvim/config/mappingkey.vim
source ~/.config/nvim/config/rails.vim
source ~/.config/nvim/config/rnvimr.vim
source ~/.config/nvim/config/scalpel.vim
source ~/.config/nvim/config/session.vim
source ~/.config/nvim/config/spelunker.vim
source ~/.config/nvim/config/telescope.vim
source ~/.config/nvim/config/theme.vim
source ~/.config/nvim/config/tmux.vim
source ~/.config/nvim/config/tree.vim
source ~/.config/nvim/config/truezen.vim
source ~/.config/nvim/config/wildmenu.vim

lua require 'autopairs-nvim'
lua require 'colorizer-nvim'
lua require 'compe-completion-nvim'
lua require 'dashboard-nvim'
lua require 'file-icons'
lua require 'lsp-nvim'
lua require 'lsp-saga-nvim'
lua require 'misc-utils'
lua require 'statusline'
lua require 'tabline'
lua require 'telescope-nvim'
lua require 'theme'
lua require 'tree-nvim'
lua require 'treesitter-nvim'
