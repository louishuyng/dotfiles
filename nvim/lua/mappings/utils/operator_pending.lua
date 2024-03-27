local opts = { silent = true }

-- Example: type cp to change params on func(a, b) -> func(_) _ is cursor position
vim.keymap.set("o", "p", "i(", opts)
