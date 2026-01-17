vim.g.loaded_matchparen = 1

local opt = vim.opt

vim.g.default_dark_theme = 'night'
vim.g.default_light_theme = 'light'
vim.g.default_dark_catppuccin_theme = 'frappe'

vim.g.home_dir = '/Users/louishuyng'
vim.g.work_project_dir = vim.g.home_dir .. '/LX14/projects'
vim.g.work_repository_dir = vim.g.home_dir .. '/LX14/repository/github.com'

vim.g.auto_format = true

-- Mise Integration
vim.env.PATH = vim.env.HOME .. '/.asdf/shims:' .. vim.env.PATH

-- Ignore compiled files
opt.wildignore = '__pycache__'
opt.wildignore:append { '*.o', '*~', '*.pyc', '*pycache*' }
opt.wildignore:append { 'Cargo.lock', 'Cargo.Bazel.lock' }

opt.cursorline = true
opt.showmode = false
opt.showcmd = true
opt.cmdheight = 0 -- Height of the command bar
opt.incsearch = true -- Makes search act like search in modern browsers
opt.showmatch = true -- show matching brackets when text indicator is over them
opt.number = true -- But show the actual number for the line we're on
opt.ignorecase = true -- Ignore case when searching...
opt.smartcase = true -- ... unless there is a capital letter in the query
opt.hidden = true -- I like having buffers stay around
opt.splitright = true -- Prefer windows splitting to the right opt.splitbelow = false -- Prefer windows splitting to the top
opt.updatetime = 250 -- Make updates happen faster
opt.hlsearch = true -- I wouldn't use this without my DoNoHL function
opt.scrolloff = 10 -- Make it so there are always ten lines below my cursor
opt.list = true -- Show some invisible characters (tabs...)
-- Modern listchars for better visibility
opt.listchars = {
  tab = '→ ',
  trail = '·',
  nbsp = '␣',
  extends = '⟩',
  precedes = '⟨',
}
opt.laststatus = 3 -- Always display the status line
opt.relativenumber = true -- Relative line numbers

-- Tabs
opt.autoindent = true
opt.cindent = true
opt.wrap = true

opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true

opt.breakindent = true
opt.showbreak = string.rep(' ', 3) -- Make it so that long lines wrap smartly
opt.linebreak = true

-- Modern, elegant fillchars
opt.fillchars = {
  eob = ' ', -- end of buffer
  fold = ' ',
  foldopen = '▾',
  foldclose = '▸',
  foldsep = '│',
  diff = '╱',
  msgsep = '─',
  horiz = '─',
  horizup = '┴',
  horizdown = '┬',
  vert = '│',
  vertleft = '┤',
  vertright = '├',
  verthoriz = '┼',
}

opt.foldmethod = 'indent'
opt.foldenable = false
opt.foldlevel = 99

opt.belloff = 'all' -- Just turn the dang bell off

opt.inccommand = 'split'
opt.swapfile = false -- Living on the edge
opt.shada = { '!', "'1000", '<50', 's10', 'h' }

opt.mouse = 'a'

-- set joinspaces
opt.joinspaces = false -- Two spaces and grade school, we're done

-- Smooth cursor line and column
opt.cursorlineopt = 'both'

vim.opt.diffopt = {
  'internal',
  'filler',
  'closeoff',
  'hiddenoff',
  'algorithm:minimal',
}

vim.opt.undofile = true
vim.opt.signcolumn = 'yes'

-- SPELL
vim.opt.spell = true

-- UNDOFILE
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')

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

-- RUST
vim.g.rust_recommended_style = 1

-- Golang
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.tabstop = 2
    vim.wo.list = false
  end,
})

-- LSP
vim.g.auto_format = true

-- Grep
vim.opt.grepprg = 'rg --vimgrep --smart-case --follow'

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
-- vim.cmd([[
--   set ttyfast
--   set synmaxcol=500
--   syntax sync minlines=50
--
--   let $NVIM_TUI_ENABLE_TRUE_COLOR=1
-- ]])

-- File Info
vim.cmd([[
  set viminfo='100,n$HOME/.vim/files/info/viminfo
]])

-- UI
vim.cmd([[
  set laststatus=3
]])

-- AI
vim.g.copilot_enabled = true

-- cliboard
vim.cmd([[
  set clipboard+=unnamedplus
]])
