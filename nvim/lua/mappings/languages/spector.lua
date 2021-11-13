local map = require 'utils.map'

local opt = {}

map("n", "<leader>dd", ":call vimspector#Launch()<CR>", opt)

-- Enable mapping keys that  move directly to window debug windows
-- map("n", "<leader>dt", ":call GotoWindow(g:vimspector_session_windows.tagpage)<CR>", opt)
-- map("n", "<leader>dw", ":call GotoWindow(g:vimspector_session_windows.watches)<CR>", opt)
-- map("n", "<leader>ds", ":call GotoWindow(g:vimspector_session_windows.stack_trace)<CR>", opt)
-- map("n", "<leader>dv", ":call GotoWindow(g:vimspector_session_windows.variables)<CR>", opt)

map("n", "<leader>dc", ":call GotoWindow(g:vimspector_session_windows.code)<CR>", opt)
map("n", "<leader>do", ":call GotoWindow(g:vimspector_session_windows.output)<CR>", opt)

map("n", "<leader>de", ":call vimspector#Reset()<CR>", opt)

map("n", "<leader>dl", "<Plug>VimspectorStepInto", opt)
map("n", "<leader>dj", "<Plug>VimspectorStepOver", opt)
map("n", "<leader>dk", "<Plug>VimspectorStepOut", opt)
map("n", "<leader>d_", "<Plug>VimspectorRestart", opt)
map("n", "<leader>d<space>", ":call vimspector#Continue()<CR>", opt)

map("n", "<leader>drc", "<Plug>VimspectorRunToCursor", opt)
map("n", "<leader>dbp", "<Plug>VimspectorToggleBreakpoint", opt)
