"" ==================================================== Init Configure

let mapleader=','
let g:fzf_preview_grep_cmd = 'rg --line-number --no-heading -w'
let g:python3_host_prog = '/usr/bin/python3'

" ==================================================== Plugin
call plug#begin(expand('~/.config/nvim/plugged'))

""""""""""""""""""""""""""THEME""""""""""""""""""""""""""
Plug 'w0rp/ale'
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
Plug 'ayu-theme/ayu-vim'
Plug 'itchyny/lightline.vim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'sainnhe/edge'

""""""""""""""""""""""""""SOURCE CONTROL""""""""""""""""""""""""""
Plug 'jistr/vim-nerdtree-tabs'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
"Config Fugitive
if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-rhubarb' " required by fugitive to :Gbrowse

""""""""""""""""""""""""""FILE SYSTEM""""""""""""""""""""""""""
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'yuki-ycino/fzf-preview.vim'
Plug 'kevinhwang91/rnvimr'

""""""""""""""""""""""""""MOVEMENT""""""""""""""""""""""""""
Plug 'joequery/stupid-easymotion'
Plug 'easymotion/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'

""""""""""""""""""""""""""LS-SERVER""""""""""""""""""""""""""
Plug 'neoclide/coc.nvim', {'branch': 'release'}

""""""""""""""""""""""""""PYTHON""""""""""""""""""""""""""
Plug 'vim-scripts/indentpython.vim'
Plug 'nvie/vim-flake8'
let python_highlight_all=1

""""""""""""""""""""""""""OTHERS""""""""""""""""""""""""""
Plug 'cohama/lexima.vim'
Plug 'wincent/scalpel'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'kamykn/spelunker.vim'
Plug 'majutsushi/tagbar'
Plug 'benmills/vimux' "Vi + Tmux
Plug 'Yggdroot/indentLine'
Plug 'preservim/nerdcommenter'
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

call plug#end()

" ==================================================== Config Plugin
source ~/.config/nvim/config/ale.vim
source ~/.config/nvim/config/buffer.vim
source ~/.config/nvim/config/coc.vim
source ~/.config/nvim/config/fzf.vim
source ~/.config/nvim/config/git.vim
source ~/.config/nvim/config/mappingkey.vim
source ~/.config/nvim/config/nerdtree.vim
source ~/.config/nvim/config/ruby.vim
source ~/.config/nvim/config/scalpel.vim
source ~/.config/nvim/config/session.vim
source ~/.config/nvim/config/spelunker.vim
source ~/.config/nvim/config/tagbar.vim
source ~/.config/nvim/config/tmux.vim
source ~/.config/nvim/config/rnvimr.vim

luafile ~/.config/nvim/lua/plugins/galaxyline-config.lua

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

" ==================================================== General Config
filetype plugin indent on

set nocompatible              " be iMproved, required filetype off
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

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
" ==================================================== Mouse
set mouse=a

" ==================================================== Theme
set background=dark
set termguicolors
set t_Co=256

colorscheme koehler

let g:lightline = {
  \ 'colorscheme': 'ayu',
  \ }

if (has("termguicolors"))
  set termguicolors
  hi LineNr ctermbg=NONE guibg=NONE
  hi VertSplit guifg=#6A68FE guibg=#0000 gui=NONE cterm=NONE
  hi SignColumn guifg=#0000 guibg=#0000
endif

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
set nofoldenable        "dont fold by default

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
