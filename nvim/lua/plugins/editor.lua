return {
  { 'terryma/vim-multiple-cursors' }, -- Multi Cursor
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  { 'mbbill/undotree' },

  -- Git
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      -- Only one of these is needed.
      'nvim-telescope/telescope.nvim', -- optional
      'ibhagwan/fzf-lua', -- optional
    },
  },
  { 'lewis6991/gitsigns.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'akinsho/git-conflict.nvim', version = '*', config = true },
  {
    'polarmutex/git-worktree.nvim',
    version = '^2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local Hooks = require('git-worktree.hooks')
      local config = require('git-worktree.config')
      local update_on_switch = Hooks.builtins.update_current_buffer_on_switch

      Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
        vim.notify('Moved from ' .. prev_path .. ' to ' .. path)
        update_on_switch(path, prev_path)
      end)

      Hooks.register(Hooks.type.DELETE, function()
        vim.cmd(config.update_on_change_command)
      end)
    end,
  },

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {},
  },

  -- Refactoring
  -- {
  --   'ThePrimeagen/refactoring.nvim',
  --   config = function()
  --     require('refactoring').setup()
  --   end,
  -- },

  -- REST API
  { 'rest-nvim/rest.nvim', ft = 'http' },
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
  },

  -- Exploring Files
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = {},
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,

    config = function()
      require('oil').setup({
        keymaps = {
          ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
          ['<C-s>'] = { 'actions.select', opts = { horizontal = true } },
          ['<BS>'] = { 'actions.parent', mode = 'n' },
          ['q'] = { 'actions.close', mode = 'n' },
        },
      })

      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

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
    config = function()
      require('mini.bracketed').setup({})
    end,
  },
  {
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require('mini.surround').setup({})
    end,
  },
  {
    'echasnovski/mini.pairs',
    version = false,
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
