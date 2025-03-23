local marlin = require("marlin")
marlin.setup({})

local mindex = 0
local generate_finder = function()
  mindex = 0
  return require("telescope.finders").new_table({
    results = require("marlin").get_indexes(),
    entry_maker = function(entry)
      mindex = mindex + 1
      return {
        value = entry,
        ordinal = mindex .. ":" .. entry.filename,
        lnum = entry.row,
        col = entry.col + 1,
        filename = entry.filename,
        display = mindex .. ":" .. entry.filename .. ":" .. entry.row .. ":" .. entry.col,
      }
    end,
  })
end

local keymap = vim.keymap.set

keymap("n", ";a", function() marlin.add() end, { desc = "add file" })
keymap("n", "]f", function() marlin.next() end, { desc = "open next index" })
keymap("n", "[f", function() marlin.prev() end, { desc = "open previous index" })
keymap("n", "<Leader><Leader>", function() marlin.toggle() end, { desc = "toggle cur/last open index" })

vim.keymap.set("n", "<C-e>", function()
  local conf = require("telescope.config").values
  local action_state = require("telescope.actions.state")

  require("telescope.pickers")
      .new({}, {
        prompt_title = "Marlin",
        finder = generate_finder(),
        previewer = conf.grep_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
          map("i", "<c-d>", function(bufnr)
            local current_picker = action_state.get_current_picker(bufnr)
            current_picker:delete_selection(function(selection)
              require("marlin").remove(selection.filename)
            end)
          end)
          map("i", "+", function(bufnr)
            local current_picker = action_state.get_current_picker(bufnr)
            local selection = current_picker:get_selection()
            require("marlin").move_up(selection.filename)
            current_picker:refresh(generate_finder(), {})
          end)
          map("i", "-", function(bufnr)
            local current_picker = action_state.get_current_picker(bufnr)
            local selection = current_picker:get_selection()
            require("marlin").move_down(selection.filename)
            current_picker:refresh(generate_finder(), {})
          end)
          return true
        end,
      })
      :find({ hidden = true })
end, { desc = "Telescope marlin" })
