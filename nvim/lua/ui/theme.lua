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
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    no_italic = true,
    integrations = {hop = true, notify = true, treesitter_context = true},
    term_colors = true,
    transparent_background = false,
    color_overrides = {
      mocha = {
        rosewater = "#ffc9c9",
        flamingo = "#deb974",
        pink = "#f2a7de",
        mauve = "#b889f4",
        red = "#ff5555",
        maroon = "#CE747D",
        peach = "#f39967",
        yellow = "#eaca89",
        green = "#96d382",
        teal = "#78cec1",
        sky = "#91d7e3",
        sapphire = "#68bae0",
        blue = "#739df2",
        lavender = "#a0a8f6",
        text = "#c5cdd9",
        subtext1 = "#a6b0d8",
        subtext0 = "#959ec2",
        overlay2 = "#848cad",
        overlay1 = "#717997",
        overlay0 = "#63677f",
        surface2 = "#505469",
        surface1 = "#3e4255",
        surface0 = "#2A2B3B",
        base = "#000000",
        mantle = "#000000",
        crust = "#000000"
      }
    }
  }

  vim.cmd('colorscheme catppuccin')
end

if vim.g.main_theme == 'dracula' then vim.cmd('colorscheme dracula') end
if vim.g.main_theme == 'dogrun' then vim.cmd('colorscheme dogrun') end
if vim.g.main_theme == 'tokyonight' then vim.cmd('colorscheme tokyonight') end
if vim.g.main_theme == 'vscode' then
  require('vscode').setup({transparent = true})
  require('vscode').load()
end

if vim.g.main_theme == 'linux' then vim.cmd('colorscheme koehler') end
