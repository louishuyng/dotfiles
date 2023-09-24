local git_blame = require('gitblame')

-- This disables showing of the blame text next to the cursor
vim.g.gitblame_display_virtual_text = 0

require('lualine').setup {
  options = {component_separators = '', section_separators = ''},
  -- Show git blame info in the status line
  sections = {
    lualine_c = {
      {
        git_blame.get_current_blame_text,
        cond = git_blame.is_blame_text_available
      }
    },
    lualine_x = {'filetype'}
  }
}
