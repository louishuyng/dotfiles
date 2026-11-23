vim.lsp.config('zls', {
  settings = {
    zls = {
      enable_inlay_hints = true,
      inlay_hints_show_parameter_name = true,
      inlay_hints_show_builtin = true,
      inlay_hints_show_variable_type_hints = true,
      warn_style = true,
      highlight_global_var_declarations = true,
    },
  },
})

vim.lsp.enable('zls')
