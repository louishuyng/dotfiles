local group = vim.api.nvim_create_augroup("StartApp", {clear = true})

vim.api.nvim_create_autocmd("VimEnter", {
  command = "CHADopen --always-focus",
  group = group
})
