local opt = { silent = true, noremap = true }

vim.keymap.set("n", "<leader>S", ":lua require('spectre').open()<CR>", opt)
vim.keymap.set("n", "<leader>sw",
  ":lua require('spectre').open_visual({select_word=true})<CR>",
  opt)
vim.keymap.set("v", "<leader>s", ":lua require('spectre').open_visual()<CR>",
  opt)
