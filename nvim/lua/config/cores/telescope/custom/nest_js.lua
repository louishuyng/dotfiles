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

local mappingsSearchFor = {
  c = 'controller',
  d = 'dto',
  e = 'entity',
  m = 'mapper',
  s = 'spec',
  mo = 'module'
}

return function(opts)
  opts = opts or {}
  local search = opts.search or ''

  local command = 'fd  --glob "*.{pattern}.ts"'

  -- Replace search with the actual search term
  -- match the search term with the mappingsSearchFor
  for key, value in pairs(mappingsSearchFor) do
    if (search == key) then search = value end
  end
  command = string.gsub(command, "{pattern}", search)

  local handle = io.popen(command)

  if (handle == nil) then
    print('could not run specified command:' .. command)
    return
  end

  local result = handle:read("*a")
  handle:close()

  local files = {}

  for token in string.gmatch(result, "[^%c]+") do table.insert(files, token) end

  pickers.new(opts, {
    debounce = 100,
    prompt_title = "Nest js > " .. search,
    finder = finders.new_table { results = files },
    previewer = previewers.cat.new(opts),
    sorter = conf.generic_sorter(opts)
  }):find()
end
