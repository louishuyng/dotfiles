local dropdown_theme = function(title, previewer, ignore)
  previewer = previewer or false
  ignore = ignore or false

  return require('telescope.themes').get_ivy({
    winblend = 0,
    prompt_title = '',
    prompt_prefix = title .. ': ',
    selection_caret = '  ',
    hidden = true,
    no_ignore = ignore,
    previewer = previewer,
    preview_title = 'Preview',
    results_title = ' ',
    layout_config = {
      height = 18,
    },
    only_cwd = true,
    sorting_strategy = 'ascending',
    file_ignore_patterns = { '%.git/', 'node_modules/', '__pycache__/', '%.o$', '%.class$' },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--glob=!.git/',
    },
  })
end

local cursor_theme = function(title, previewer, ignore)
  previewer = previewer or false
  ignore = ignore or false

  return require('telescope.themes').get_cursor({
    winblend = 0,
    prompt_title = false,
    prompt_prefix = '  ',
    selection_caret = ' ',
    entry_prefix = '',
    hidden = true,
    no_ignore = ignore,
    previewer = false,
    results_title = false,
    borderchars = {
      prompt = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
      results = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    },
    layout_config = {
      width = 0.5,
      height = 0.4,
    },
    color_devicons = false,
    path_display = { 'tail' },
    sorting_strategy = 'ascending',
    only_cwd = true,
    file_ignore_patterns = { '%.git/', 'node_modules/', '__pycache__/', '%.o$', '%.class$' },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--glob=!.git/',
    },
  })
end

return {
  dropdown_theme = dropdown_theme,
  cursor_theme = cursor_theme,
}
