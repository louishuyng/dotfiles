-- Minimal native bufferline: listed buffers as plain names in each file window's winbar.
local palette = require('config.theme.palette')
local M = {}

palette.on_change(function(c)
  c = c or palette.colors
  if not next(c) then
    return
  end
  local hl = vim.api.nvim_set_hl
  hl(0, 'BufLine', { bg = c.bg_alt, fg = c.muted })
  hl(0, 'BufLineSel', { bg = c.bg_alt, fg = c.primary, bold = true })
  hl(0, 'BufLineMod', { bg = c.bg_alt, fg = c.attention })
end)

local function listed_buffers()
  return vim.tbl_filter(function(b)
    return vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b)
  end, vim.api.nvim_list_bufs())
end

-- Tail name, prefixed with the parent dir when two buffers share a tail.
local function labels(bufs)
  local tails, counts = {}, {}
  for _, b in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(b)
    local tail = name == '' and '[No Name]' or vim.fn.fnamemodify(name, ':t')
    tails[b] = tail
    counts[tail] = (counts[tail] or 0) + 1
  end
  local out = {}
  for _, b in ipairs(bufs) do
    local tail = tails[b]
    local name = vim.api.nvim_buf_get_name(b)
    out[b] = counts[tail] > 1 and name ~= '' and (vim.fn.fnamemodify(name, ':h:t') .. '/' .. tail) or tail
  end
  return out
end

function M.render()
  local bufs = listed_buffers()
  local names = labels(bufs)
  local current = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local parts = {}
  for _, b in ipairs(bufs) do
    local group = b == current and 'BufLineSel' or 'BufLine'
    local mod = vim.bo[b].modified and '%#BufLineMod#●' or ' '
    -- %N@fn@ makes the label clickable; fn receives the buffer number.
    parts[#parts + 1] = string.format(
      "%%%d@v:lua.require'ui.bufferline'.click@%%#%s# %s %s%%X",
      b,
      group,
      names[b]:gsub('%%', '%%%%'),
      mod
    )
  end
  return table.concat(parts) .. '%#BufLine#%='
end

function M.click(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
end

local winbar = [[%!v:lua.require('ui.bufferline').render()]]

-- Set per window, not globally: a global winbar would also sit above the
-- file tree, terminals and other special windows. Clearing explicitly matters
-- because a split inherits its parent window's winbar.
local function apply(win)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= '' then
    return
  end
  local is_file = vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ''
  vim.api.nvim_set_option_value('winbar', is_file and winbar or '', { scope = 'local', win = win })
end

local group = vim.api.nvim_create_augroup('ui_bufferline', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType', 'TermOpen' }, {
  group = group,
  callback = function()
    apply(vim.api.nvim_get_current_win())
  end,
})
-- Winbars of other windows don't redraw on their own when the buffer list changes.
vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
  group = group,
  callback = function()
    vim.schedule(function()
      vim.cmd.redrawstatus { bang = true }
    end)
  end,
})

return M
