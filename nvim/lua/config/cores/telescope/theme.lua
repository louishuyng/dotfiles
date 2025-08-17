local dropdown_theme = function(title, previewer, ignore)
  previewer = previewer or false
  ignore = ignore or false

  return require('telescope.themes').get_dropdown({
    results_height = 20,
    winblend = 0,
    width = 0.8,
    prompt_title = '',
    prompt_prefix = title .. ' > ',
    selection_caret = ' ',
    hidden = true,
    no_ignore = ignore,
    previewer = previewer,
    preview_title = 'Preview',
    borderchars = {
      prompt = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' },
      results = { ' ', '▐', '▄', '▌', '▌', '▐', '▟', '▙' },
      preview = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' },
    },
    layout_config = {
      prompt_position = 'top',
      width = 0.5,
    },
    only_cwd = true,
  })
end

return {
  dropdown_theme = dropdown_theme,
}
