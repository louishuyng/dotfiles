local icons = require('config.libs.icons')
local M = {}

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
  local is_active = vim.g.statusline_winid == vim.api.nvim_get_current_win()
  local bufnr = get_current_bufnr()
  local name = vim.fn.expand('#' .. bufnr .. ':p:t')
  local extension = vim.fn.expand('#' .. bufnr .. ':e')

  local icon, highlight = require('nvim-web-devicons').get_icon(name, extension)
  if not icon then
    -- Is in a folder
    icon = ''
    highlight = 'String'
  end

  local file_path = '%{expand("%:p:h:t")}/%{expand("%:p:t")}'
  local icon_str = icon and color(highlight, icon .. ' ') or ''

  return icon_str .. ' ' .. file_path
end

local function file_modified()
  local is_modified = vim.api.nvim_get_option_value('modified', { buf = get_current_bufnr() })

  if is_modified then
    return color('StatuslineBoolean', '+')
  end

  return nil
end

local function file_read_only()
  local is_readonly = vim.api.nvim_get_option_value('readonly', { buf = get_current_bufnr() })

  if is_readonly then
    return color('StatuslineBoolean', '‼')
  end

  return nil
end

local function lsp_status()
  local bufnr = get_current_bufnr()

  local errors = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warnings = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  local infos = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })
  local hints = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })

  local messages = {}

  -- if no messages, show the checkmark
  if #errors == 0 and #warnings == 0 and #infos == 0 and #hints == 0 then
    return ''
  end

  if #errors ~= 0 then
    table.insert(messages, color('DiagnosticError', string.format(icons.diagnostics.Error .. '%s', #errors)))
  end
  if #warnings ~= 0 then
    table.insert(messages, color('DiagnosticWarn', string.format(icons.diagnostics.Warn .. '%s', #warnings)))
  end

  if #infos ~= 0 then
    table.insert(messages, color('DiagnosticInfo', string.format(icons.diagnostics.Info .. '%s', #infos)))
  end

  if #hints ~= 0 then
    table.insert(messages, color('DiagnosticHint', string.format(icons.diagnostics.Hint .. '%s', #hints)))
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
      return color('Type', '󰵺 ' .. i .. '/' .. #indexes)
    end
  end

  return nil
end

local function mode_color()
  local mode_colors = {
    n = 'String',
    i = 'Keyword',
    v = 'Type',
    V = 'Type',
    [''] = 'Keyword',
    c = 'Constant',
    s = 'Type',
    S = 'Type',
    [''] = 'Type',
    R = 'DiagnosticError',
    Rv = 'DiagnosticError',
  }

  local mode = vim.api.nvim_get_mode().mode
  local icon = '▎'
  local color_group = mode_colors[mode] or 'Function'

  return color(color_group, icon)
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

local function line_tracking()
  local line = vim.fn.line('.')
  local total_lines = vim.fn.line('$')

  if line == 1 then
    return color('Function', 'Top')
  elseif line == total_lines then
    return color('Function', 'Bot')
  end

  return string.format(
    '%s/%s',
    color('Function', string.format('%s', line)),
    color('Function', string.format('%s', total_lines))
  )
end

local function file_encoding()
  local encoding = vim.bo.fileencoding
  if encoding == '' then
    encoding = 'utf-8'
  end

  return color('Type', string.format(icons.misc.Encoding .. ' %s', encoding))
end

function M.statusline()
  local sections = {
    mode_color(),
    file_name(),
    file_modified(),
    file_read_only(),
    '',
    marlin_index(),
    macro_recording(),
    lsp_status(),
    git_changes(),
    -- Right side
    '%=',
    ' ',
    line_tracking(),
    ' ',
    file_encoding(),
  }

  return table.concat(
    vim.tbl_filter(function(section)
      return section
    end, sections),
    ' '
  )
end

vim.o.statusline = [[%!v:lua.require('ui.statusline').statusline()]]

return M
