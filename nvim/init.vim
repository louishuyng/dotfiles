"" ==================================================== Initialize
let mapleader=','

" ==================================================== Plug-in
call plug#begin(expand('~/.config/nvim/plugged'))

""""""""""""""""""""""""""THEME""""""""""""""""""""""""""
Plug 'sainnhe/edge'

""""""""""""""""""""""""""SOURCE CONTROL""""""""""""""""""""""""""
Plug 'airblade/vim-gitgutter'
Plug 'brooth/far.vim'
Plug 'dense-analysis/ale'
Plug 'kdheepak/lazygit.nvim'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'branch': 'release/0.x'
  \ }

""""""""""""""""""""""""""file system""""""""""""""""""""""""""
Plug 'kevinhwang91/rnvimr'

""""""""""""""""""""""""""MOVEMENT""""""""""""""""""""""""""
Plug 'terryma/vim-multiple-cursors'

""""""""""""""""""""""""""RUBY""""""""""""""""""""""""""
Plug 'thoughtbot/vim-rspec'

""""""""""""""""""""""""""TOOLS""""""""""""""""""""""""""
Plug 'benmills/vimux' "Vi + Tmux
Plug 'kamykn/spelunker.vim' "Check Spell
Plug 'wincent/scalpel' "Replace Text in Buffer
Plug 'tpope/vim-surround'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  } "Markdown Preview
Plug 'glepnir/dashboard-nvim'

call plug#end()

lua require 'init'

" ==================================================== Plug-in Configuration
source ~/.config/nvim/config/anzu.vim
source ~/.config/nvim/config/abbreviations.vim
source ~/.config/nvim/config/ale.vim
source ~/.config/nvim/config/buffer.vim
source ~/.config/nvim/config/dashboard.vim
source ~/.config/nvim/config/far.vim
source ~/.config/nvim/config/folds.vim
source ~/.config/nvim/config/git.vim
source ~/.config/nvim/config/lsp.vim
source ~/.config/nvim/config/lspsaga.vim
source ~/.config/nvim/config/mappingkey.vim
source ~/.config/nvim/config/options.vim
source ~/.config/nvim/config/rails.vim
source ~/.config/nvim/config/rnvimr.vim
source ~/.config/nvim/config/scalpel.vim
source ~/.config/nvim/config/spelunker.vim
source ~/.config/nvim/config/telescope.vim
source ~/.config/nvim/config/tmux.vim
source ~/.config/nvim/config/tree.vim
source ~/.config/nvim/config/wildmenu.vim
