local present, trouble = pcall(require, "trouble")

if not (present) then
    return
end

trouble.setup({
  position = "bottom",
  height = 10,
  width = 50,
  icons = true,
  mode = "lsp_workspace_diagnostics",
  fold_open = "",
  fold_closed = "",
  action_keys = {
    close = "q",
    cancel = "<esc>",
    refresh = "r",
    jump = {"<cr>", "<tab>"},
    open_split = { "i" },
    open_vsplit = { "s" },
    open_tab = { "<c-t>" },
    jump_close = {"o"},
    toggle_mode = "m",
    toggle_preview = "P",
    hover = "K",
    preview = "p",
    close_folds = {"zM", "zm", "zc"},
    open_folds = {"zR", "zr", "zo"},
    toggle_fold = {"zA", "za"},
    previous = "k",
    next = "j"
  },
  indent_lines = true,
  auto_open = false,
  auto_close = false,
  auto_preview = true,
  auto_fold = false,
  signs = {
    error = "",
    warning = "",
    hint = "",
    information = "",
    other = "﫠"
  },
  use_lsp_diagnostic_signs = false
})
