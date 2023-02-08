local present, term = pcall(require, "toggleterm")
if not present then return end

term.setup({
  size = function(term)
    if term.direction == "vertical" then return vim.o.columns * 0.3 end
  end,
  direction = 'vertical',
  open_mapping = [[<C-\>]]
})
