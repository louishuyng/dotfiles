require('outline').setup({
  outline_window = {
    position = 'right',
    width = 25,
    relative_width = true,
    auto_close = false,
    focus_on_open = true,
    show_cursorline = true,
  },
  outline_items = {
    show_symbol_details = true,
    highlight_hovered_item = true,
    auto_set_cursor = true,
  },
  symbol_folding = {
    autofold_depth = 1,
    auto_unfold = { hovered = true, only = true },
  },
  preview_window = {
    auto_preview = false,
    border = 'single',
  },
})

vim.keymap.set('n', '<leader>ss', '<cmd>Outline<CR>', { desc = 'Toggle outline' })
