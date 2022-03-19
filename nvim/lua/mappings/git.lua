local map = require 'utils.map'
local buf_map = require 'utils.buf_map'

local opt = {}
local M = {}

map("n", "<leader>;",  ":lua require('config.libs.git_worktree').pull()<CR>", opt)
map("n", "<leader>ga", ":Gwrite!<CR>", opt)
map("n", "<leader>gb",  ":Telescope git_branches<CR>", opt)
map("n", "<leader>gc", ":Telescope git_commits<CR>", opt)
map("n", "<leader>gl", ":Git log<CR>", opt)
map("n", ",gb", ":Git blame<CR>", opt)
map("n", "<leader>gp", ":lua require('config.libs.git_worktree').push()<CR>", opt)
map("n", "<leader>gpf", ":lua require('config.libs.git_worktree').push_force()<CR>", opt)
map("n", "<leader>gs", ":Telescope git_stash<CR>", opt)

map("n", ",gd", ":q!<CR> :Gedit!<CR>", opt)
map("n", "<leader>gd", ":Gdiffsplit!<CR>", opt)
map("n", ",gs", ":Git<CR>:20wincmd_<CR>", opt, {silent = true})
map("n", "<leader>go", "<cmd>lua require'gitlinker'.get_repo_url({action_callback = require'gitlinker.actions'.open_in_browser})<cr>", opt)
map("n", "dh", ":diffget //2<CR>", opt)
map("n", "dl", ":diffget //3<CR>", opt)

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

-- Message
map("n", "<leader>gcm", ":Git commit -m \"Merge branch '' into ''\"", opt)

-- Git Signs
M.gitsigns_mappings = function(bufnr)
    local gs = package.loaded.gitsigns

    -- Navigation
    buf_map(bufnr, 'n', ']h', "&diff ? ']h' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    buf_map(bufnr, 'n', '[h', "&diff ? '[h' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

    -- Actions
    buf_map(bufnr, {'n', 'v'}, 'ga', ':Gitsigns stage_hunk<CR>')
    buf_map(bufnr, {'n', 'v'}, 'gu', ':Gitsigns reset_hunk<CR>')
    buf_map(bufnr, 'n', 'gA', gs.stage_buffer)
    buf_map(bufnr, 'n', 'gU', gs.undo_stage_hunk)
    buf_map(bufnr, 'n', 'gR', gs.reset_buffer)
    buf_map(bufnr, 'n', 'gp', gs.preview_hunk)
    buf_map(bufnr, 'n', '<leader>td', gs.toggle_deleted)
    -- Text object
    -- map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end

return M
