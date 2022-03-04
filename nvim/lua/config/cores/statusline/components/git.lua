local colors = require 'ui.statusline_colors'

local git = {
  branch = {
    provider = 'git_branch',
    icon = ' ',
    -- icon = ' ',
    left_sep = ' ',
    hl = {
      fg = colors.violet,
      style = 'bold'
    },
  },
  add = {
    provider = 'git_diff_added',
    hl = {
      fg = colors.green
    }
  },
  change = {
    provider = 'git_diff_changed',
    hl = {
      fg = colors.orange
    }
  },
  remove = {
    provider = 'git_diff_removed',
    hl = {
      fg = colors.red
    }
  }
}

return git
