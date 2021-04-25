require'bufferline'.setup{
  options = {
    view = "multiwindow",
    numbers = "buffer_id",
    mappings = true,
    buffer_close_icon= '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 15,
    max_prefix_length = 15, -- prefix used when a buffer is deduplicated
    tab_size = 18,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    persist_buffer_sort = false,
    separator_style = "thin",
    always_show_bufferline = true,
  },
  highlights = {
    buffer_selected = {
        guifg = normal_fg,
        guibg = "#3A3E44",
        gui = "bold"
    },
    separator_visible = {
        guifg = "#282c34",
        guibg = "#282c34"
    },
    indicator_selected = {
        guifg = "#282c34",
        guibg = "#282c34"
    },
    modified_selected = {
        guifg = string_fg,
        guibg = "#3A3E44"
    },
    tab_selected = {
      guifg = tabline_sel_bg,
      uibg = "#3A3E44",
      gui = "bold",
    },
  }
}
