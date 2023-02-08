local opts = {silent = true, noremap = true}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local Terminal = require('toggleterm.terminal').Terminal

local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float"
})
local bpytop =
    Terminal:new({cmd = "bpytop", hidden = true, direction = "float"})
local lazydocker = Terminal:new({
  cmd = "lazydocker",
  hidden = true,
  direction = "float"
})
local k9s = Terminal:new({cmd = "k9s", hidden = true, direction = 'tab'})
local nnn = Terminal:new({
  cmd = "nnn",
  hidden = true,
  size = 40,
  direction = 'tab'
})

function _lazygit_toggle() lazygit:toggle() end
function _bpytop_toggle() bpytop:toggle() end
function _lazydocker_toggle() lazydocker:toggle() end
function _k9s_toggle() k9s:toggle() end
function _nnn_toggle() nnn:toggle() end

vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>",
                        {noremap = true, silent = true})

vim.keymap.set('n', '<leader>nnn', '<cmd>lua _nnn_toggle()<CR>', opts)
vim.keymap.set('n', '<leader>ht', '<cmd>lua _bpytop_toggle()<CR>', opts)
vim.keymap.set('n', '<leader>ld', '<cmd>lua _lazydocker_toggle()<CR>', opts)
vim.keymap.set('n', '<leader>lg', '<cmd>lua _lazygit_toggle()<CR>', opts)
vim.keymap.set('n', '<leader>k9', '<cmd>lua _k9s_toggle()<CR>', opts)
