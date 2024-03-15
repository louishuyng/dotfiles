local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then return end

ts_config.setup {
  ensure_installed = {
    "go", "graphql", "javascript", "jsdoc", "http", "json", "jsonc", "lua",
    "python", "ruby", "rust", "tsx", "typescript", "svelte", "kotlin", "yaml",
    "html", "toml", "vim", "fish", "bash", "markdown", "terraform", "smithy",
    "regex", "markdown_inline", "vimdoc"
  },
  matchup = {enable = true},
  highlight = {enable = true},
  autotag = {enable = true},
  indent = {enable = true},
  context_commentstring = {enable = true}
}

require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'go', 'lua', 'python', 'rust', 'typescript', 'regex', 'bash', 'markdown',
    'markdown_inline', 'kdl', 'sql', 'ruby'
  },

  highlight = {enable = true},
  indent = {enable = true},
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
      goto_next_start = {[']f'] = '@function.outer', [']c'] = '@class.outer'},
      goto_next_end = {[']F'] = '@function.outer', [']C'] = '@class.outer'},
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[c'] = '@class.outer'
      },
      goto_previous_end = {['[F'] = '@function.outer', ['[C'] = '@class.outer'}
    },
    swap = {
      enable = true,
      swap_next = {['<leader>.'] = '@parameter.inner'},
      swap_previous = {['<leader>,'] = '@parameter.inner'}
    }
  }
}
