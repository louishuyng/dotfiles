local chadtree_settings = {
  view = {
    width = 33
  },
  keymap = {
    change_focus = {"C"},
    change_focus_up = {"u"},
    toggle_follow = {"m"},
    v_split = {"s"},
    h_split = {"i"},
    open_sys = {"<enter>"},
    primary = {"o"},
    secondary = {"o"}, tertiary = {"t"},
    trash = {"T"},
    collapse = {"O", "`"},
    select = {"<tab>"},
    clear_selection = {"<s-tab>"},
    copy = {"c"} ,
  }
}
vim.api.nvim_set_var("chadtree_settings", chadtree_settings)
