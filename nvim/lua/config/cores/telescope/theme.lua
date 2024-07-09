local dropdown_theme = function(title)
  return require('telescope.themes').get_dropdown({
    results_height = 20,
    winblend = 0,
    width = 0.8,
    prompt_title = '',
    prompt_prefix = title .. ' > ',
    hidden = true,
    previewer = false,
    preview_title = '',
    borderchars = {
      prompt = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' },
      results = { ' ', '▐', '▄', '▌', '▌', '▐', '▟', '▙' },
      preview = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' },
    },
    layout_config = {
      prompt_position = "top",
      width = 0.5,
    },
  })
end

return {
  dropdown_theme = dropdown_theme
}
