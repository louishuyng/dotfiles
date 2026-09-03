local map = vim.keymap.set
local ns = vim.api.nvim_create_namespace('nvim.multicursor')

local function active()
  return #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { limit = 1 }) > 0
end

local function visual_matches(all)
  local anchor = vim.fn.getpos('v')
  local cursor = vim.fn.getpos('.')
  local mode = vim.fn.mode()
  local lines = vim.fn.getregion(anchor, cursor, { type = mode })
  local start = anchor
  if cursor[2] < anchor[2] or (cursor[2] == anchor[2] and cursor[3] < anchor[3]) then
    start = cursor
  end

  for i, line in ipairs(lines) do
    lines[i] = vim.fn.escape(line, '\\')
  end
  vim.fn.setreg('/', '\\V' .. table.concat(lines, '\\n'))
  vim.cmd.normal({ vim.keycode('<Esc>'), bang = true })
  vim.api.nvim_win_set_cursor(0, { start[2], mode == 'V' and 0 or start[3] - 1 })
  vim.cmd.normal({ all and '1Q' or 'Qn', bang = true })
end

map('n', '<C-n>', '*NQn', { desc = 'Add next match cursor' })
map('x', '<C-n>', function()
  visual_matches(false)
end, { desc = 'Add next selection cursor' })
map('n', '<C-Down>', 'Qj', { desc = 'Add cursor below' })
map('n', '<C-Up>', 'Qk', { desc = 'Add cursor above' })
map('n', '<leader>A', '*N1Q', { desc = 'Add cursors to all word matches' })
map('x', '<leader>A', function()
  visual_matches(true)
end, { desc = 'Add cursors to all selection matches' })
map('x', '<leader>a', 'Q', { desc = 'Add cursors to selected lines' })
map('n', '<C-x>', function()
  return active() and 'n' or '<C-x>'
end, { expr = true, desc = 'Skip multicursor match' })
map('n', '<C-p>', function()
  return active() and ']C' or '<C-p>'
end, { expr = true, desc = 'Remove multicursor match' })
