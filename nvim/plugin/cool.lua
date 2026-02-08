-- Efficient hlsearch auto-clear (replaces cool.vim)
-- Only clears on InsertEnter, not CursorMoved (much faster)

local group = vim.api.nvim_create_augroup('EfficientCool', { clear = true })

-- Clear search highlight when entering insert mode
vim.api.nvim_create_autocmd('InsertEnter', {
  group = group,
  callback = function()
    if vim.v.hlsearch == 1 then
      vim.cmd('nohlsearch')
    end
  end,
})

-- Clear search highlight when pressing Escape in normal mode
vim.keymap.set('n', '<Esc>', function()
  if vim.v.hlsearch == 1 then
    vim.cmd('nohlsearch')
  end
  return '<Esc>'
end, { expr = true, silent = true })
