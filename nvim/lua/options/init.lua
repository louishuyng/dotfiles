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

-- UNDOFILE
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')

-- NUMBERS
vim.cmd([[
  set number relativenumber
]])

-- FILLCHARS
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋'
}

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

-- FOLD
opt.foldmethod = 'indent'
opt.foldnestmax = 5
vim.o.foldlevel = 99
vim.o.foldlevelstart = -1

-- COLORCOLUMN
vim.cmd([[
  autocmd FileType * setlocal colorcolumn=120
  autocmd FileType alpha setlocal colorcolumn=""
]])

-- SPELL
vim.api.nvim_command("set spell")

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
vim.cmd('abbrev rubocopo rubocop:enable ')

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

-- plantuml
vim.cmd [[
au FileType plantuml let g:plantuml_previewer#plantuml_jar_path = get(
    \  matchlist(system('cat `which plantuml` | grep plantuml.jar'), '\v.*\s[''"]?(\S+plantuml\.jar).*'),
    \  1,
    \  0
    \)
  ]]

-- Draw Performance
vim.cmd([[
    set ttyfast
  set synmaxcol=128
  syntax sync minlines=256
  let g:sneak#label = 1
]])

-- Draft Buff Mappings Table
vim.g.draft_buff_languages = {'Http', 'Ruby', 'Javascript', 'Golang'}

-- Theme
vim.g.main_theme = 'linux'
