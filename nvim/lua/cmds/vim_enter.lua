local group = vim.api.nvim_create_augroup("StartApp", {clear = true})

-- TODO: still need to add some tasks when start vim
vim.api.nvim_create_autocmd("VimEnter", {command = "", group = group})
