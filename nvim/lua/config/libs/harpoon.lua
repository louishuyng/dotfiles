local present, harpoon = pcall(require, "harpoon")

if not (present) then return end

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)

local conf = require('telescope.config').values

local make_finder = function(harpoon_files)
  local paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(paths, item.value)
  end

  return require('telescope.finders').new_table {
    results = paths,
  }
end

local function toggle_telescope(harpoon_files)
  require('telescope.pickers')
      .new({}, {
        prompt_title = 'Harpoon',
        finder = make_finder(harpoon_files),
        previewer = conf.file_previewer {},
        sorter = conf.generic_sorter {},
        attach_mappings = function(bufnr, map)
          map('i', '<C-d>', function()
            local state = require 'telescope.actions.state'
            local selected_query = state.get_selected_entry()
            local current_picker = state.get_current_picker(bufnr)
            harpoon:list():remove_at(selected_query.index)
            current_picker:refresh(make_finder(harpoon:list()))
          end)

          return true
        end,
      })
      :find()
end
vim.keymap.set('n', '<C-e>', function()
  toggle_telescope(harpoon:list())
end, { desc = 'Open harpoon window' })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "m{", function() harpoon:list():prev() end)
vim.keymap.set("n", "m}", function() harpoon:list():next() end)


harpoon:extend({
  UI_CREATE = function(cx)
    vim.keymap.set("n", "v",
      function() harpoon.ui:select_menu_item({ vsplit = true }) end,
      { buffer = cx.bufnr })

    vim.keymap.set("n", "s",
      function() harpoon.ui:select_menu_item({ split = true }) end,
      { buffer = cx.bufnr })

    vim.keymap.set("n", "<C-t>", function()
      harpoon.ui:select_menu_item({ tabedit = true })
    end, { buffer = cx.bufnr })
  end
})
