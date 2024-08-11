local opts = { noremap = true, silent = true }

vim.keymap.set("v", "<leader>r", ":SnipRun<CR>", opts)

-- Run a script with visual all the text in current buffer and run it
vim.keymap.set("n", "<leader>r", function()
  vim.cmd(":'<,'>SnipRun")
end, opts)
