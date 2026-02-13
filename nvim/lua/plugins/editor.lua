return {
  { 'terryma/vim-multiple-cursors', lazy = false },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
  },
  { 'mbbill/undotree', cmd = 'UndotreeToggle' },

  -- Git
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      -- Only one of these is needed.
      'nvim-telescope/telescope.nvim', -- optional
      'ibhagwan/fzf-lua', -- optional
    },
  },
  { 'lewis6991/gitsigns.nvim', event = { 'BufReadPost', 'BufNewFile' }, dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'akinsho/git-conflict.nvim', version = '*', event = { 'BufReadPost', 'BufNewFile' }, config = true },
  -- {
  --   'polarmutex/git-worktree.nvim',
  --   version = '^2',
  --   cmd = { 'GitWorktreeSwitch', 'GitWorktreeCreate', 'GitWorktreeDelete' },
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  --   config = function()
  --     local Hooks = require('git-worktree.hooks')
  --     local config = require('git-worktree.config')
  --     local update_on_switch = Hooks.builtins.update_current_buffer_on_switch
  --
  --     Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
  --       vim.notify('Moved from ' .. prev_path .. ' to ' .. path)
  --       update_on_switch(path, prev_path)
  --     end)
  --
  --     Hooks.register(Hooks.type.DELETE, function()
  --       vim.cmd(config.update_on_change_command)
  --     end)
  --   end,
  -- },

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    opts = {},
  },

  -- Refactoring
  -- {
  --   'ThePrimeagen/refactoring.nvim',
  --   config = function()
  --     require('refactoring').setup()
  --   end,
  -- },

  -- Key map finding
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  -- Find matching words
  {
    'dyng/ctrlsf.vim',
    cmd = { 'CtrlSF', 'CtrlSFOpen', 'CtrlSFToggle' },
  },

  -- Exploring Files
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = {},
    -- Lazy load Oil on command
    cmd = 'Oil',
    keys = { { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' } },

    config = function()
      require('oil').setup({
        keymaps = {
          ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
          ['<C-s>'] = { 'actions.select', opts = { horizontal = true } },
          ['<BS>'] = { 'actions.parent', mode = 'n' },
          ['q'] = { 'actions.close', mode = 'n' },
        },
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'OilActionsPost',
        callback = function(event)
          if event.data.actions.type == 'move' then
            Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
          end
        end,
      })
    end,
  },

  -- MINI plugins
  {
    'echasnovski/mini.ai',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local spec_treesitter = require('mini.ai').gen_spec.treesitter
      require('mini.ai').setup({
        custom_textobjects = {
          f = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
          c = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
          o = spec_treesitter({
            a = { '@conditional.outer', '@loop.outer' },
            i = { '@conditional.inner', '@loop.inner' },
          }),
        },
      })
    end,
  },
  {
    'echasnovski/mini.bracketed',
    version = false,
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('mini.bracketed').setup({
        -- Avoid Conflicted with Marlin navigation
        file = { suffix = '', options = {} },
      })
    end,
  },
  {
    'echasnovski/mini.surround',
    version = false,
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('mini.surround').setup({})
    end,
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    event = 'InsertEnter',
    config = function()
      require('mini.pairs').setup({})
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    lazy = true,
    cmd = { 'Spectre' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
}
