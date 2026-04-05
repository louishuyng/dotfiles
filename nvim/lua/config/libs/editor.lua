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
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash' })
vim.keymap.set({ 'n', 'o', 'x' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash Treesitter' })
vim.keymap.set('o', 'r', function() require('flash').remote({}) end, { desc = 'Remote Flash' })
vim.keymap.set({ 'n', 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, { desc = 'Treesitter Search' })

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
  keymaps = {
    ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-s>'] = { 'actions.select', opts = { horizontal = true } },
    ['<BS>'] = { 'actions.parent', mode = 'n' },
    ['q'] = { 'actions.close', mode = 'n' },
  },
})
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
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
require('smart-splits').setup({
  resize_mode = {
    hooks = {
      on_enter = function()
        vim.notify('Entering resize mode...', vim.log.levels.INFO)
      end,
      on_leave = function()
        vim.notify('Exiting resize mode', vim.log.levels.INFO)
      end,
    },
  },
})

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

-- Nvim notify
local notify_opts = {
  timeout = 3000,
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
  stages = 'fade_in_slide_out',
  render = 'compact',
  background_colour = '#161616',
  fps = 60,
  icons = {
    ERROR = '󰅚 ',
    WARN = '󰀪 ',
    INFO = '󰋽 ',
    DEBUG = '󰃤 ',
    TRACE = '󰏫 ',
  },
  level = 2,
  minimum_width = 50,
  top_down = false,
  on_open = function(win)
    vim.api.nvim_win_set_config(win, { zindex = 100 })
  end,
}
require('notify').setup(notify_opts)
vim.notify = require('notify')
vim.keymap.set('n', '<leader>un', function()
  require('notify').dismiss({ silent = true, pending = true })
end, { desc = 'Dismiss all Notifications' })

-- SmoothCursor
require('smoothcursor').setup({
  type = 'default',
  cursor = '▷',
  texthl = 'SmoothCursor',
  fancy = {
    enable = true,
    head = { cursor = '▷', texthl = 'SmoothCursor' },
    body = {
      { cursor = '●', texthl = 'SmoothCursorBody' },
      { cursor = '●', texthl = 'SmoothCursorBody' },
      { cursor = '•', texthl = 'SmoothCursorBody' },
      { cursor = '.', texthl = 'SmoothCursorBody' },
    },
  },
  speed = 25,
  intervals = 35,
  threshold = 3,
  disabled_filetypes = { 'alpha', 'neo-tree', 'oil', 'mason' },
})

-- Material icons + web-devicons
local web_devicons_ok, web_devicons = pcall(require, 'nvim-web-devicons')
if web_devicons_ok then
  local material_icon_ok, material_icon = pcall(require, 'nvim-material-icon')
  if material_icon_ok then
    material_icon.setup({
      override = {},
      color_icons = true,
      default = true,
      strict = true,
      override_by_filename = {},
      override_by_extension = {},
    })
    web_devicons.setup({
      override = material_icon.get_icons(),
      color_icons = true,
      default = true,
    })
  end
end

-- LuaSnip
require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_vscode').lazy_load({ paths = '~/.dotfiles/nvim/snippets' })
require('luasnip').filetype_extend('ruby', { 'rails' })

-- Git conflict
require('git-conflict').setup()

-- Tiny inline diagnostic
require('tiny-inline-diagnostic').setup()
vim.diagnostic.config({ virtual_text = false })

-- Opencode
vim.o.autoread = true
vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
  require('opencode').ask('@this: ', { submit = true })
end, { desc = 'Ask opencode…' })
vim.keymap.set({ 'n', 'x' }, '<leader>ox', function()
  require('opencode').select()
end, { desc = 'Execute opencode action…' })
vim.keymap.set({ 'n', 't' }, '<leader>oo', function()
  require('opencode').toggle()
end, { desc = 'Toggle opencode' })
vim.keymap.set('x', '<leader>op', function()
  return require('opencode').operator('@this ')
end, { desc = 'Add range to opencode', expr = true })
vim.keymap.set('n', '<leader>op', function()
  return require('opencode').operator('@this ') .. '_'
end, { desc = 'Add line to opencode', expr = true })
vim.keymap.set('n', '<leader>ob', function()
  require('opencode').ask('@buffer: ', { submit = true })
end, { desc = 'Ask about this buffer' })
vim.keymap.set('n', '<[[>', function()
  require('opencode').command('session.half.page.up')
end, { desc = 'Scroll opencode up' })
vim.keymap.set('n', '<]]>', function()
  require('opencode').command('session.half.page.down')
end, { desc = 'Scroll opencode down' })
