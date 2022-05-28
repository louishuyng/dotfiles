local searching_google_in_normal =
    [[:lua vim.fn.system({'open', 'https://google.com/search?q=' .. vim.fn.expand("<cword>")})<CR>]]
local searching_google_in_visual =
    [[<ESC>gv"gy<ESC>:lua vim.fn.system({'open', 'https://google.com/search?q=' .. vim.fn.getreg('g')})<CR>]]

vim.keymap.set("n", "<C-g>", searching_google_in_normal,
               {silent = true, noremap = true})
vim.keymap.set("v", "<C-g>", searching_google_in_visual,
               {silent = true, noremap = true})
