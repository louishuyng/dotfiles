vim.keymap.set("n", "<leader>dd", ":call vimspector#Launch()<CR>")

-- Enable mapping keys that  move directly to window debug windows
-- vim.keymap.set("n", "<leader>dt", ":call GotoWindow(g:vimspector_session_windows.tagpage)<CR>")
-- vim.keymap.set("n", "<leader>dw", ":call GotoWindow(g:vimspector_session_windows.watches)<CR>")
-- vim.keymap.set("n", "<leader>ds", ":call GotoWindow(g:vimspector_session_windows.stack_trace)<CR>")
-- vim.keymap.set("n", "<leader>dv", ":call GotoWindow(g:vimspector_session_windows.variables)<CR>")

vim.keymap.set("n", "<leader>dc", ":call GotoWindow(g:vimspector_session_windows.code)<CR>")
vim.keymap.set("n", "<leader>do", ":call GotoWindow(g:vimspector_session_windows.output)<CR>")
vim.keymap.set("n", "<leader>dt", ":call GotoWindow(g:vimspector_session_windows.terminal)<CR>")

vim.keymap.set("n", "<leader>de", ":call vimspector#Reset()<CR>")

vim.keymap.set("n", "<leader>dl", "<Plug>VimspectorStepInto")
vim.keymap.set("n", "<leader>dj", "<Plug>VimspectorStepOver")
vim.keymap.set("n", "<leader>dk", "<Plug>VimspectorStepOut")
vim.keymap.set("n", "<leader>d_", "<Plug>VimspectorRestart")
vim.keymap.set("n", "<leader>d<leader>", ":call vimspector#Continue()<CR>")

vim.keymap.set("n", "<leader>drc", "<Plug>VimspectorRunToCursor")
vim.keymap.set("n", "<leader>dbp", "<Plug>VimspectorToggleBreakpoint")
