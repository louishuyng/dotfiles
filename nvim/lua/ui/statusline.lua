local icons = require('config.libs.icons')
local M = {}

local function setup_highlights()
  local ok, palettes = pcall(require, 'catppuccin.palettes')
  if not ok then
    return
  end
  local c = palettes.get_palette()
  if not c then
    return
  end

  local hl = vim.api.nvim_set_hl
  hl(0, 'StlModeNormal', { fg = c.green, bold = true })
  hl(0, 'StlModeInsert', { fg = c.mauve, bold = true })
  hl(0, 'StlModeVisual', { fg = c.yellow, bold = true })
  hl(0, 'StlModeCommand', { fg = c.peach, bold = true })
  hl(0, 'StlModeReplace', { fg = c.red, bold = true })
  hl(0, 'StlReadOnly', { fg = c.red, bold = true })
  hl(0, 'StlInfo', { fg = c.blue })
  hl(0, 'StlAccent', { fg = c.teal })
  hl(0, 'StlSnipai', { fg = c.mauve, bold = true })
  hl(0, 'StlFileSize', { fg = c.overlay1 })
  hl(0, 'StlBranch', { fg = c.mauve, bold = true })
  hl(0, 'StlFiletype', { fg = c.text })
  hl(0, 'StlRocket', { fg = c.green })
  hl(0, 'StlScroll', { fg = c.subtext0 })
  hl(0, 'StlPathModified', { fg = c.yellow, bold = true })
end

setup_highlights()
vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_highlights })

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
  n = '󰰓 ',
  i = '󰰄 ',
  v = '󰰫 ',
  V = '󰰫 ',
  [''] = '󰰫 ',
  c = '󰯲 ',
  s = '󰰢 ',
  S = '󰰢 ',
  [''] = '󰰢 ',
  R = '󰰟 ',
  Rv = '󰰟 ',
  t = '󰰥 ',
}

local function mode_letter()
  local mode = vim.api.nvim_get_mode().mode
  local color_group = MODE_COLORS[mode] or 'StlInfo'
  local letter = MODE_LETTERS[mode] or '󰰓'
  return color(color_group, letter)
end

local function mode_indicator()
  return mode_bar() .. ' ' .. mode_letter()
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
