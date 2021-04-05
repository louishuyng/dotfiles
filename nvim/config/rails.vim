nnoremap <SID>: :<C-U><C-R>=v:count ? v:count : ''<CR>

nmap <silent><leader>rf  <SID>:find <Plug><cfile><CR>
nmap <silent><leader>rff ,v <SID>:find <Plug><cfile><CR>
nmap <silent><leader>rfF ,h <SID>:find <Plug><cfile><CR>

" RSpec.vim mappings
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>
