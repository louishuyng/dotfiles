-- Run from the repo root: nvim --headless -u NONE -i NONE -n -l nvim/tests/performance.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. '/nvim')
package.loaded['config.theme.palette'] = { colors = {}, on_change = function() end }
package.loaded.marlin = {
  get_indexes = function()
    return {}
  end,
}
package.loaded['snipai.statusline'] = {
  status = function()
    return ''
  end,
}

local statusline = require('ui.statusline')
_G.__stl_pulse_timer:stop()
_G.__stl_pulse_timer:close()
_G.__stl_pulse_timer = nil

local icons = require('config.libs.icons').diagnostics
local severity = vim.diagnostic.severity
local buf = vim.api.nvim_get_current_buf()
local other_buf = vim.api.nvim_create_buf(false, true)
local ns = vim.api.nvim_create_namespace('performance_diagnostics')
local other_ns = vim.api.nvim_create_namespace('performance_other_diagnostics')
vim.g.statusline_winid = vim.api.nvim_get_current_win()
vim.diagnostic.config({ virtual_text = false, signs = false, underline = false })

local function diagnostic(level)
  return { lnum = 0, col = 0, message = 'test', severity = level }
end

vim.diagnostic.set(ns, buf, {
  diagnostic(severity.ERROR),
  diagnostic(severity.WARN),
  diagnostic(severity.INFO),
  diagnostic(severity.HINT),
})
vim.diagnostic.set(other_ns, buf, { diagnostic(severity.ERROR) })
vim.diagnostic.set(ns, other_buf, { diagnostic(severity.ERROR) })

local function assert_counts(errors, warnings, info, hints)
  local text = statusline.statusline()
  for _, item in ipairs({
    { 'DiagnosticError', icons.Error, errors },
    { 'DiagnosticWarn', icons.Warn, warnings },
    { 'DiagnosticInfo', icons.Info, info },
  }) do
    local expected = ('%%#%s#%s%d%%*'):format(item[1], item[2], item[3])
    assert(text:find(expected, 1, true), 'Missing diagnostic count: ' .. expected)
  end
  local hint = ('%%#DiagnosticHint#%s%d%%*'):format(icons.Hint, hints)
  assert((text:find(hint, 1, true) ~= nil) == (hints > 0), 'Hint visibility changed')
end

assert_counts(2, 1, 1, 1)
vim.diagnostic.reset(ns, buf)
assert_counts(1, 0, 0, 0)
vim.diagnostic.reset(other_ns, buf)
assert_counts(0, 0, 0, 0)

-- Timed-out searches can return zero totals; keep their visible fallback.
local searchcount = vim.fn.searchcount
vim.v.hlsearch = 1
for index, case in ipairs({
  { { current = 2, total = 3 }, '󰍉 2/3' },
  { { current = 0, total = 0, incomplete = 1 }, '󰍉 ?/?' },
  { { total = 0 }, nil },
}) do
  vim.fn.setreg('/', 'test' .. index)
  vim.fn.searchcount = function(opts)
    assert(opts.timeout <= 16, 'Search counting can block a frame')
    return case[1]
  end
  local text = statusline.statusline()
  if case[2] then
    assert(text:find(case[2], 1, true), 'Search counter changed')
  else
    assert(not text:find('󰍉', 1, true), 'Empty search counter is visible')
  end
end
local searches = 0
vim.fn.searchcount = function()
  searches = searches + 1
  return { current = 1, total = 1 }
end
vim.fn.setreg('/', 'cache_test')
statusline.statusline()
statusline.statusline()
assert(searches == 1, 'Identical redraws repeat the search scan')
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'first', 'second' })
statusline.statusline()
assert(searches == 2, 'Text edits retain stale search counts')
vim.api.nvim_win_set_cursor(0, { 2, 0 })
statusline.statusline()
assert(searches == 3, 'Cursor movement retains stale search counts')
vim.o.ignorecase = not vim.o.ignorecase
statusline.statusline()
assert(searches == 4, 'Search options retain stale search counts')
vim.fn.setreg('/', '\\%#')
statusline.statusline()
statusline.statusline()
assert(searches == 6, 'Position-dependent searches were cached')
vim.fn.searchcount = searchcount
vim.v.hlsearch = 0

-- Metals must keep one shared config and attach for each supported buffer.
local loads, configs, attachments = 0, 0, {}
package.preload.metals = function()
  loads = loads + 1
  return {
    bare_config = function()
      configs = configs + 1
      return { handlers = {}, settings = {} }
    end,
    initialize_or_attach = function(config)
      assert(type(config.on_attach) == 'function')
      table.insert(attachments, config)
    end,
  }
end
dofile('nvim/lua/config/libs/metals.lua')
vim.api.nvim_exec_autocmds('FileType', { pattern = 'lua' })
assert(loads == 0, 'Metals loaded for an unrelated filetype')
for _, ft in ipairs({ 'scala', 'sbt', 'java', 'scala' }) do
  vim.api.nvim_exec_autocmds('FileType', { pattern = ft })
end
assert(loads == 1 and configs == 1 and #attachments == 4, 'Metals initialization changed')
for _, config in ipairs(attachments) do
  assert(config == attachments[1], 'Metals config must be shared')
end

-- The built-in Lua ftplugin starts highlighting before our large-file guard.
vim.cmd('filetype plugin on')
dofile('nvim/lua/config/cores/treesitter.lua')
for _, large in ipairs({ false, true }) do
  local path = vim.fn.tempname() .. '.lua'
  local lines = large and vim.fn['repeat']({ 'local value = true -- test' }, 5000) or { 'local value = true' }
  vim.fn.writefile(lines, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  assert(vim.bo.filetype == 'lua', 'Filetype detection changed')
  assert((vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil) == not large)
  vim.cmd.bwipeout()
  vim.fn.delete(path)
end

vim.cmd.packadd('nvim-cmp')
vim.cmd.packadd('LuaSnip')
dofile('nvim/lua/config/cores/cmp.lua')
local enabled = require('cmp').get_config().enabled
assert(enabled(), 'Normal completion disabled')
vim.b.completion = false
assert(not enabled(), 'Large-file completion guard ignored')
vim.b.completion = nil
vim.bo.buftype = 'prompt'
assert(not enabled(), 'Prompt completion enabled')
vim.bo.buftype = ''
assert(enabled(), 'Completion did not recover')

print('Statusline, deferred Metals, large-file highlighting, and completion checks passed')
vim.cmd('qa!')
