local present, indent = pcall(require, "indent_blankline")

if not (present) then
    return
end

indent.setup {
  show_end_of_line = true,
}

