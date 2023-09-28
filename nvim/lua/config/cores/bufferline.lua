local present, bufferline = pcall(require, "bufferline")

local main_colors = require("ui.main_colors")[vim.g.main_theme]

if not present then return end

bufferline.setup {
  highlights = {
    fill = {bg = main_colors.bg},
    background = {bg = main_colors.bg},
    buffer_visible = {bg = main_colors.bg},
    buffer_selected = {
      fg = main_colors.selected_buffer_fg,
      bg = main_colors.selected_buffer_bg
    },
    tab = {bg = main_colors.selected_buffer_bg},
    tab_selected = {bg = main_colors.selected_tab_bg, fg = main_colors.black},
    tab_separator = {
      bg = main_colors.selected_buffer_bg,
      fg = main_colors.selected_buffer_bg
    },
    tab_separator_selected = {
      bg = main_colors.selected_buffer_bg,
      fg = main_colors.selected_buffer_bg
    },
    numbers = {bg = main_colors.bg},
    numbers_visible = {bg = main_colors.bg},
    numbers_selected = {bg = main_colors.selected_buffer_bg},
    modified = {bg = main_colors.bg, fg = main_colors.red},
    modified_visible = {bg = main_colors.bg, fg = main_colors.red},
    modified_selected = {
      bg = main_colors.selected_buffer_bg,
      fg = main_colors.black_red
    },
    duplicate_selected = {
      fg = main_colors.selected_buffer_fg,
      bg = main_colors.selected_buffer_bg
    },
    duplicate_visible = {bg = main_colors.bg, italic = true},
    duplicate = {bg = main_colors.bg, italic = true},
    separator_selected = {bg = main_colors.selected_buffer_bg},
    separator_visible = {bg = main_colors.bg},
    separator = {bg = main_colors.bg},
    indicator_selected = {bg = main_colors.selected_buffer_bg},
    pick_selected = {
      fg = main_colors.black_red,
      bg = main_colors.selected_buffer_bg
    },
    pick_visible = {fg = main_colors.red, bg = main_colors.bg},
    pick = {fg = main_colors.red, bg = main_colors.bg},
    offset_separator = {bg = main_colors.bg}
  },
  options = {
    style_preset = {
      bufferline.style_preset.no_italic,
      bufferline.style_preset.no_bold,
      style_preset = bufferline.style_preset.minimal
    },
    diagnostics = "nvim_lsp",
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left"
      }
    },
    show_close_icon = false,
    show_buffer_close_icons = false,
    separator_style = {"", ""},
    indicator = {
      icon = '', -- this should be omitted if indicator style is not 'icon'
      style = 'none'
    },
    custom_filter = function(buf_number, buf_numbers)
      if vim.bo[buf_number].filetype ~= 'fugitive' then return true end

      return false
    end
  }
}
