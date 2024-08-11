vim.keymap.set({ "n", "x" }, "<leader>rf", function()
  require('telescope').extensions.refactoring.refactors()
end)
vim.keymap.set("x", "<leader>re", ":Refactor extract ")
