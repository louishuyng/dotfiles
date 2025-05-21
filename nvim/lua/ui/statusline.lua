local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
  return
end

local lualine_require = require('lualine_require')
lualine_require.require = require

local icons = require('config.libs.icons')

local Util = require('lazyvim.util')

vim.o.laststatus = vim.g.lualine_laststatus

local colors = {}

local flavour = vim.g.theme == 'night' and vim.g.default_dark_catppuccin_theme or 'latte'

local C = require('catppuccin.palettes').get_palette(flavour)

local colors = {
  bg0 = C.mantle,
  bg1 = C.base,
  bg2 = C.surface0,
  fg0 = C.text,
  fg1 = C.subtext0,
  fg2 = C.subtext1,
  red0 = C.red,
  red1 = C.red,
  yellow0 = C.yellow,
  yellow1 = C.yellow,
  green0 = C.green,
  green1 = C.green,
  blue1 = C.blue,
  purple0 = C.mauve,
  purple1 = C.mauve,
}

local theme = {
  normal = {
    a = { bg = colors.bg0, fg = colors.purple0 },
    b = { bg = colors.bg0, fg = colors.yellow0 },
    c = { bg = colors.bg0, fg = colors.fg2 },
  },
  insert = {
    a = { bg = colors.bg0, fg = colors.green0 },
    b = { bg = colors.bg0, fg = colors.green1 },
  },
  command = {
    a = { bg = colors.bg0, fg = colors.yellow0 },
    b = { bg = colors.bg0, fg = colors.yellow1 },
  },
  visual = {
    a = { bg = colors.bg0, fg = colors.blue1 },
    b = { bg = colors.bg0, fg = colors.blue1 },
  },
  replace = {
    a = { bg = colors.bg0, fg = colors.red0 },
    b = { bg = colors.bg0, fg = colors.red1 },
  },
  inactive = {
    a = { bg = colors.bg0, fg = colors.blue1 },
    b = { bg = colors.bg0, fg = colors.bg0 },
    c = { bg = colors.bg0, fg = colors.bg1 },
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
    component_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(mode)
          -- Vertical bar symbol
          return '▐'
        end,
        padding = { left = 0, right = 0 },
      },
      {
        'filesize',
        color = { fg = colors.fg2 },
      },
      -- {
      --   'filename',
      --   file_status = true, -- Displays file status (readonly status, modified status)
      --   newfile_status = false,
      --   path = 4, -- 0: Just the filename
      --
      --   shorting_target = 40, -- Shortens path to leave 40 spaces in the window
      --   symbols = {
      --     modified = '[+]',
      --     readonly = '[-]',
      --     unnamed = '[No Name]',
      --     newfile = '[New]',
      --   },
      --   color = { fg = colors.yellow1 },
      -- },
      {
        'location',
        color = { fg = colors.fg2 },
      },
    },
    lualine_b = {
      {
        'marlin',
        fmt = marlin_component,
        color = { fg = colors.purple0 },
      },
    },

    lualine_c = {
      Util.lualine.root_dir(),
      {
        'diff',
        symbols = {
          added = '+',
          modified = '~',
          removed = '-',
        },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
    },
    lualine_x = {
      -- stylua: ignore
      {
        function() return require("noice").api.status.mode.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        color = { fg = Snacks.util.color("Constant") }
      },
      {
        'encoding',
      },
      {
        'branch',
        icon = '',
        color = { fg = colors.green0 },
      },
      {
        function()
          return '  ' .. require('dap').status()
        end,
        cond = function()
          return package.loaded['dap'] and require('dap').status() ~= ''
        end,
        color = { fg = Snacks.util.color('Debug') },
      },
    },
    lualine_y = {},
    lualine_z = {},
  },
}
