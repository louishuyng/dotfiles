local map = require 'utils.map'

local opt = {}

map("n", "<leader>;",  ":lua require('plugins.git_worktree').pull()<CR>", opt)
map("n", "<leader>ga", ":Gwrite!<CR>", opt)
map("n", "<leader>gb",  ":Telescope git_branches<CR>", opt)
map("n", "<leader>gc", ":Telescope git_commits<CR>", opt)
map("n", "<leader>gd", ":Gvdiff!<CR>", opt)
map("n", "<leader>gl", ":Git log<CR>", opt)
map("n", "<leader>gm",  ":GitMessenger<CR>", opt)
map("n", "<leader>gp", ":lua require('plugins.git_worktree').push()<CR>", opt)
map("n", "<leader>gpf", ":lua require('plugins.git_worktree').push_force()<CR>", opt)
map("n", "<leader>gs", ":Telescope git_stash<CR>", opt)

map("n", ",gb",  ":ToggleBlameLine<CR>", opt)
map("n", ",gd", ":q!<CR> :Gedit!<CR>", opt)
map("n", ",gs", ":Git<CR>:20wincmd_<CR>", opt, {silent = true})
map("n", "<leader>go", "<cmd>lua require'gitlinker'.get_repo_url({action_callback = require'gitlinker.actions'.open_in_browser})<cr>", opt)
map("n", "[h",  "<Plug>(GitGutterPrevHunk)", opt)
map("n", "]h",  "<Plug>(GitGutterNextHunk)", opt)
map("n", "dh", ":diffget //2<CR>", opt)
map("n", "dl", ":diffget //3<CR>", opt)
map("n", "ga",  "<Plug>(GitGutterStageHunk)", opt)
map("n", "gp",  "<Plug>(GitGutterPreviewHunk)", opt)
map("n", "gp",  "<Plug>(GitGutterPreviewHunk)", opt)
map("n", "gu",  "<Plug>(GitGutterUndoHunk)", opt)

map("n", "<leader>1", ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_oivan <CR><CR>", opt)
map("n", "<leader>2", ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_elxr <CR><CR>", opt)
map("n", "<leader>3", ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_open_source <CR><CR>", opt)

-- Octo
map("n", "<leader>gpl", ":Octo pr list<CR>", opt)
map("n", "<leader>gpc", ":Octo pr create<CR>", opt)

map("n", "<leader>gr", ":Octo thread resolve<CR>", opt)
map("n", "<leader>gR", ":Octo thread unresolve<CR>", opt)

map("n", "<leader>grv", ":Octo review start<CR>", opt)
map("n", "<leader>grd", ":Octo review discard<CR>", opt)
map("n", "<leader>grs", ":Octo review submit<CR>", opt)
