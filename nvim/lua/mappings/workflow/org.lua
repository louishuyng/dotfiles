local opts = {silent = true}

vim.keymap.set('n', '<leader>oc', ':Neorg gtd capture<CR>', opts)
vim.keymap.set('n', '<leader>ov', ':Neorg gtd views<CR>', opts)
vim.keymap.set('n', '<leader>oe', ':Neorg gtd edit<CR>', opts)

vim.keymap.set('n', '<leader>oww', ':Neorg workspace work<CR>', opts)
vim.keymap.set('n', '<leader>owl', ':Neorg workspace life<CR>', opts)

vim.keymap.set('n', '<leader>oj', ':Neorg journal ')
vim.keymap.set('n', '<leader>ot', ':Neorg journal toc update<CR>')
vim.keymap.set('n', '<leader>op', ':Neorg presenter start<CR>')

-- Task Actions
vim.cmd(
    "autocmd BufEnter *.norg nnoremap gtu :Neorg keybind norg core.norg.qol.todo_items.todo.task_undone<CR>")

vim.cmd(
    "autocmd BufEnter *.norg nnoremap gtd :Neorg keybind norg core.norg.qol.todo_items.todo.task_done<CR>")

vim.cmd(
    "autocmd BufEnter *.norg nnoremap gtp :Neorg keybind norg core.norg.qol.todo_items.todo.task_pending<CR>")

vim.cmd(
    "autocmd BufEnter *.norg nnoremap gth :Neorg keybind norg core.norg.qol.todo_items.todo.task_on_hold<CR>")

vim.cmd(
    "autocmd BufEnter *.norg nnoremap gtc :Neorg keybind norg core.norg.qol.todo_items.todo.task_cancelled<CR>")

vim.cmd(
    "autocmd BufEnter *.norg nnoremap gti :Neorg keybind norg core.norg.qol.todo_items.todo.task_important<CR>")

vim.cmd(
    "autocmd BufEnter *.norg nnoremap <C-Space> :Neorg keybind norg core.norg.qol.todo_items.todo.task_cycle<CR>")
