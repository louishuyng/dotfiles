require('nvim-nonicons').setup {}

require('nvim-web-devicons').set_icon {
  ["tf"] = {
    icon = vim.fn.nr2char("61972"),
    color = "#5F43E9",
    cterm_color = "93",
    name = "Terraform"
  }
}
