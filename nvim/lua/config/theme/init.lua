-- Theme orchestrator.
--
-- Holds two slots (dark + light) populated by adapters. auto-dark-mode flips
-- between them; `:Theme` reassigns either slot at runtime. Consumers don't
-- care which adapter is active — they read semantic colors from
-- config.theme.palette and re-apply via palette.on_change.

local palette = require('config.theme.palette')

-- Modern colorschemes require true-color terminal support.
vim.o.termguicolors = true

local M = {}

-- Adapters are loaded lazily so installing a new theme doesn't pay for it
-- until the user actually swaps to it.
local adapter_loaders = {
  catppuccin = function()
    return require('config.theme.adapters.catppuccin')
  end,
  cendre = function()
    return require('config.theme.adapters.cendre')
  end,
  gruvbox_material = function()
    return require('config.theme.adapters.gruvbox_material')
  end,
  melange = function()
    return require('config.theme.adapters.melange')
  end,
  github = function()
    return require('config.theme.adapters.github')
  end,
  solarized_osaka = function()
    return require('config.theme.adapters.solarized_osaka')
  end,
}

local adapters = {}
local setup_done = {}

local function get_adapter(name)
  if not adapters[name] then
    local loader = adapter_loaders[name]
    if not loader then
      vim.notify(('config.theme: unknown theme %q, falling back to "catppuccin"'):format(name), vim.log.levels.WARN)
      loader = adapter_loaders['catppuccin']
      if not loader then
        error(('config.theme: unknown theme %q'):format(name), 2)
      end
      name = 'catppuccin'
    end
    adapters[name] = loader()
  end
  return adapters[name]
end

local function ensure_setup(name)
  local adapter = get_adapter(name)
  if not setup_done[name] then
    adapter.setup()
    setup_done[name] = true
  end
  return adapter
end

-- Defaults — change these or call M.set / :Theme to swap. User runtime
-- choices are persisted to a state file (see load_state / save_state below)
-- and override these defaults at startup.
M.config = {
  dark = 'catppuccin',
  light = 'catppuccin',
}

local state_path = vim.fs.joinpath(vim.fn.stdpath('state'), 'theme.json')

local function load_state()
  local f = io.open(state_path, 'r')
  if not f then
    return
  end
  local raw = f:read('*a')
  f:close()
  local ok, data = pcall(vim.json.decode, raw)
  if not ok or type(data) ~= 'table' then
    vim.notify('config.theme: ignoring malformed ' .. state_path, vim.log.levels.WARN)
    return
  end
  for _, variant in ipairs({ 'dark', 'light' }) do
    local name = data[variant]
    if type(name) == 'string' and adapter_loaders[name] then
      M.config[variant] = name
    end
  end
end

local function save_state()
  vim.fn.mkdir(vim.fs.dirname(state_path), 'p')
  local f, err = io.open(state_path, 'w')
  if not f then
    vim.notify('config.theme: cannot write ' .. state_path .. ': ' .. tostring(err), vim.log.levels.WARN)
    return
  end
  f:write(vim.json.encode({ dark = M.config.dark, light = M.config.light }))
  f:close()
end

load_state()

local active_variant = vim.o.background == 'light' and 'light' or 'dark'

local function apply(variant)
  active_variant = variant
  local adapter = ensure_setup(M.config[variant])
  palette.set_adapter(adapter)

  -- Adapters flip `vim.o.background` before `:colorscheme`, and that flip
  -- re-sources the *current* (outgoing) colorscheme, firing a ColorScheme event
  -- while the old theme's colors are still live. Plugins that re-derive
  -- highlights from base groups with `default = true` (git-conflict, neogit,
  -- gitsigns, oil, ...) latch onto those stale colors on that early event; the
  -- real colorscheme load then can't override a group already set as default,
  -- so their colors lag one toggle behind until a restart. Swallow ColorScheme
  -- across the whole swap and emit exactly one event once the new theme is live.
  local eventignore = vim.o.eventignore
  vim.o.eventignore = (eventignore ~= '' and eventignore .. ',' or '') .. 'ColorScheme'
  local ok, err = pcall(adapter.apply, variant)
  vim.o.eventignore = eventignore
  if not ok then
    error(err)
  end
  vim.api.nvim_exec_autocmds('ColorScheme', { pattern = vim.g.colors_name })
end

---@param themes string|{dark?:string, light?:string}
function M.set(themes)
  if type(themes) == 'string' then
    themes = { dark = themes, light = themes }
  end
  M.config.dark = themes.dark or M.config.dark
  M.config.light = themes.light or M.config.light
  apply(active_variant)
  save_state()
end

function M.list()
  return vim.tbl_keys(adapter_loaders)
end

function M.current()
  return {
    dark = M.config.dark,
    light = M.config.light,
    variant = active_variant,
  }
end

apply(active_variant)

require('auto-dark-mode').setup({
  update_interval = 1000,
  set_dark_mode = function()
    apply('dark')
  end,
  set_light_mode = function()
    apply('light')
  end,
})

-- :Theme                          -> show current state
-- :Theme tokyonight               -> set both dark and light to tokyonight
-- :Theme dark=tokyonight light=catppuccin -> set per-variant
vim.api.nvim_create_user_command('Theme', function(opts)
  local args = opts.fargs
  if #args == 0 then
    local s = M.current()
    vim.notify(('theme: dark=%s  light=%s  variant=%s'):format(s.dark, s.light, s.variant), vim.log.levels.INFO)
    return
  end
  if #args == 1 and not args[1]:find('=') then
    M.set(args[1])
    return
  end
  local cfg = {}
  for _, a in ipairs(args) do
    local k, v = a:match('^([^=]+)=(.+)$')
    if k and v then
      cfg[k] = v
    end
  end
  M.set(cfg)
end, {
  nargs = '*',
  complete = function(arg)
    local names = vim.tbl_keys(adapter_loaders)
    if arg:find('=') then
      local prefix = arg:match('^([^=]+)=')
      return vim.tbl_map(function(n)
        return prefix .. '=' .. n
      end, names)
    end
    return names
  end,
  desc = 'Switch nvim colorscheme adapter',
})

return M
