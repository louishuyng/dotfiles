local toggle_auto_format =
    require"functions.toggle_auto_format".toggle_auto_format

vim.keymap.set("n", "gff", ":vsplit<CR>gf")
vim.keymap.set("n", "gfh", ":split<CR>gf")

vim.keymap.set("n", "<space>A", toggle_auto_format)
