-- Run from the repo root: nvim --headless --clean -u nvim/tests/multicursor.lua
vim.g.mapleader = ' '
dofile('nvim/lua/config/libs/multicursor.lua')
dofile('nvim/plugin/cool.lua')

local ns = vim.api.nvim_create_namespace('nvim.multicursor')
local function feed(keys)
  vim.api.nvim_feedkeys(vim.keycode(keys), 'mx', false)
end

vim.api.nvim_buf_set_lines(0, 0, -1, true, { 'foo foo bar foo' })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
feed('<C-n>')
feed('<C-n>')
assert(#vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) == 2)
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 1, 12 }))

feed('<C-p>')
assert(#vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) == 2)
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 1, 0 }))

vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
vim.api.nvim_win_set_cursor(0, { 1, 0 })
feed('viw<leader>A')
assert(#vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) == 3)
feed('<Esc>')
assert(#vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) == 0)

print('multicursor checks passed')
vim.cmd('qa!')
