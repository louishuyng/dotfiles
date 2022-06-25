require('litee.lib').setup()
require('litee.gh').setup({
  jump_mode = "invoking",
  map_resize_keys = true,
  disable_keymaps = false,
  icon_set = "nerd",
  git_buffer_completion = true,
  keymaps = {
    open = "<CR>",
    expand = "o",
    collapse = "u",
    goto_issue = "gd",
    details = "d",
    submit_comment = "<C-s>",
    actions = "<C-m>",
    resolve_thread = "<C-r>",
    goto_web = "gx"
  }
})
