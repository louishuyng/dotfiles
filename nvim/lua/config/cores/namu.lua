require("namu").setup({
  -- Enable the modules you want
  namu_symbols = {
    enable = true,
    options = {
      AllowKinds = {
        default = {
          "Function",
          "Method",
          "Class",
          "Enum",
          "Interface",
          "Field",
          "Struct",
        },
        go = {
          "Function",
          "Method",
          "Struct", -- For struct definitions
          "Field",  -- For struct fields
          "Interface",
          "Constant",
          -- "Variable",
          "Property",
          -- "TypeParameter", -- For type parameters if using generics
        },
        lua = { "Function", "Method", "Table", "Module" },
        python = { "Function", "Class", "Method" },
        -- Filetype specific
        yaml = { "Object", "Array" },
        json = { "Module" },
        toml = { "Object" },
        markdown = { "String" },
      },
      movement = {
        next = { "<C-j>", "<DOWN>" },   -- Support multiple keys
        previous = { "<C-k>", "<UP>" }, -- Support multiple keys
        close = { "<ESC>" },            -- close mapping
        select = { "<CR>" },            -- select mapping
        delete_word = {},               -- delete word mapping
        clear_line = {},                -- clear line mapping
      },
      multiselect = {
        enabled = true,
        indicator = "●", -- or "✓"◉
        keymaps = {
          toggle = "<Tab>",
          select_all = "<C-g>",
          clear_all = "<C-r>",
          untoggle = "<S-Tab>",
        },
        max_items = nil, -- No limit by default
      },
      custom_keymaps = {
        yank = {
          keys = { "<C-y>" }, -- yank symbol text
        },
        delete = {
          keys = { "<C-d>" }, -- delete symbol text
        },
        vertical_split = {
          keys = { "<C-v>" }, -- open in vertical split
        },
        horizontal_split = {
          keys = { "<C-s>" }, -- open in horizontal split
        },
        codecompanion = {
          keys = "<C-a>", -- Add symbols to CodeCompanion
        },
      },
    }, -- here you can configure namu
  },
  -- Optional: Enable other modules if needed
  ui_select = { enable = true }, -- vim.ui.select() wrapper

  highlight = "NamuPreview",
})

vim.keymap.set("n", ";s", ":Namu symbols<cr>", {
  desc = "Jump to LSP symbol",
  silent = true,
})
vim.api.nvim_set_hl(0, 'NamuPreview', { bg = 'red', fg = '#ebdbb2', bold = true }) -- Adjust colors as needed
vim.api.nvim_set_hl(0, 'NamuParent', { fg = '#fabd2f', bold = true })
vim.api.nvim_set_hl(0, 'NamuNested', { fg = '#83a598' })
vim.api.nvim_set_hl(0, 'NamuStyle', { fg = '#d3869b', italic = true })

vim.api.nvim_set_hl(0, 'NamuPrefixSymbol', { fg = '#d65d0e' })
vim.api.nvim_set_hl(0, 'NamuSymbolFunction', { fg = '#8ec07c' })
