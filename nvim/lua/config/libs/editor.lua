-- Miscellaneous plugin setups

-- Comment
require('Comment').setup()

-- Which Key
require('which-key').setup()

-- Flash
require('flash').setup({
  modes = {
    search = { enabled = false },
    char = {
      enabled = true,
      keys = { 'f', 'F' },
    },
  },
})
vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump()
end, { desc = 'Flash' })
vim.keymap.set({ 'n', 'o', 'x' }, 'S', function()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })
vim.keymap.set('o', 'r', function()
  require('flash').remote({})
end, { desc = 'Remote Flash' })
vim.keymap.set({ 'n', 'o', 'x' }, 'R', function()
  require('flash').treesitter_search()
end, { desc = 'Treesitter Search' })

-- Mini plugins
require('mini.bracketed').setup({
  -- Avoid conflict with Marlin navigation
  file = { suffix = '', options = {} },
})
require('mini.surround').setup({})
require('mini.pairs').setup({})

-- TODO comments
require('todo-comments').setup({})

-- Trouble
require('trouble').setup({
  use_diagnostic_signs = true,
})
vim.keymap.set('n', '<leader>fd', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })

-- Oil
require('oil').setup({
  columns = {
    'icon',
    { 'permissions', highlight = 'Comment' },
    { 'size', highlight = 'Number' },
    { 'mtime', highlight = 'Comment', format = '%d %b %Y %H:%M' },
  },
  win_options = {
    number = false,
    relativenumber = false,
  },
  delete_to_trash = true,
  watch_for_changes = true,
  view_options = {
    show_hidden = true,
    case_insensitive = true,
    is_always_hidden = function(name)
      return name == '..' or name == '.git' or name == '.DS_Store'
    end,
  },
  keymaps = {
    ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-s>'] = { 'actions.select', opts = { horizontal = true } },
    ['<BS>'] = { 'actions.parent', mode = 'n' },
    ['q'] = { 'actions.close', mode = 'n' },
  },
})
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('n', ',e', '<CMD>Oil<CR>', { desc = 'File browser' })
vim.api.nvim_create_autocmd('User', {
  pattern = 'OilActionsPost',
  callback = function(event)
    if event.data.actions.type == 'move' then
      Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
    end
  end,
})

-- Code runner
require('code_runner').setup({
  filetype = {
    go = { 'go run' },
  },
})

-- Smart splits
require('smart-splits').setup({})

-- Colorizer
require('colorizer').setup({
  '*',
  css = { css = true },
  scss = { css = true },
}, {
  RGB = true,
  RRGGBB = true,
  names = false,
  RRGGBBAA = true,
  rgb_fn = true,
  hsl_fn = true,
  css = true,
  css_fn = true,
  mode = 'background',
})

-- LuaSnip
require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_vscode').lazy_load({ paths = '~/.dotfiles/nvim/snippets' })
require('luasnip').filetype_extend('ruby', { 'rails' })

-- Tiny inline diagnostic
require('tiny-inline-diagnostic').setup()
vim.diagnostic.config({ virtual_text = false })

-- Opencode
-- vim.o.autoread = true
-- vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
--   require('opencode').ask('@this: ', { submit = true })
-- end, { desc = 'Ask opencode…' })
-- vim.keymap.set({ 'n', 'x' }, '<leader>ox', function()
--   require('opencode').select()
-- end, { desc = 'Execute opencode action…' })
-- vim.keymap.set({ 'n', 't' }, '<leader>oo', function()
--   require('opencode').toggle()
-- end, { desc = 'Toggle opencode' })
-- vim.keymap.set('x', '<leader>op', function()
--   return require('opencode').operator('@this ')
-- end, { desc = 'Add range to opencode', expr = true })
-- vim.keymap.set('n', '<leader>op', function()
--   return require('opencode').operator('@this ') .. '_'
-- end, { desc = 'Add line to opencode', expr = true })
-- vim.keymap.set('n', '<leader>ob', function()
--   require('opencode').ask('@buffer: ', { submit = true })
-- end, { desc = 'Ask about this buffer' })
-- vim.keymap.set('n', '<[[>', function()
--   require('opencode').command('session.half.page.up')
-- end, { desc = 'Scroll opencode up' })
-- vim.keymap.set('n', '<]]>', function()
--   require('opencode').command('session.half.page.down')
-- end, { desc = 'Scroll opencode down' })
