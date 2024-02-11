local has_telescope, telescope = pcall(require, 'telescope')
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require('telescope.previewers')

if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

local M = {}

return function(opts)
  opts = opts or {}

  local command = "notes ls"
  local handle = io.popen(command)

  if (handle == nil) then
    print('could not run specified command:' .. command)
    return
  end

  local result = handle:read("*a")

  handle:close()

  local files = {}

  for token in string.gmatch(result, "[^%c]+") do
    -- Path will be ~/notes/${token}
    local format = string.format("~/notes/%s", token)

    table.insert(files, format)
  end

  pickers.new(opts, {
    debounce = 100,
    prompt_title = "Engineer Note",
    finder = finders.new_table {results = files},
    previewer = previewers.cat.new(opts),
    sorter = conf.generic_sorter(opts)
  }):find()
end
