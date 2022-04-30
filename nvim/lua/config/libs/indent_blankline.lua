local present, indent = pcall(require, "indent_blankline")

if not (present) then
    return
end

indent.setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
}

