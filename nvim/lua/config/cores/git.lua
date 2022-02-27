local present, gitsigns = pcall(require, "gitsigns")
if not present then
  return
end


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

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']h', "&diff ? ']h' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    map('n', '[h', "&diff ? '[h' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

    -- Actions
    map({'n', 'v'}, 'ga', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, 'gu', ':Gitsigns reset_hunk<CR>')
    map('n', 'gA', gs.stage_buffer)
    map('n', 'gr', gs.undo_stage_hunk)
    map('n', 'gR', gs.reset_buffer)
    map('n', 'gp', gs.preview_hunk)
    map('n', ',gb', gs.toggle_current_line_blame)
    map('n', '<leader>gd', gs.diffthis)
    map('n', '<leader>gD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

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
