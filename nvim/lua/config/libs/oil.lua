local present, oil = pcall(require, "oil")

if not (present) then return end

oil.setup({
  keymaps = {
    ["g?"] = "actions.show_help",
    ["l"] = "actions.select",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-s>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["q"] = "actions.close",
    ["<S-r>"] = "actions.refresh",
    ["h"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["."] = "actions.toggle_hidden"
  },
  use_default_keymaps = false
})
