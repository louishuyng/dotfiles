-- Run from the repo root: nvim --headless -u NONE -i NONE -n -l nvim/tests/plugin_patches.lua
local root = vim.fn.tempname()
vim.env.XDG_CONFIG_HOME = root .. '/config'
vim.env.XDG_STATE_HOME = root .. '/state'
local plugin = { spec = { name = 'fixture' }, path = root .. '/fixture' }
local patch_dir = vim.fn.stdpath('config') .. '/patches'
vim.fn.mkdir(patch_dir, 'p')
vim.fn.mkdir(plugin.path, 'p')
local target = plugin.path .. '/api.lua'
vim.fn.writefile({ 'return vim.F.if_nil(false, true)' }, target)
vim.fn.writefile({
  '--- a/api.lua',
  '+++ b/api.lua',
  '@@ -1 +1 @@',
  '-return vim.F.if_nil(false, true)',
  '+return vim.nonnil(false, true)',
}, patch_dir .. '/fixture.patch')

local patches = dofile('nvim/lua/config/plugin_patches.lua')
patches.apply(plugin)
assert(dofile(target) == false, 'False default semantics changed')
local content = vim.fn.readfile(target)[1]
assert(content == 'return vim.nonnil(false, true)', 'Patch was not applied')
patches.apply(plugin)
assert(vim.fn.readfile(target)[1] == content, 'Repeated application changed plugin code')

-- An upstream checkout resets the source; the update hook must restore the fix.
vim.fn.writefile({ 'return vim.F.if_nil(false, true)' }, target)
vim.api.nvim_exec_autocmds('PackChanged', { data = vim.tbl_extend('force', plugin, { kind = 'update' }) })
assert(vim.fn.readfile(target)[1] == content, 'Update hook did not restore patch')

local notify = vim.notify
local warnings = 0
vim.notify = function(_, level)
  assert(level == vim.log.levels.WARN)
  warnings = warnings + 1
end
vim.fn.writefile({ 'return "upstream changed"' }, target)
patches.apply(plugin)
vim.notify = notify
assert(warnings == 1, 'Incompatible upstream source was not reported')
assert(dofile(target) == 'upstream changed', 'Incompatible patch overwrote upstream code')

-- Disabled Snacks modules must not fail readiness checks; enabled failures remain visible.
local snacks, health = _G.Snacks, vim.health
local disabled_checks, enabled_checks, errors = 0, 0, 0
_G.Snacks = {
  did_setup = true,
  config = { disabled = { enabled = false }, enabled = { enabled = true } },
  meta = {
    get = function()
      return {
        {
          name = 'disabled',
          meta = { needs_setup = true },
          health = function()
            disabled_checks = disabled_checks + 1
          end,
        },
        {
          name = 'enabled',
          meta = { needs_setup = true },
          health = function()
            enabled_checks = enabled_checks + 1
            vim.health.error('real failure')
          end,
        },
      }
    end,
  },
}
vim.health = {
  start = function() end,
  ok = function() end,
  warn = function() end,
  error = function()
    errors = errors + 1
  end,
}
local snacks_health = dofile(vim.fn.stdpath('data') .. '/site/pack/core/opt/snacks.nvim/lua/snacks/health.lua')
snacks_health.check()
_G.Snacks, vim.health = snacks, health
assert(disabled_checks == 0 and enabled_checks == 1 and errors == 1, 'Snacks health checks ignore module state')
vim.fn.delete(root, 'rf')
print('Plugin patch defaults, idempotence, update hook, and conflict checks passed')
vim.cmd('qa!')
