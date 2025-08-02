local present, ts_config = pcall(require, 'nvim-treesitter.configs')
if not present then
  return
end

local context = require 'treesitter-context'

require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'go',
    'graphql',
    'javascript',
    'jsdoc',
    'http',
    'json',
    'jsonc',
    'lua',
    'python',
    'ruby',
    'rust',
    'tsx',
    'typescript',
    'svelte',
    'kotlin',
    'yaml',
    'html',
    'toml',
    'vim',
    'fish',
    'bash',
    'markdown',
    'terraform',
    'smithy',
    'regex',
    'markdown_inline',
    'vimdoc',
    'xml',
    'ocaml',
    'zig',
    'gleam',
    'kdl',
    'sql',
  },
  matchup = { enable = true },
  autotag = { enable = true },
  context_commentstring = { enable = true },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },
}

context.setup {
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  multiwindow = false, -- Enable multiwindow support.
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}

vim.keymap.set('n', '[[', function()
  context.go_to_context(vim.v.count1)
end, { silent = true, desc = 'Go to parent context' })
