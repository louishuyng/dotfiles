return {
  -- Smooth cursor animation
  {
    'gen740/SmoothCursor.nvim',
    enabled = true,
    event = 'VeryLazy',
    opts = {
      type = 'default',
      cursor = '▷',
      texthl = 'SmoothCursor',
      fancy = {
        enable = true,
        head = { cursor = '▷', texthl = 'SmoothCursor' },
        body = {
          { cursor = '●', texthl = 'SmoothCursorBody' },
          { cursor = '●', texthl = 'SmoothCursorBody' },
          { cursor = '•', texthl = 'SmoothCursorBody' },
          { cursor = '.', texthl = 'SmoothCursorBody' },
        },
      },
      speed = 25,
      intervals = 35,
      threshold = 3,
      disabled_filetypes = { 'alpha', 'neo-tree', 'oil', 'lazy', 'mason' },
    },
  },
  {
    'LazyVim/LazyVim',
    lazy = false,
    priority = 1000,
  },
  { 'folke/snacks.nvim', lazy = false, priority = 1000 },
  {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },
  {
    'akinsho/nvim-bufferline.lua',
    event = 'VeryLazy',
    enabled = false,
  },
  -- { 'b0o/incline.nvim' },
  {
    'DaikyXendo/nvim-material-icon',
    lazy = false,
    priority = 999,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local web_devicons_ok, web_devicons = pcall(require, 'nvim-web-devicons')
      if not web_devicons_ok then
        return
      end

      local material_icon_ok, material_icon = pcall(require, 'nvim-material-icon')
      if not material_icon_ok then
        return
      end

      material_icon.setup({
        override = {},
        color_icons = true,
        default = true,
        strict = true,
        override_by_filename = {},
        override_by_extension = {},
      })

      web_devicons.setup({
        override = material_icon.get_icons(),
        color_icons = true,
        default = true,
      })
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
  },
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    config = function()
      require('smart-splits').setup({
        resize_mode = {
          hooks = {
            on_enter = function()
              vim.notify('Entering resize mode...', vim.log.levels.INFO)
            end,
            on_leave = function()
              vim.notify('Exiting resize mode', vim.log.levels.INFO)
            end,
          },
        },
      })
    end,
  },
  -- Color highlighter
  {
    'norcalli/nvim-colorizer.lua',
    event = 'BufReadPre',
    config = function()
      require('colorizer').setup({
        '*',
        css = { css = true },
        scss = { css = true },
      }, {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = 'background',
      })
    end,
  },
  -- Beautiful notifications
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>un',
        function()
          require('notify').dismiss({ silent = true, pending = true })
        end,
        desc = 'Dismiss all Notifications',
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      stages = 'fade_in_slide_out',
      render = 'wrapped-compact',
      background_colour = '#1e222a',
      fps = 60,
      icons = {
        ERROR = '󰅚 ',
        WARN = '󰀪 ',
        INFO = '󰋽 ',
        DEBUG = '󰃤 ',
        TRACE = '󰏫 ',
      },
      level = 2,
      minimum_width = 50,
      top_down = false,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    config = function(_, opts)
      require('notify').setup(opts)
      vim.notify = require('notify')
    end,
  },
  -- Startup dashboard with anime theme
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    opts = function()
      local dashboard = require('alpha.themes.dashboard')

      local dashboard_art = require('ui.dashboard_art')
      local logo = dashboard_art.kawaii

      dashboard.section.header.val = vim.split(logo, '\n')

      -- Styling
      dashboard.section.header.opts.hl = 'AlphaHeader'
      dashboard.section.footer.opts.hl = 'AlphaFooter'

      -- Layout with better centering
      dashboard.opts.layout = {
        { type = 'padding', val = 15 },
        dashboard.section.header,
        { type = 'padding', val = 2 },
        dashboard.section.footer,
      }

      dashboard.opts.opts = {
        margin = 5,
        noautocmd = true,
      }

      return dashboard
    end,
    config = function(_, dashboard)
      -- Close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'AlphaReady',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      require('alpha').setup(dashboard.opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local opts = dashboard.opts
          -- Update footer with fresh stats
          local lazy_ok, lazy = pcall(require, 'lazy')
          if lazy_ok then
            local stats = lazy.stats()
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
            local version = vim.version()
            local nvim_version = string.format('v%d.%d.%d', version.major, version.minor, version.patch)
            local os_name = vim.loop.os_uname().sysname
            local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
            local datetime = os.date('%Y-%m-%d  %H:%M:%S')
            local hour = tonumber(os.date('%H'))
            local greeting = hour < 6 and '🌙 Good night'
              or hour < 12 and '🌅 Good morning'
              or hour < 18 and '☀️  Good afternoon'
              or '🌆 Good evening'

            opts.layout[4].val = {
              '',
              greeting .. ', Louis!',
              '',
              '',
              '',
              ' Startup: ' .. string.format('%-15s', ms .. ' ms'),
              '',
              ' Plugins: ' .. string.format('%-15s', stats.loaded .. '/' .. stats.count),
              '',
              ' NeoVim: ' .. string.format('%-15s', nvim_version),
              '',
              ' System: ' .. string.format('%-15s', os_name),
              '',
              '',
              ' Workspace: ' .. string.format('%-26s', cwd:sub(1, 26)),
              '',
            }
          end
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
