local note = os.getenv("NVIM_NOTE")

if vim.g.dark_mode then
  vim.cmd([[
    set background=dark
    colorscheme catppuccin
  ]])
else
  vim.cmd([[
    set background=light
    colorscheme catppuccin
  ]])
end

if note == "true" then
  vim.g.dark_mode = "true"
  vim.cmd([[
    set background=dark
    colorscheme catppuccin
  ]])
end

vim.cmd([[
  hi DiagnosticSignError guifg=#ea6962
  hi DiagnosticSignWarn guifg=#d8a657
  hi DiagnosticSignInfo guifg=#89b482
  hi DiagnosticSignHint guifg=#89b482

  hi NvimTreeGitStaged guifg=#99cc99 guibg=NONE
  hi NvimTreeGitDirty guifg=#cc6666 guibg=NONE
]])
