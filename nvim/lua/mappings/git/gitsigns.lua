local buf_map = require 'utils.buf_map'

local M = {}

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
end

return M