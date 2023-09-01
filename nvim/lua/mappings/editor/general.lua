local opt = {silent = true, noremap = true}

-- General
vim.keymap.set("n", ",s", ":<C-u>split<CR>", opt)
vim.keymap.set("n", ",v", ":<C-u>vsplit<CR>", opt)

vim.keymap.set("n", ",e", ":e <C-R>=expand(\"%:p:h\") . \"/\" <CR>", opt)

vim.keymap.set("v", "<C-x>", ":!pbcopy<CR>", opt)
vim.keymap.set("v", "<C-c>", ":w !pbcopy<CR><CR>", opt)

vim.keymap.set("v", "/", "*")
vim.keymap.set("n", "<C-j>", "<C-w>j", opt)
vim.keymap.set("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set("n", "<C-h>", "<C-w>h", opt)

-- Scrolling Center
vim.keymap.set("n", "<C-d>", "<C-d>zz", opt)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opt)

-- Grep file
vim.keymap
    .set("n", "<leader>fw", "yiw:silent grep <C-R>\" | copen<CR><CR>", opt)

-- Macro Apply Visual
vim.keymap.set("v", ",m", ":normal @")

-- Move Block
vim.keymap.set("v", "<S-j>", ":m'>+<CR>gv=gv", opt)
vim.keymap.set("v", "<S-k>", ":m-2<CR>gv=gv", opt)

-- Sorting
vim.keymap.set("v", "<leader>so", ":sort<CR>", opt)

-- Open URL
vim.keymap.set("n", "<leader><CR>", ":call OpenUrlUnderCursor()<CR>", opt)

-- Replace
vim.keymap.set("n", "r;", "yiw:%s/<C-R>\"/", opt)

-- Yank
-- " replace currently selected text with default register
-- " without yanking it
vim.keymap.set("v", "p", "\"_dP", opt)

-- Notification
vim.keymap.set("n", "<leader>sn", ":Notifications<CR>", opt)

-- ZenMode
vim.keymap.set("n", "<C-w>o", ":ZenMode<CR>", opt)

-- Lazy
vim.keymap.set("n", "<leader>li", ":Lazy install<CR>", opt)
vim.keymap.set("n", "<leader>lc", ":Lazy clean<CR>", opt)
vim.keymap.set("n", "<leader>lu", ":Lazy update<CR>", opt)

-- Clipboard Code Snippet
vim.keymap.set("v", "<leader>sc", function()
  require('silicon').visualise_api({to_clip = true})
end, opt)

-- Toggle Theme
local reload_theme = function()
  if vim.g.main_theme ~= "linux" then
    vim.g.main_theme = "linux"
  else
    vim.g.main_theme = "edge"
  end

  vim.cmd('luafile ~/.dotfiles/nvim/lua/ui/theme.lua')
  vim.cmd('luafile ~/.dotfiles/nvim/lua/ui/highlights.lua')

  vim.notify("Theme changed to " .. vim.g.main_theme)
end

vim.keymap.set("n", "<leader>0", reload_theme)
