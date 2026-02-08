local icons = require('config.libs.icons')
local bufferline = require('bufferline')

-- Get colors based on current theme
local function get_colors()
  local is_light = vim.o.background == 'light'

  if is_light then
    return {
      bg = '#eef1f4',
      fg = '#4b505b',
      fg_alt = '#9ca2ab',
      accent = '#5079be',
      modified = '#be7e05',
      error = '#d05858',
    }
  end

  return {
    bg = '#33353f',
    fg = '#c5cdd9',
    fg_alt = '#535965',
    accent = '#6cb6eb',
    modified = '#deb974',
    error = '#ec7279',
  }
end

local colors = get_colors()

bufferline.setup {
  options = {
    mode = 'tabs',
    numbers = 'none',
    close_command = 'bdelete! %d',
    right_mouse_command = 'bdelete! %d',
    left_mouse_command = 'buffer %d',
    middle_mouse_command = nil,
    indicator = {
      icon = '▎',
      style = 'icon',
    },
    buffer_close_icon = '󰅖',
    modified_icon = '󰏫',
    close_icon = '󰅖',
    left_trunc_marker = '󰁍',
    right_trunc_marker = '󰁔',
    max_name_length = 18,
    max_prefix_length = 15,
    tab_size = 18,
    diagnostics = 'nvim_lsp',
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level)
      local icon = level:match('error') and icons.diagnostics.Error or icons.diagnostics.Warn
      return ' ' .. icon .. count
    end,
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = false,
    show_tab_indicators = true,
    separator_style = 'thin',
    enforce_regular_tabs = false,
    always_show_bufferline = false,
    style_preset = {
      bufferline.style_preset.no_italic,
      bufferline.style_preset.no_bold,
    },
    themable = true,
    offsets = {
      {
        filetype = 'neo-tree',
        text = '󰙅 File Explorer',
        text_align = 'center',
        separator = true,
      },
      {
        filetype = 'NvimTree',
        text = '󰙅 File Explorer',
        text_align = 'center',
        separator = true,
      },
    },
    hover = {
      enabled = true,
      delay = 200,
      reveal = { 'close' },
    },
  },
  highlights = {
    fill = {
      bg = colors.bg,
    },
    background = {
      fg = colors.fg_alt,
      bg = colors.bg,
    },
    tab = {
      fg = colors.fg_alt,
      bg = colors.bg,
    },
    tab_selected = {
      fg = colors.accent,
      bg = colors.bg,
    },
    tab_separator = {
      fg = colors.bg,
      bg = colors.bg,
    },
    tab_separator_selected = {
      fg = colors.bg,
      bg = colors.bg,
    },
    buffer_visible = {
      fg = colors.fg_alt,
      bg = colors.bg,
    },
    buffer_selected = {
      fg = colors.fg,
      bg = colors.bg,
      bold = true,
    },
    close_button = {
      fg = colors.fg_alt,
      bg = colors.bg,
    },
    close_button_visible = {
      fg = colors.fg_alt,
      bg = colors.bg,
    },
    close_button_selected = {
      fg = colors.error,
      bg = colors.bg,
    },
    modified = {
      fg = colors.modified,
      bg = colors.bg,
    },
    modified_visible = {
      fg = colors.modified,
      bg = colors.bg,
    },
    modified_selected = {
      fg = colors.modified,
      bg = colors.bg,
    },
    separator = {
      fg = colors.bg,
      bg = colors.bg,
    },
    separator_visible = {
      fg = colors.bg,
      bg = colors.bg,
    },
    separator_selected = {
      fg = colors.bg,
      bg = colors.bg,
    },
    indicator_visible = {
      fg = colors.fg_alt,
      bg = colors.bg,
    },
    indicator_selected = {
      fg = colors.accent,
      bg = colors.bg,
    },
  },
}
