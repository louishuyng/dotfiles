local present, gitsigns = pcall(require, "gitsigns")
if not present then
  return
end

local buf_map = require 'utils.buf_map'

gitsigns.setup{
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    -- Navigation
    buf_map(bufnr, 'n', ']h', "&diff ? ']h' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    buf_map(bufnr, 'n', '[h', "&diff ? '[h' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

    -- Actions
    buf_map(bufnr, {'n', 'v'}, 'ga', ':Gitsigns stage_hunk<CR>')
    buf_map(bufnr, {'n', 'v'}, 'gu', ':Gitsigns reset_hunk<CR>')
    buf_map(bufnr, 'n', 'gA', gs.stage_buffer)
    buf_map(bufnr, 'n', 'gr', gs.undo_stage_hunk)
    buf_map(bufnr, 'n', 'gR', gs.reset_buffer)
    buf_map(bufnr, 'n', 'gp', gs.preview_hunk)
    buf_map(bufnr, 'n', ',gb', gs.toggle_current_line_blame)
    buf_map(bufnr, 'n', '<leader>gd', gs.diffthis)
    buf_map(bufnr, 'n', '<leader>gD', function() gs.diffthis('~') end)
    buf_map(bufnr, 'n', '<leader>td', gs.toggle_deleted)

    -- Text object
    -- map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- Git Messenger
vim.g.git_messenger_always_into_popup = true
vim.g.git_messenger_include_diff = "current"

-- Git Linker
local present, gitlinker = pcall(require, "gitlinker")
if not present then
  return
end

gitlinker.setup({})
