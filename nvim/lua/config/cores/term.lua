local present, toggleterm = pcall(require, "toggleterm")

toggleterm.setup {
  direction = 'horizontal',
  size = vim.o.lines * 0.3,
  open_mapping = [[<c-t>]]
}
