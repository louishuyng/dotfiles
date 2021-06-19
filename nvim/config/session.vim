let g:auto_save = 1
let g:auto_save_events = ["InsertLeave", "TextChanged"]
let g:auto_save_silent = 1 

nnoremap <silent> <space>sl :SessionLoad<CR>
nnoremap <silent> <space>ss :SessionSave<CR>
