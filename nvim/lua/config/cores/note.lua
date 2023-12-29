require("obsidian").setup({
  workspaces = {{name = "notes", path = "~/Dev/Obsidian/LouisDev/notes"}},
  daily_notes = {
    folder = "dailies",
    date_format = "%Y-%m-%d",
    alias_format = "%B %-d, %Y",
    template = nil
  },
  completion = {
    nvim_cmp = true,
    min_chars = 2,
    new_notes_location = "current_dir",
    prepend_note_id = true,
    prepend_note_path = false,
    use_path_only = false
  },
  mappings = {
    -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
    ["gf"] = {
      action = function() return require("obsidian").util.gf_passthrough() end,
      opts = {noremap = false, expr = true, buffer = true}
    },
    -- Toggle check-boxes.
    ["<leader>ch"] = {
      action = function() return require("obsidian").util.toggle_checkbox() end,
      opts = {buffer = true}
    }
  },
  templates = {
    subdir = "my-templates",
    date_format = "%Y-%m-%d-%a",
    time_format = "%H:%M"
  },
  finder = "telescope.nvim",
  open_notes_in = "vsplit"
})
