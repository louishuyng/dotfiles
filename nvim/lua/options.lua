local opt = vim.opt

opt.ruler = false
opt.hidden = true
opt.ignorecase = true
opt.autoread = true
opt.splitbelow = false
opt.splitright = true
opt.termguicolors = true
opt.cul = true
opt.mouse = "a"
opt.cmdheight = 1
opt.updatetime = 250 -- update interval for gitsigns
opt.timeoutlen = 1000
opt.ttimeoutlen = 0
opt.clipboard = "unnamedplus"
opt.fillchars = { eob = "x" }

-- CENTER CURSOR
opt.scrolloff = 999
opt.sidescrolloff = 999

-- CURSOR
opt.gcr='a:blinkon0'

-- SWAPFILE
vim.g.noswapfile = true
vim.g.nobackup = true
vim.g.nowritebackup = true
vim.g.nowb = true

-- NUMBERS
opt.number = true
opt.numberwidth = 2
opt.relativenumber = true

-- INDENLINE
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true

-- DISABLE BUILTIN VIM PLUGINS
vim.g.loaded_gzip = 0
vim.g.loaded_tar = 0
vim.g.loaded_tarPlugin = 0
vim.g.loaded_zipPlugin = 0
vim.g.loaded_2html_plugin = 0
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_matchit = 0
vim.g.loaded_matchparen = 0
vim.g.loaded_spec = 0

-- COLOR COLUMN
vim.api.nvim_command("set colorcolumn=80")

-- LIST
vim.api.nvim_command("set list")
vim.api.nvim_command("set list listchars=tab:▸\\ ,trail:·,precedes:←,extends:→,eol:↲,nbsp:␣")

-- FOLD
opt.foldmethod ='indent'
opt.foldnestmax = 5
vim.api.nvim_command("set nofoldenable")

-- MUNDO
vim.api.nvim_command("set undofile")
vim.api.nvim_command("set undodir=~/.vim/undo")

-- RUST
vim.g.rust_recommended_style = 0

-- Golang
vim.cmd [[au FileType go set noexpandtab]]
vim.cmd [[au FileType go set shiftwidth=2]]
vim.cmd [[au FileType go set softtabstop=2]]
vim.cmd [[au FileType go set tabstop=2]]
