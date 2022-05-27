local buf_map = require 'utils.buf_map'

local M = {}

vim.keymap.set("n", "<leader>;",
               ":lua require('config.libs.git_worktree').pull()<CR>")
vim.keymap.set("n", "<leader>ga", ":Gwrite!<CR>")
vim.keymap.set("n", "<leader>gb", ":Telescope git_branches<CR>")
vim.keymap.set("n", "<leader>gc", ":Telescope git_commits<CR>")
vim.keymap.set("n", "<leader>gl", ":Git log<CR>")
vim.keymap.set("n", ",gb", ":Git blame<CR>")
vim.keymap.set("n", "<leader>gp",
               ":lua require('config.libs.git_worktree').push()<CR>")
vim.keymap.set("n", "<leader>gpf",
               ":lua require('config.libs.git_worktree').push_force()<CR>")

vim.keymap.set("n", ",gs", ":Git<CR>:20wincmd_<CR>", {silent = true})
vim.keymap.set("n", "<leader>go",
               "<cmd>lua require'gitlinker'.get_repo_url({action_callback = require'gitlinker.actions'.open_in_browser})<cr>")

vim.keymap.set("n", "<leader>1",
               ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_oivan <CR><CR>")
vim.keymap.set("n", "<leader>2",
               ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_elxr <CR><CR>")
vim.keymap.set("n", "<leader>3",
               ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_open_source <CR><CR>")

-- Octo
vim.keymap.set("n", "<leader>gpl", ":Octo pr list<CR>")
vim.keymap.set("n", "<leader>gpc", ":Octo pr create<CR>")

vim.keymap.set("n", "<leader>gr", ":Octo thread resolve<CR>")
vim.keymap.set("n", "<leader>gR", ":Octo thread unresolve<CR>")

vim.keymap.set("n", "<leader>grv", ":Octo review start<CR>")
vim.keymap.set("n", "<leader>grd", ":Octo review discard<CR>")
vim.keymap.set("n", "<leader>grs", ":Octo review submit<CR>")

-- Merge Tool
vim.keymap.set("n", "dh", ":diffget //2<CR>")
vim.keymap.set("n", "dl", ":diffget //3<CR>")
vim.keymap.set("n", "<leader>gm", ":GitConflictListQf<CR>")

-- Git Conflict
vim.keymap.set('n', '<leader>ch', '<Plug>(git-conflict-ours)')
vim.keymap.set('n', '<leader>ci', '<Plug>(git-conflict-theirs)')
vim.keymap.set('n', '<leader>cb', '<Plug>(git-conflict-both)')
vim.keymap.set('n', '<leader>c0', '<Plug>(git-conflict-none)')
vim.keymap.set("n", "]x", "<Plug>(git-conflict-next-conflict)")
vim.keymap.set("n", "[x", "<Plug>(git-conflict-prev-conflict)")

-- Git Signs
M.gitsigns_mappings = function(bufnr)
  local gs = package.loaded.gitsigns

  -- Navigation
  buf_map(bufnr, 'n', ']h', "&diff ? ']h' : '<cmd>Gitsigns next_hunk<CR>'",
          {expr = true})
  buf_map(bufnr, 'n', '[h', "&diff ? '[h' : '<cmd>Gitsigns prev_hunk<CR>'",
          {expr = true})

  -- Actions
  buf_map(bufnr, {'n', 'v'}, 'ga', ':Gitsigns stage_hunk<CR>')
  buf_map(bufnr, {'n', 'v'}, 'gu', ':Gitsigns reset_hunk<CR>')
  buf_map(bufnr, 'n', 'gA', gs.stage_buffer)
  buf_map(bufnr, 'n', 'gU', gs.undo_stage_hunk)
  buf_map(bufnr, 'n', 'gR', gs.reset_buffer)
  buf_map(bufnr, 'n', 'gp', gs.preview_hunk)
  buf_map(bufnr, 'n', '<leader>td', gs.toggle_deleted)
  -- Text object
  -- vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end

return M
