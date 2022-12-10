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

-- CENTER CURSOR
opt.scrolloff = 999
opt.sidescrolloff = 999

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

-- LIST
vim.opt.list = true
vim.opt.listchars:append("eol:↲")
vim.opt.listchars:append("tab:» ")
vim.opt.listchars:append("trail:·")
vim.opt.listchars:append("extends:<")
vim.opt.listchars:append("precedes:>")
vim.opt.listchars:append("conceal:┊")

-- Fillchars
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋'
}

-- FOLD
opt.foldmethod = 'indent'
opt.foldnestmax = 5
vim.o.foldlevel = 99
vim.o.foldlevelstart = -1

-- SPELL
vim.api.nvim_command("set spell")

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

-- Org mode support
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'

-- Abbreviations
-- === General
vim.cmd('abbrev mgmail huynguyennbk@gmail.com')
vim.cmd('abbrev mname Louis Nguyen')
vim.cmd('abbrev lorem Lorem ipsum dolor sit amet, consectetur adipiscing elit')
-- === Ruby
vim.cmd('abbrev rubocopd rubocop:disable ')
vim.cmd('abbrev rubocopo rubocop:disable ')

-- LSP
vim.g.auto_format = true

-- GIT
vim.opt.diffopt = {
  "internal", "filler", "closeoff", "hiddenoff", "algorithm:minimal", "vertical"
}

-- Grep
vim.cmd('set grepprg=rg\\ --vimgrep\\ --smart-case\\ --follow')

-- Winbar
-- vim.api.nvim_command("set winbar=%m\\ %f")

-- hide tabline and statusline on startup screen
vim.cmd [[
augroup alpha_tabline
  au!
  au FileType alpha set showtabline=0 laststatus=0 noruler | au BufUnload <buffer> set showtabline=2 ruler laststatus=3
augroup END
]]
