local ascii_heatmap = require('git-dashboard-nvim').setup {
  show_only_weeks_with_commits = true,
  title = 'owner_with_repo_name',
}


local opts = {
  theme = 'doom',
  config = {
    header = ascii_heatmap,
    center = {
      { action = '', desc = '', icon = '', key = 'n' },
    },
    footer = function()
      return {}
    end,
 },
}


local dashboard = require 'alpha.themes.dashboard'
local git_dashboard = require('git-dashboard-nvim').setup(opts)

dashboard.section.header.val = git_dashboard
dashboard.section.buttons.val = {}

require('alpha').setup(dashboard.opts)
