-- vim-visual-multi (mg979/vim-visual-multi)
-- Defaults already give: <C-n> next match, <C-Down>/<C-Up> column cursors, <Esc> quit.
-- Override "Select All" so it isn't \\A (default leader is `\\`).
vim.g.VM_default_mappings = 1
vim.g.VM_maps = {
  ['Select All']    = '<Leader>A', -- normal: <Space>A select all matches of word under cursor
  ['Visual All']    = '<Leader>A', -- visual: <Space>A select all matches of visual selection
  ['Visual Add']    = '<Leader>a', -- visual: <Space>a add current selection as a cursor
  ['Skip Region']   = '<C-x>',
  ['Remove Region'] = '<C-p>',
}
