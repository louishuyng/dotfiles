local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = 'float'
})
local lazydocker = Terminal:new({
  cmd = "lazydocker",
  hidden = true,
  direction = 'float'
})
local k9s = Terminal:new({cmd = "k9s", hidden = true, direction = 'float'})
local ranger =
    Terminal:new({cmd = "ranger", hidden = true, direction = 'float'})

function _lazygit_toggle() lazygit:toggle() end

function _lazydocker_toggle() lazydocker:toggle() end

function _k9s_toggle() k9s:toggle() end

function _ranger_toggle() ranger:toggle() end

vim.api.nvim_set_keymap("n", "<leader>lg", "<cmd>lua _lazygit_toggle()<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>ld", "<cmd>lua _lazydocker_toggle()<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>ra", "<cmd>lua _ranger_toggle()<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>k9", "<cmd>lua _k9s_toggle()<CR>",
                        {noremap = true, silent = true})
