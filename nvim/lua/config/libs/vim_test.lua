vim.g['test#strategy'] = "vimux"

vim.cmd([[
  let test#ruby#bundle_exec = 1
  let test#ruby#rspec#options = {
    \ 'nearest': 'RAILS_ENV=test',
    \ 'file':    'RAILS_ENV=test',
  \}
]])
