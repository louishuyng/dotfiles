local present, bufferline = pcall(require, "bufferline")
local main_colors = require("ui.main_colors")
if not present then return end

bufferline.setup {
  highlights = {
    fill = {bg = main_colors.bg},
    background = {bg = main_colors.bg},
    tab = {bg = main_colors.bg},
    tab_selected = {
      bg = main_colors.selected_buffer_bg,
      fg = main_colors.selected_buffer_fg
    },
    tab_close = {bg = main_colors.bg},
    buffer_visible = {bg = main_colors.bg},
    buffer_selected = {
      fg = main_colors.selected_buffer_fg,
      bg = main_colors.selected_buffer_bg,
      bold = true,
      italic = false
    },
    numbers = {bg = main_colors.bg},
    numbers_visible = {bg = main_colors.bg},
    numbers_selected = {
      bg = main_colors.selected_buffer_bg,
      bold = true,
      italic = false
    },
    modified = {bg = main_colors.bg, fg = main_colors.red},
    modified_visible = {bg = main_colors.bg, fg = main_colors.red},
    modified_selected = {
      bg = main_colors.selected_buffer_bg,
      fg = main_colors.black_red
    },
    duplicate_selected = {
      fg = main_colors.selected_buffer_fg,
      bg = main_colors.selected_buffer_bg,
      italic = false
    },
    duplicate_visible = {bg = main_colors.bg, italic = false},
    duplicate = {bg = main_colors.bg, italic = false},
    separator_selected = {bg = main_colors.selected_buffer_bg},
    separator_visible = {bg = main_colors.bg},
    separator = {bg = main_colors.bg},
    indicator_selected = {bg = main_colors.selected_buffer_bg},
    pick_selected = {
      fg = main_colors.black_red,
      bg = main_colors.selected_buffer_bg,
      bold = true,
      italic = false
    },
    pick_visible = {
      fg = main_colors.red,
      bg = main_colors.bg,
      bold = true,
      italic = false
    },
    pick = {
      fg = main_colors.red,
      bg = main_colors.bg,
      bold = true,
      italic = false
    },
    offset_separator = {bg = main_colors.bg}
  },
  options = {
    show_close_icon = false,
    show_buffer_close_icons = false,
    show_buffer_icons = false,
    separator_style = {" ", " "},
    indicator = {
      icon = '', -- this should be omitted if indicator style is not 'icon'
      style = 'none'
    }
  }
}
