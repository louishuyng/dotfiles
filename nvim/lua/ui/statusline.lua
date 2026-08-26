local icons = require('config.libs.icons')
local palette = require('config.theme.palette')
local M = {}

local function setup_highlights(c)
  c = c or palette.colors
  if not next(c) then
    return
  end

  local hl = vim.api.nvim_set_hl

  hl(0, 'StatusLine', { bg = c.bg_alt, fg = c.text })
  hl(0, 'StatusLineNC', { bg = c.bg_alt, fg = c.muted })

  -- Tabline (visible when 2+ tabs exist; see options/init.lua showtabline).
  -- Inactive tabs sit on the bg_alt chrome layer (same as the tree, since
  -- both are "frame" elements). The active tab drops to editor bg so it
  -- visually owns the canvas below.
  hl(0, 'TabLine', { bg = c.bg_alt, fg = c.muted })
  hl(0, 'TabLineSel', { bg = c.bg, fg = c.primary, bold = true })
  hl(0, 'TabLineFill', { bg = c.bg_alt })

  hl(0, 'StlModeNormal', { fg = c.primary, bold = true })
  hl(0, 'StlModeInsert', { fg = c.info, bold = true })
  hl(0, 'StlModeVisual', { fg = c.tertiary, bold = true })
  hl(0, 'StlModeCommand', { fg = c.warn, bold = true })
  hl(0, 'StlModeReplace', { fg = c.error, bold = true })
  hl(0, 'StlReadOnly', { fg = c.error, bold = true })
  hl(0, 'StlInfo', { fg = c.info })
  hl(0, 'StlAccent', { fg = c.secondary })
  hl(0, 'StlSnipai', { fg = c.tertiary, bold = true })
  hl(0, 'StlFileSize', { fg = c.muted })
  hl(0, 'StlBranch', { fg = c.tertiary, bold = true })
  hl(0, 'StlFiletype', { fg = c.text })
  hl(0, 'StlRocket', { fg = c.primary })
  hl(0, 'StlScroll', { fg = c.subtle })
  hl(0, 'StlPathModified', { fg = c.attention, bold = true })
  hl(0, 'StlSearch', { fg = c.attention, bold = true })
end

palette.on_change(setup_highlights)

---@return integer
local function get_current_bufnr()
  return vim.fn.winbufnr(vim.g.statusline_winid) or 0
end

---Output the content colored by the supplied highlight group.
---@param highlight_group string
---@param content string
---@return string
local function color(highlight_group, content)
  return string.format('%%#%s#%s%%*', highlight_group, content)
end

---@return string
local function file_name()
  local is_modified = vim.api.nvim_get_option_value('modified', { buf = get_current_bufnr() })
  local file_path = '%{expand("%:p:h:t")}/%{expand("%:p:t")}'

  if is_modified then
    return color('StlPathModified', '󰳻 ' .. file_path)
  end

  return file_path
end

local function file_read_only()
  local is_readonly = vim.api.nvim_get_option_value('readonly', { buf = get_current_bufnr() })

  if is_readonly then
    return color('StlReadOnly', '‼')
  end

  return nil
end

local DIAGNOSTIC_SEVERITIES = {
  { severity = vim.diagnostic.severity.ERROR, hl = 'DiagnosticError', icon = icons.diagnostics.Error, always = true },
  { severity = vim.diagnostic.severity.WARN, hl = 'DiagnosticWarn', icon = icons.diagnostics.Warn, always = true },
  { severity = vim.diagnostic.severity.INFO, hl = 'DiagnosticInfo', icon = icons.diagnostics.Info, always = true },
  { severity = vim.diagnostic.severity.HINT, hl = 'DiagnosticHint', icon = icons.diagnostics.Hint, always = false },
}

local function lsp_status()
  local bufnr = get_current_bufnr()
  local messages = {}
  for _, sev in ipairs(DIAGNOSTIC_SEVERITIES) do
    local count = #vim.diagnostic.get(bufnr, { severity = sev.severity })
    if sev.always or count > 0 then
      table.insert(messages, color(sev.hl, sev.icon .. tostring(count)))
    end
  end
  return table.concat(messages, ' ')
end

local function search_count()
  if vim.v.hlsearch == 0 then
    return nil
  end
  local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 100 })
  if not ok or type(result) ~= 'table' or (result.total or 0) == 0 then
    return nil
  end
  if result.incomplete == 1 then
    return color('StlSearch', '󰍉 ?/?')
  end
  return color('StlSearch', string.format('󰍉 %d/%d', result.current, result.total))
end

-- A row of decorative glyphs that breathe through the theme's accent hues. A
-- short timer runs one phase that all icons share with a per-slot offset, so
-- they pulse as a staggered wave; each full breath re-rolls the glyphs and
-- steps the hue. All PULSE_COUNT icons stay on screen at all times — the
-- breath only dims them (never below PULSE_MIN), it never removes them.
-- Cool Nerd Font icons, all from the Material Design range, which Terminess
-- draws with a real outline: skull, ghost, alien, devil, space-invader, robot,
-- death-star, nuke, biohazard, bug, code-tags. (Font Awesome / Codicon glyphs
-- are in the font's cmap but render as empty outlines here, so they're avoided.)
local PULSE_GLYPHS = { '󰚌', '󰊠', '󰢚', '󰡆', '󰼰', '󰚩', '󰣫', '󰚤', '󰨃', '󰃤', '󰅴' }
local PULSE_HUES = { 'primary', 'secondary', 'tertiary', 'info', 'warn', 'error' }
local PULSE_COUNT = 5 -- number of icons in the row
local PULSE_SEP = '  ' -- padding between icons in the row
local PULSE_PAD_LEFT = ' ' -- extra gap before the row (widens the space after search_count)
local PULSE_INTERVAL = 100 -- ms between ticks
local PULSE_STEP = 0.05 -- phase advance per tick (~2s per full breath)
local PULSE_IDLE_MS = 150 -- don't force redraws until input has been quiet this long
local PULSE_MIN = 0.55 -- dimmest brightness — kept high enough that icons stay visible
local PULSE_MAX = 1.0 -- brightest brightness at the peak of the breath

local pulse = { hue = 1, phase = 0, last_input = 0, glyphs = {} }
for i = 1, PULSE_COUNT do
  pulse.glyphs[i] = PULSE_GLYPHS[i]
end

-- Stamp the last keypress so the timer can tell idle from active editing. The
-- namespace is stable across reloads, so re-sourcing replaces (not stacks) it.
vim.on_key(function()
  pulse.last_input = vim.uv.now()
end, vim.api.nvim_create_namespace('stl_pulse_key'))

local function hex_to_rgb(hex)
  hex = hex:gsub('#', '')
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

---Linearly blend two hex colors; t in [0,1], 0 = from, 1 = to.
local function blend(from, to, t)
  local fr, fg, fb = hex_to_rgb(from)
  local tr, tg, tb = hex_to_rgb(to)
  return string.format(
    '#%02x%02x%02x',
    math.floor(fr + (tr - fr) * t + 0.5),
    math.floor(fg + (tg - fg) * t + 0.5),
    math.floor(fb + (tb - fb) * t + 0.5)
  )
end

-- Recompute every slot's highlight from the current phase. No side effects
-- beyond nvim_set_hl, so it's safe to call on theme change as well as per tick.
local function apply_pulse_hl()
  local c = palette.colors
  if not c.bg_alt then
    return
  end
  for i = 1, PULSE_COUNT do
    local phase = (pulse.phase + (i - 1) / PULSE_COUNT) % 1
    -- cosine easing between PULSE_MIN (breath edges) and PULSE_MAX (its peak).
    local brightness = PULSE_MIN + (PULSE_MAX - PULSE_MIN) * (0.5 - 0.5 * math.cos(phase * 2 * math.pi))
    local hidx = (pulse.hue - 1 + (i - 1)) % #PULSE_HUES + 1
    local hue = c[PULSE_HUES[hidx]] or c.primary
    vim.api.nvim_set_hl(0, 'StlPulse' .. i, { fg = blend(c.bg_alt, hue, brightness), bold = true })
  end
end

-- Fill pulse.glyphs with PULSE_COUNT *distinct* glyphs (partial Fisher-Yates),
-- so no two slots ever show the same character.
local function roll_glyphs()
  local pool = { unpack(PULSE_GLYPHS) }
  for i = 1, PULSE_COUNT do
    local j = math.random(i, #pool)
    pool[i], pool[j] = pool[j], pool[i]
    pulse.glyphs[i] = pool[i]
  end
end

local function pulse_tick()
  if not palette.colors.bg_alt then
    return
  end
  pulse.phase = pulse.phase + PULSE_STEP
  if pulse.phase >= 1 then
    pulse.phase = pulse.phase - 1
    pulse.hue = pulse.hue % #PULSE_HUES + 1
    roll_glyphs()
  end
  apply_pulse_hl()
  -- Only force a redraw when idle; while typing/moving, the user's own events
  -- already redraw the statusline, so forcing more just adds input latency.
  if vim.uv.now() - pulse.last_input > PULSE_IDLE_MS then
    vim.cmd('redrawstatus')
  end
end

-- Seed the slot highlights now (and re-seed on theme flip) so the groups exist
-- before the first tick; on_change fires immediately if the palette is ready.
palette.on_change(apply_pulse_hl)

-- Survive config reloads: stop any timer a previous load of this module started.
if _G.__stl_pulse_timer then
  pcall(function()
    _G.__stl_pulse_timer:stop()
    _G.__stl_pulse_timer:close()
  end)
end
math.randomseed(os.time())
_G.__stl_pulse_timer = vim.uv.new_timer()
if _G.__stl_pulse_timer then
  _G.__stl_pulse_timer:start(PULSE_INTERVAL, PULSE_INTERVAL, vim.schedule_wrap(pulse_tick))
end

local function pulse_icons()
  local parts = {}
  for i = 1, PULSE_COUNT do
    parts[i] = color('StlPulse' .. i, pulse.glyphs[i])
  end
  return PULSE_PAD_LEFT .. table.concat(parts, PULSE_SEP)
end

local function macro_recording()
  local reg = vim.fn.reg_recording()
  if reg == '' then
    return nil
  end
  return color('DiagnosticError', ' @' .. reg)
end

local function marlin_index()
  local ok, marlin = pcall(require, 'marlin')
  if not ok then
    return nil
  end

  local indexes = marlin.get_indexes()
  if not indexes or #indexes == 0 then
    return nil
  end

  local current_file = vim.fn.expand('%:p')
  for i, entry in ipairs(indexes) do
    if entry.filename == current_file then
      return color('StlAccent', '󰵺 ' .. i .. '/' .. #indexes)
    end
  end

  return nil
end

local MODE_COLORS = {
  n = 'StlModeNormal',
  i = 'StlModeInsert',
  v = 'StlModeVisual',
  V = 'StlModeVisual',
  [''] = 'StlModeInsert', -- ctrl-i fallback (kept from prior impl)
  c = 'StlModeCommand',
  s = 'StlModeVisual',
  S = 'StlModeVisual',
  [''] = 'StlModeVisual', -- ctrl-v block visual
  R = 'StlModeReplace',
  Rv = 'StlModeReplace',
  t = 'StlModeInsert',
}

local function mode_bar()
  local mode = vim.api.nvim_get_mode().mode
  local color_group = MODE_COLORS[mode] or 'StlInfo'
  return color(color_group, '▎')
end

local MODE_LETTERS = {
  n = 'NOR',
  i = 'INS',
  v = 'VISL',
  V = 'V-LINE',
  c = 'COMMAND',
  s = 'SEL',
  S = 'S-LINE',
  [''] = 'V-BLOCK',
  R = 'REP',
  Rv = 'V-REP',
  t = 'TERM',
}

local function mode_letter()
  local mode = vim.api.nvim_get_mode().mode
  local color_group = MODE_COLORS[mode] or 'StlInfo'
  local letter = MODE_LETTERS[mode] or mode:upper()
  return color(color_group, letter)
end

local function mode_indicator()
  return mode_bar() .. '' .. mode_letter()
end

local function git_changes()
  local bufnr = get_current_bufnr()
  local git_status = vim.b[bufnr].gitsigns_status_dict

  if not git_status then
    return nil
  end

  local added = git_status.added or 0
  local changed = git_status.changed or 0
  local removed = git_status.removed or 0

  local messages = {}
  if added ~= 0 then
    table.insert(messages, color('GitSignsAdd', string.format(icons.git.added .. '%s', added)))
  end
  if changed ~= 0 then
    table.insert(messages, color('GitSignsChange', string.format(icons.git.modified .. '%s', changed)))
  end
  if removed ~= 0 then
    table.insert(messages, color('GitSignsDelete', string.format(icons.git.removed .. '%s', removed)))
  end

  return table.concat(messages, ' ')
end

local function position()
  local line = vim.fn.line('.')
  local col = vim.fn.virtcol('.')
  local total = vim.fn.line('$')
  local first = vim.fn.line('w0')
  local last = vim.fn.line('w$')

  local scroll
  if first == 1 and last == total then
    scroll = 'All'
  elseif line == 1 then
    scroll = 'Top'
  elseif line == total then
    scroll = 'Bot'
  else
    scroll = string.format('%d%%%%', math.floor((line - 1) / math.max(total - 1, 1) * 100))
  end

  return string.format(
    '%s:%s %s',
    color('StlInfo', tostring(line)),
    color('StlInfo', tostring(col)),
    color('StlScroll', scroll)
  )
end

local function snipai_status()
  local ok, statusline = pcall(require, 'snipai.statusline')
  if not ok then
    return nil
  end
  local text = statusline.status(get_current_bufnr())
  if text == nil or text == '' then
    return nil
  end
  return color('StlSnipai', text)
end

local function file_size()
  local fname = vim.api.nvim_buf_get_name(get_current_bufnr())
  if fname == '' then
    return nil
  end
  local stat = vim.uv.fs_stat(fname)
  if not stat then
    return nil
  end
  local bytes = stat.size
  local s
  if bytes < 1024 then
    s = string.format('%dB', bytes)
  elseif bytes < 1024 * 1024 then
    s = string.format('%.1fk', bytes / 1024)
  else
    s = string.format('%.1fM', bytes / 1024 / 1024)
  end
  return color('StlFileSize', s)
end

local FT_DISPLAY = {
  typescript = 'TypeScript',
  typescriptreact = 'TypeScript',
  javascript = 'JavaScript',
  javascriptreact = 'JavaScript',
  json = 'JSON',
  yaml = 'YAML',
  html = 'HTML',
  css = 'CSS',
  scss = 'SCSS',
  sh = 'Shell',
  zsh = 'Zsh',
  fish = 'Fish',
}

local function filetype()
  local ft = vim.bo[get_current_bufnr()].filetype
  if ft == '' then
    return nil
  end
  local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(ft)
  local name = FT_DISPLAY[ft] or (ft:sub(1, 1):upper() .. ft:sub(2))

  return color('StlFiletype', name)
end

local function git_branch()
  local bufnr = get_current_bufnr()
  local head = vim.b[bufnr].gitsigns_head or vim.g.gitsigns_head
  if not head or head == '' then
    return nil
  end
  return color('StlBranch', ' ' .. head)
end

local function lsp_rocket()
  local bufnr = get_current_bufnr()
  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    return nil
  end
  return color('StlRocket', ' ')
end

function M.statusline()
  local sections = {
    -- Left cluster
    mode_indicator(),
    file_size(),
    file_name(),
    file_read_only(),
    marlin_index(),
    snipai_status(),
    macro_recording(),
    position(),
    search_count(),
    -- pulse_icons(),
    -- Separator
    '%=',
    -- Right cluster
    lsp_rocket(),
    filetype(),
    git_branch(),
    git_changes(),
    lsp_status(),
  }

  return table.concat(
    vim.tbl_filter(function(section)
      return section ~= nil and section ~= ''
    end, sections),
    '  '
  )
end

vim.o.statusline = [[%!v:lua.require('ui.statusline').statusline()]]

return M
