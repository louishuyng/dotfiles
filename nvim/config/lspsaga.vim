nnoremap <silent> gr :Lspsaga lsp_finder<CR>
nnoremap <silent> gd :Lspsaga preview_definition<CR>
nnoremap <silent> ac :Lspsaga code_action<CR>
nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <silent><leader>rr :Lspsaga rename<CR>
nnoremap <silent> [d :Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> ]d :Lspsaga diagnostic_jump_prev<CR>

highlight default LspSagaFinderSelection guifg=#0000 guibg=NONE gui=NONE
