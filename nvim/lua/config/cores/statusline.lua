require('lualine').setup {
  options = {component_separators = '', section_separators = ''},

  -- Show git blame info in the status line
  sections = {lualine_c = {}}
}
