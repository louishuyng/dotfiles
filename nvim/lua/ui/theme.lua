if vim.g.main_theme == 'gruvbox' then
  vim.g.gruvbox_material_background = "hard"
  vim.cmd('colorscheme gruvbox-material')
end

if vim.g.main_theme == 'edge' then
  vim.g.edge_transparent_background = 1
  vim.g.edge_better_performance = 1

  vim.cmd('colorscheme edge')
end

if vim.g.main_theme == 'catppuccin' then
  require("catppuccin").setup {
    flavour = "mocha" -- latte, frappe, macchiato, mocha
  }

  vim.cmd('colorscheme catppuccin')
end

if vim.g.main_theme == 'dracula' then vim.cmd('colorscheme dracula') end
if vim.g.main_theme == 'dogrun' then vim.cmd('colorscheme dogrun') end
