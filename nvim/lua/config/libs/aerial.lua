local status_ok, aerial = pcall(require, "aerial")
if status_ok then
  aerial.setup({
    close_behavior = "global",
    backends = {"lsp", "treesitter", "markdown"},
    show_guides = true,
    filter_kind = false,
    open_automatic = false,
    icons = {
      Array = "",
      Boolean = "⊨",
      Class = "",
      Constant = "",
      Constructor = "",
      Key = "",
      Function = "",
      Method = "ƒ",
      Namespace = "",
      Null = "NULL",
      Number = "#",
      Object = "⦿",
      Property = "",
      TypeParameter = "𝙏",
      Variable = "",
      Enum = "ℰ",
      Package = "",
      EnumMember = "",
      File = "",
      Module = "",
      Field = "",
      Interface = "ﰮ",
      String = "𝓐",
      Struct = "𝓢",
      Event = "",
      Operator = "+"
    },
    guides = {
      mid_item = "├ ",
      last_item = "└ ",
      nested_top = "│ ",
      whitespace = "  "
    }
  })
end
