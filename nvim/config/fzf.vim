nnoremap <silent> <leader>e :call Fzf_dev()<CR>


" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

let g:fzf_colors =
  \ { 'fg':    ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

let g:fzf_preview_command = 'bat --color=always --style=grid --theme=ansi-dark {-1}'

let g:fzf_preview_split_key_map = 'ctrl-h'
let g:fzf_preview_vsplit_key_map = 'ctrl-v'
let g:fzf_preview_tabedit_key_map = 'ctrl-t'

function! Fzf_dev()
let l:fzf_files_options = '--preview "bat --theme="OneHalfDark" --style=numbers,changes --color always {2..-1} | head -'.&lines.'"'

function! s:files()
  let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
  return s:prepend_icon(l:files)
endfunction

function! s:prepend_icon(candidates)
  let l:result = []
  for l:candidate in a:candidates
    let l:filename = fnamemodify(l:candidate, ':p:t')
    let l:icon = WebDevIconsGetFileTypeSymbol(l:filename, isdirectory(l:filename))
    call add(l:result, printf('%s %s', l:icon, l:candidate))
  endfor

  return l:result
endfunction

function! s:edit_file(item)
  let l:pos = stridx(a:item, ' ')
  let l:file_path = a:item[pos+1:-1]
  execute 'silent e' l:file_path
endfunction

call fzf#run({
      \ 'source': <sid>files(),
      \ 'sink':   function('s:edit_file'),
      \ 'options': '-m ' . l:fzf_files_options,
      \ 'down':    '40%' })
endfunction
@annata83

nnoremap <silent> <space>h :FZFMru<Cr>
nnoremap <silent> <c-f> :call Fzf_dev()<CR>
nnoremap <silent> <leader>f :Find<CR>
nnoremap <silent> <leader>fc :FzfPreviewGitStatus<CR>
