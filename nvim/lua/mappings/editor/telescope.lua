local telescope = require('telescope')
local builtin = require('telescope.builtin')
local dropdown_theme = require('config.cores.telescope.theme').dropdown_theme

-- Main finding
vim.keymap.set('n', '<c-p>', function()
  builtin.find_files(dropdown_theme('Files'))
end, { silent = true, noremap = true, desc = 'Find files' })

vim.keymap.set('n', '<leader>fi', function()
  builtin.find_files(dropdown_theme('Files', false, true))
end, { silent = true, noremap = true, desc = 'Find files include ignore' })

vim.keymap.set('n', '<leader>fb', function()
  return builtin.buffers(dropdown_theme('Buffers'))
end, { silent = true, noremap = true, desc = 'List buffers' })

vim.keymap.set('n', '<leader>/', function()
  return require('telescope').extensions.live_grep_args.live_grep_args(dropdown_theme('LiveGrep', true))
end, { silent = true, noremap = true, desc = 'Grep words' })

vim.keymap.set('n', '<leader>fm', function()
  return builtin.marks(dropdown_theme('Marks'))
end, { silent = true, noremap = true, desc = 'List marks' })

vim.keymap.set('n', '<leader>fj', function()
  return builtin.jumplist(dropdown_theme('Jumplist', true))
end, { silent = true, noremap = true, desc = 'List jumplist' })

vim.keymap.set('n', 'gr', function()
  builtin.lsp_references(dropdown_theme('References', true))
end, { silent = true, noremap = true, desc = 'Find references' })

vim.keymap.set('n', '<leader>fd', function()
  builtin.diagnostics(dropdown_theme('Diagnostics'))
end, { silent = true, noremap = true, desc = 'Find diagnostics' })

-- TODO list
vim.keymap.set('n', '<leader>td', ':TodoTelescope<CR>', { silent = true, noremap = true, desc = 'List todo list' })

-- prefix with <leader>f
vim.keymap.set('n', '<leader>f/', function()
  return builtin.current_buffer_fuzzy_find(dropdown_theme('CurrentBuffer'))
end, { silent = true, noremap = true, desc = 'Search in current buffer' })

vim.keymap.set('n', '<leader>fr', function()
  require('telescope').extensions.frecency.frecency(dropdown_theme('Recent Files'))
end, { silent = true, noremap = true, desc = 'Search recent files' })

-- searching vim built-in
vim.keymap.set('n', 'g?', function()
  return builtin.help_tags(dropdown_theme('HelpTags'))
end, { silent = true, noremap = true, desc = 'Open help tags' })

vim.keymap.set('n', '<leader><BS>', function()
  builtin.keymaps(dropdown_theme('Keymaps'))
end, { silent = true, noremap = true, desc = 'List keymaps' })

vim.keymap.set('n', '<leader>"', function()
  builtin.registers(dropdown_theme('Registers'))
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

  builtin.resume(dropdown_theme('Resume'))
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
