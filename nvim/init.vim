"" ==================================================== Initialize
let mapleader=','
let g:python3_host_prog = '/usr/bin/python3'
let g:netrw_keepdir= 0

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

""""""""""""""""""""""""""RUBY""""""""""""""""""""""""""
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'
Plug 'thoughtbot/vim-rspec'

""""""""""""""""""""""""""OTHERS""""""""""""""""""""""""""
Plug 'Pocco81/TrueZen.nvim' "Focus Tool
Plug 'tpope/vim-endwise'
Plug 'windwp/nvim-autopairs'
Plug 'wincent/scalpel'
Plug 'tpope/vim-surround'
Plug 'kamykn/spelunker.vim'
Plug 'benmills/vimux' "Vi + Tmux
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'preservim/nerdcommenter'

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
source ~/.config/nvim/config/session.vim
source ~/.config/nvim/config/spelunker.vim
source ~/.config/nvim/config/tagbar.vim
source ~/.config/nvim/config/tmux.vim
source ~/.config/nvim/config/rnvimr.vim
source ~/.config/nvim/config/telescope.vim
source ~/.config/nvim/config/truezen.vim

lua require 'lsp-nvim'
lua require 'statusline'
lua require 'tabline'
lua require 'treesitter-nvim'
lua require 'telescope-nvim'
lua require 'theme'
lua require 'gitsigns-nvim'
lua require 'ident-blankline-nvim'
lua require 'autopairs-nvim'
lua require 'compe-completion-nvim'
lua require 'file-icons'

"*****************************************************************************
"" Abbreviations
"*****************************************************************************
"" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

" ==================================================== General Configuration
filetype plugin indent on

set nocompatible              " be improved, required file type off
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set gcr=a:blinkon0              "Disable cursor blink
set guicursor=n:blinkon1        "Fix bug cursor of COC
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim
set encoding=utf-8
set lazyredraw
set ttimeout
set ttimeoutlen=2
set number relativenumber
set hidden
set cursorline
set visualbell
set spell

" ==================================================== Mouse
set mouse=a

" ==================================================== Theme
set background=dark
set t_Co=256
set termguicolors

" ==================================================== Turn Off Swap Files
set noswapfile
set nobackup
set nowritebackup
set nowb

" ==================================================== Indentation
set autoindent
set smartindent
set smarttab
set softtabstop=2
set tabstop=2
set expandtab ts=2 sw=2 ai
set textwidth=70

autocmd Filetype php setlocal ts=4 sw=4 sts=0 expandtab
autocmd Filetype kotlin setlocal ts=4 sw=4 sts=0 expandtab
autocmd Filetype java setlocal ts=4 sw=4 sts=0 expandtab
autocmd Filetype xml setlocal ts=4 sw=4 sts=0 expandtab
autocmd Filetype python setlocal ts=4 sw=4 sts=0 expandtab
autocmd FileType ruby set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2

autocmd BufWritePre * %s/\s\+$//e

" Auto indent pasted text
nnoremap p p=`]
nnoremap P P=`]

filetype plugin on
filetype indent on

set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ==================================================== Folds
set foldmethod=indent   "fold based on indent
set foldnestmax=5       "deepest fold is 5 levels
set nofoldenable        "don't fold by default

" ==================================================== Completion
set wildmenu
set wildmode=longest:full,full
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

" ==================================================== Scrolling
set scrolloff=3         "Start scrolling when we're 3 lines away from margins
set sidescrolloff=15
set sidescroll=1

" ==================================================== Search
set incsearch       " Find the next match as we type the search
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital
set hlsearch

" ==================================================== Clipboard
set clipboard=unnamed
