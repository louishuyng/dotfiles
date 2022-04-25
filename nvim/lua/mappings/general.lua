vim.keymap.set("n", ",h", ":<C-u>split<CR>")
vim.keymap.set("n", ",v", ":<C-u>vsplit<CR>")

vim.keymap.set("n", ",e", ":e <C-R>=expand(\"%:p:h\") . \"/\" <CR>")

vim.keymap.set("v", "<C-x>", ":!pbcopy<CR>")
vim.keymap.set("v", "<C-c>", ":w !pbcopy<CR><CR>")

vim.keymap.set("v", "/", "*")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")

vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("v", "<C-s>", "<C-C>:w<CR>")
vim.keymap.set("i", "<C-s>", "<C-O>:w<CR>")
vim.keymap.set("n", "<C-d>", ":q!<CR>")
vim.keymap.set("v", "<C-d>", "<ESC>:q!<CR>")
vim.keymap.set("i", "<C-d>", "<ESC>:q!<CR>")

-- Macro Apply Visual
vim.keymap.set("v", ",m", ":normal @")

-- Move Block
vim.keymap.set("v", "<S-j>", ":m'>+<CR>gv=gv")
vim.keymap.set("v", "<S-k>", ":m-2<CR>gv=gv")

vim.keymap.set("v", "<leader>ex", ":w !")

-- Sorting
vim.keymap.set("v", "<leader>so", ":sort<CR>")

-- Open URL
vim.keymap.set("n", "<c-b>", ":call OpenUrlUnderCursor()<CR>")

-- Replace
vim.keymap.set("n", "r;", "yiw:%s/<C-R>\"/")

-- Packer
vim.keymap.set("n", "<leader>pi", ":PackerInstall<CR>")
vim.keymap.set("n", "<leader>pc", ":PackerCompile<CR>")
vim.keymap.set("n", "<leader>pr", ":PackerClean<CR>")
