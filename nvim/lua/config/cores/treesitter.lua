local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then return end

ts_config.setup {
  ensure_installed = {
    "go", "graphql", "javascript", "jsdoc", "http", "json", "jsonc", "lua",
    "python", "ruby", "rust", "tsx", "typescript", "svelte", "kotlin", "yaml",
    "html", "toml", "vim", "fish", "bash", "markdown", "terraform", "smithy",
    "regex"
  },
  matchup = { enable = true },
  highlight = { enable = true },
  autotag = { enable = true },
  indent = { enable = true },
  context_commentstring = { enable = true }
}

local present2, treesitter_context = pcall(require, "treesitter-context")
if not present2 then return end

treesitter_context.setup {
  enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
  trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20,    -- The Z-index of the context window
  on_attach = nil -- (fun(buf: integer): boolean) return false to disable attaching
}

require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'go', 'lua', 'python', 'rust', 'typescript', 'regex', 'bash', 'markdown',
    'markdown_inline', 'kdl', 'sql', 'ruby'
  },

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-b>'
    }
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner'
      }
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = { [']f'] = '@function.outer',[']c'] = '@class.outer' },
      goto_next_end = { [']F'] = '@function.outer',[']C'] = '@class.outer' },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[c'] = '@class.outer'
      },
      goto_previous_end = { ['[F'] = '@function.outer',['[C'] = '@class.outer' }
    },
    swap = {
      enable = true,
      swap_next = { ['<leader>.'] = '@parameter.inner' },
      swap_previous = { ['<leader>,'] = '@parameter.inner' }
    }
  }
}
