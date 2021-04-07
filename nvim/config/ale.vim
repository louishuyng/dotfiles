let g:ale_linters = {
\  '*': ['remove_trailing_lines', 'trim_whitespace'],
\  'javascript': ['eslint', 'prettier', 'flow'],
\  'typescript': ['tslint', 'eslint'],
\  'ruby': ['rubocop'],
\  'python': ['flake8', 'pylint'],
\}

let g:ale_fixers = {
\   'typescript': [
\       'tslint',
\       'eslint',
\   ],
\   'javascript': [
\       'prettier',
\       'flow',
\       'eslint',
\   ],
\   'ruby': [
\       'rubocop',
\   ],
\}

let g:ale_enabled = 1
let g:ale_fix_on_save = 1
let g:ale_sign_error = '⛄'
let g:ale_sign_warning = '⚠'
let g:ale_statusline_format = ['⛄ %d', '⚠ %d', '']
let g:ale_echo_msg_format = '%linter%: %s'

nnoremap ]a :ALENextWrap<cr>
nnoremap [a :ALEPreviousWrap<cr>
nmap <leader>at :ALEToggle<CR>
