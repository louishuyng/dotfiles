local has_telescope, telescope = pcall(require, 'telescope')
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

local M = {}

return function(opts)
  opts = opts or {}

  local entry_maker = function(entry)
    return {value = entry, display = entry, ordinal = entry}
  end

  local command = "tmux list-sessions | awk '{print $1}' | sed 's/://'"
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
    prompt_title = "Tmux Session",
    finder = finders.new_table {results = files},
    previewer = false,
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        vim.cmd("silent !tmux switch -t " .. selection[1])
      end)
      return true
    end
  }):find()
end
