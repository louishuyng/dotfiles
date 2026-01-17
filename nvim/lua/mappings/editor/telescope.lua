local telescope = require('telescope')
local builtin = require('telescope.builtin')
local telescope_theme = require('config.cores.telescope.theme').dropdown_theme

-- Main finding
vim.keymap.set('n', '<c-p>', function()
  builtin.find_files(telescope_theme('Files'))
end, { silent = true, noremap = true, desc = 'Find files' })

vim.keymap.set('n', '<leader>fi', function()
  builtin.find_files(telescope_theme('Files', false, true))
end, { silent = true, noremap = true, desc = 'Find files include ignore' })

vim.keymap.set('n', '<leader>fb', function()
  return builtin.buffers(telescope_theme('Buffers'))
end, { silent = true, noremap = true, desc = 'List buffers' })
vim.keymap.set('n', '<leader>/', function()
  return require('telescope').extensions.live_grep_args.live_grep_args(telescope_theme('LiveGrep', true))
end, { silent = true, noremap = true, desc = 'Grep words' })

vim.keymap.set('n', '<leader>fm', function()
  return builtin.marks(telescope_theme('Marks'))
end, { silent = true, noremap = true, desc = 'List marks' })

vim.keymap.set('n', '<leader>fj', function()
  return builtin.jumplist(telescope_theme('Jumplist', true))
end, { silent = true, noremap = true, desc = 'List jumplist' })

vim.keymap.set('n', 'gr', function()
  builtin.lsp_references(telescope_theme('References', true))
end, { silent = true, noremap = true, desc = 'Find references' })

-- TODO list
vim.keymap.set('n', '<leader>td', ':TodoTelescope<CR>', { silent = true, noremap = true, desc = 'List todo list' })

-- prefix with <leader>f
vim.keymap.set('n', '<leader>f/', function()
  return builtin.current_buffer_fuzzy_find(telescope_theme('CurrentBuffer'))
end, { silent = true, noremap = true, desc = 'Search in current buffer' })

vim.keymap.set('n', '<leader>fr', function()
  local theme_opts = telescope_theme('Recent Files')
  theme_opts.cwd_only = true
  builtin.oldfiles(theme_opts)
end, { silent = true, noremap = true, desc = 'Search recent files in project' })

vim.keymap.set('n', '<leader>fR', function()
  local theme_opts = telescope_theme('Recent Files (All)')
  builtin.oldfiles(theme_opts)
end, { silent = true, noremap = true, desc = 'Search all recent files' })

-- searching vim built-in
vim.keymap.set('n', 'g?', function()
  return builtin.help_tags(telescope_theme('HelpTags'))
end, { silent = true, noremap = true, desc = 'Open help tags' })

vim.keymap.set('n', '<leader><BS>', function()
  builtin.keymaps(telescope_theme('Keymaps'))
end, { silent = true, noremap = true, desc = 'List keymaps' })

vim.keymap.set('n', '<leader>"', function()
  builtin.registers(telescope_theme('Registers'))
end, { silent = true, noremap = true, desc = 'List registers' })

-- vim config
vim.keymap.set(
  'n',
  '<leader>vc',
  ':Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>',
  { silent = true, noremap = true, desc = 'Find vim configurations' }
)

-- File Browser with the path of the current path
vim.keymap.set('n', ',e', function()
  local function telescope_buffer_dir()
    return vim.fn.expand('%:p:h')
  end

  telescope.extensions.file_browser.file_browser({
    path = '%:p:h',
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = true,
  })
end, { silent = true, noremap = true, desc = 'File browser' })

-- Resume Previous Telescope
vim.keymap.set('n', '<leader>fl', function()
  local builtin = builtin

  builtin.resume(telescope_theme('Resume'))
end, { silent = true, noremap = true, desc = 'Get last telescope result' })

-- -- NEST JS
-- vim.keymap.set("n", "<leader>fn", function()
--   require('config.cores.telescope.custom.nest_js')({
--     search = vim.fn.input("Search nest_js: ")
--   })
-- end)

vim.keymap.set('n', '<leader>fa', function()
  builtin.find_files({
    prompt_title = 'APIs',
    find_command = { 'fd', '--type', 'f', '--extension', 'http' },
  })
end, { silent = true, noremap = true, desc = 'List HTTP APIs' })

-- Select theme
vim.keymap.set('n', '<leader>ct', function()
  require('config.cores.telescope.custom.theme_select')()
end, { silent = true, noremap = true, desc = 'Choose theme' })
