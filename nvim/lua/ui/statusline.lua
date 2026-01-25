local icons = require('config.libs.icons')
local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
  return
end

-- Detect current theme and get colors
local function get_theme_colors()
  local colorscheme = vim.g.colors_name or 'midnight'
  
  if colorscheme == 'daylight' then
    return require('lush_themes.daylight.colors')
  else
    return require('lush_themes.midnight.colors')
  end
end

local theme_colors = get_theme_colors()

local colors = {
  bg0 = theme_colors.bg_dark,
  bg1 = theme_colors.bg,
  bg2 = theme_colors.bg_highlight,
  fg0 = theme_colors.fg,
  fg1 = theme_colors.fg_dark,
  fg2 = theme_colors.fg,
  red0 = theme_colors.red,
  red1 = theme_colors.red,
  yellow0 = theme_colors.yellow,
  yellow1 = theme_colors.yellow,
  green0 = theme_colors.green,
  green1 = theme_colors.green,
  blue1 = theme_colors.blue,
  purple0 = theme_colors.purple,
  purple1 = theme_colors.purple,
}

local theme = {
  normal = {
    a = { bg = colors.blue1, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg2, fg = colors.blue1 },
    c = { bg = colors.bg0, fg = colors.fg2 },
  },
  insert = {
    a = { bg = colors.green0, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg2, fg = colors.green1 },
  },
  command = {
    a = { bg = colors.yellow0, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg2, fg = colors.yellow1 },
  },
  visual = {
    a = { bg = colors.purple0, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg2, fg = colors.purple1 },
  },
  replace = {
    a = { bg = colors.red0, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg2, fg = colors.red1 },
  },
  inactive = {
    a = { bg = colors.bg1, fg = colors.fg1 },
    b = { bg = colors.bg0, fg = colors.fg1 },
    c = { bg = colors.bg0, fg = colors.fg1 },
  },
}

local marlin = require('marlin')
local marlin_component = function()
  local indexes = marlin.num_indexes()
  if indexes == 0 then
    return ''
  end
  local cur_index = marlin.cur_index()

  return ' ' .. cur_index .. '/' .. indexes
end

lualine.setup {
  options = {
    theme = theme,
    globalstatus = true,
    disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'intro' } },
    section_separators = { left = '', right = '' },
    component_separators = { left = '│', right = '│' },
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {
      {
        'active',
        fmt = function()
          return ''
        end,
        color = function()
          local mode = vim.fn.mode()
          local mode_color = {
            n = colors.blue1,
            i = colors.green1,
            v = colors.purple1,
            V = colors.purple1,
            ['\22'] = colors.purple1,
            c = colors.yellow1,
            s = colors.purple1,
            S = colors.purple1,
            ['\19'] = colors.purple1,
            R = colors.red1,
            r = colors.red1,
            ['!'] = colors.yellow1,
            t = colors.green1,
          }
          return { fg = mode_color[mode] or colors.blue1 }
        end,
      },
    },
    lualine_c = {
      {
        'branch',
        icon = '',
        color = { fg = colors.fg0, gui = 'bold' },
        padding = { left = 1, right = 1 },
      },
      {
        'diff',
        symbols = {
          added = icons.git.added or ' ',
          modified = icons.git.modified or ' ',
          removed = icons.git.removed or ' ',
        },
        diff_color = {
          added = { fg = colors.green0 },
          modified = { fg = colors.yellow0 },
          removed = { fg = colors.red0 },
        },
        padding = { left = 1, right = 1 },
      },
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error .. ' ',
          warn = icons.diagnostics.Warn .. ' ',
          info = icons.diagnostics.Info .. ' ',
          hint = icons.diagnostics.Hint .. ' ',
        },
        diagnostics_color = {
          error = { fg = colors.red0 },
          warn = { fg = colors.yellow0 },
          info = { fg = colors.blue1 },
          hint = { fg = colors.fg2 },
        },
        padding = { left = 1, right = 1 },
      },
      {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = ' ●',
          readonly = ' ',
          unnamed = '[No Name]',
          newfile = ' ',
        },
        color = { fg = colors.green0 },
        padding = { left = 1, right = 1 },
      },
      {
        'marlin',
        fmt = marlin_component,
        color = { fg = colors.purple0 },
        padding = { left = 1, right = 1 },
      },
      {
        'opencode',
        ---@alias opencode.status.Status
        ---| "idle"
        ---| "error"
        ---| "responding"
        ---| "requesting_permission"
        color = function()
          local status = require('opencode.status').status

          if status == 'responding' then
            return { fg = colors.green0, gui = 'bold' }
          elseif status == 'requesting_permission' then
            return { fg = colors.yellow0, gui = 'bold' }
          elseif status == 'error' then
            return { fg = colors.red0, gui = 'bold' }
          else
            return { fg = colors.fg2 }
          end
        end,
        fmt = function()
          local status = require('opencode').statusline()
          return status
        end,
        padding = { left = 1, right = 1 },
      },
    },
    lualine_x = {
      {
        -- Recording Macro
        function()
          local reg = vim.fn.reg_recording()
          return reg ~= '' and ' REC @' .. reg or ''
        end,
        color = {
          fg = colors.red0,
          gui = 'bold',
        },
        cond = function()
          return vim.fn.reg_recording() ~= ''
        end,
        padding = { left = 1, right = 1 },
      },
      {
        'lsp_status',
        icon = '',
        color = { fg = colors.purple0 },
        padding = { left = 1, right = 1 },
      },
      {
        'encoding',
        fmt = function(str)
          return str:upper()
        end,
        color = { fg = colors.blue1 },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_y = {
      {
        'progress',
        color = { fg = colors.green0, bg = colors.bg0 },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_z = {
      {
        'location',
        color = { fg = colors.yellow0, bg = colors.bg0 },
      },
    },
  },
}
