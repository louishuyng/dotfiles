local group = vim.api.nvim_create_augroup('StartApp', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', { command = 'syntax on', group = group })
-- vim.api.nvim_create_autocmd("VimEnter", { command = "NvimTreeOpen", group = group })
