local group = vim.api.nvim_create_augroup("StartApp", {clear = true})

vim.api.nvim_create_autocmd("VimEnter", {command = "syntax on", group = group})
vim.api.nvim_create_autocmd("BufEnter  ~/Dev/org/work/index.norg",
                            {command = "set noswapfile"})

vim.api.nvim_create_autocmd("VimEnter", {
  command = "silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape' 1>/dev/null 2>&1 &",
  group = group
})

vim.api.nvim_create_autocmd("VimLeave", {
  command = "silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Caps_Lock' 1>/dev/null 2>&1 &",
  group = group
})
