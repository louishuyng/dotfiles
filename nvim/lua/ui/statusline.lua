local icons = require('config.libs.icons')
local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
  return
end

-- Async language version loader (reads from asdf once at startup)
local function load_lang_versions()
  vim.g.lang_versions = vim.g.lang_versions or {}

  -- Map filetype to asdf plugin name
  local ft_to_asdf = {
    python = 'python',
    javascript = 'nodejs',
    typescript = 'nodejs',
    typescriptreact = 'nodejs',
    javascriptreact = 'nodejs',
    ruby = 'ruby',
    go = 'golang',
    rust = 'rust',
    lua = 'lua',
    java = 'java',
    elixir = 'elixir',
    kotlin = 'kotlin',
    php = 'php',
  }

  -- Read asdf current versions asynchronously
  vim.fn.jobstart('asdf current 2>/dev/null', {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then
        return
      end
      local versions = {}
      for _, line in ipairs(data) do
        -- Parse: "nodejs          20.10.0         /path/to/.tool-versions"
        local plugin, version = line:match('^(%S+)%s+(%S+)')
        if plugin and version and version ~= '' then
          -- Extract major.minor only
          local short_ver = version:match('^(%d+%.%d+)')
          if short_ver then
            versions[plugin] = short_ver
          end
        end
      end
      -- Map asdf plugin names to filetypes
      local lang_versions = {}
      for ft, asdf_name in pairs(ft_to_asdf) do
        if versions[asdf_name] then
          lang_versions[ft] = versions[asdf_name]
        end
      end
      vim.g.lang_versions = lang_versions
    end,
  })
end

-- Load versions once at startup
load_lang_versions()

-- Edge modeline colors
local function get_colors()
  local is_light = vim.o.background == 'light'

  if is_light then
    return {
      bg = '#eef1f4', -- mantle light
      fg = '#4b505b', -- text light
      fg_alt = '#7b828e', -- overlay0 light
      red = '#d05858',
      orange = '#be7e05',
      green = '#608e32',
      cyan = '#3a8b84',
      blue = '#5079be',
      magenta = '#b05ccc',
      yellow = '#be7e05',
    }
  end

  return {
    bg = '#33353f', -- mantle dark
    fg = '#c5cdd9', -- text dark
    fg_alt = '#9099a4', -- overlay0 dark
    red = '#ec7279',
    orange = '#deb974',
    green = '#a0c980',
    cyan = '#5dbbc1',
    blue = '#6cb6eb',
    magenta = '#d38aea',
    yellow = '#deb974',
  }
end

local colors = get_colors()

-- Minimal doom theme
local doom_theme = {
  normal = {
    a = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
    b = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
    c = { bg = colors.bg, fg = colors.fg_alt, gui = 'bold' },
  },
  insert = {
    a = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
  },
  visual = {
    a = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
  },
  replace = {
    a = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
  },
  command = {
    a = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
  },
  inactive = {
    a = { bg = colors.bg, fg = colors.fg_alt },
    b = { bg = colors.bg, fg = colors.fg_alt },
    c = { bg = colors.bg, fg = colors.fg_alt },
  },
}

-- Mode indicator with icons
local mode_component = {
  function()
    -- return '▌'
    return '|'
    -- return '● '
  end,
  color = function()
    if vim.bo.modified then
      return { fg = colors.orange, gui = 'bold' }
    elseif vim.bo.readonly or not vim.bo.modifiable then
      return { fg = colors.red, gui = 'bold' }
    end
    return { fg = colors.blue, gui = 'bold' }
  end,
  padding = { left = 0, right = 1 },
}

-- Mode indicator (just colored letter)
local mode_circle = {
  function()
    return '●'
    -- local mode_map = {
    --   n = '󰫻 ',
    --   i = ' ',
    --   v = '󱎤 ',
    --   V = '󱎤 ',
    --   ['\22'] = '󱎤 ',
    --   c = '󰫰 ',
    --   s = '󱎤 ',
    --   S = '󱎤 ',
    --   ['\19'] = '󱎤 ',
    --   R = '󰫿 ',
    --   r = '󰫿 ',
    --   ['!'] = '!',
    --   t = ' ',
    -- }
    -- return mode_map[vim.fn.mode()] or 'N'
  end,
  color = function()
    local mode_colors = {
      n = { fg = colors.green, gui = 'bold' },
      i = { fg = colors.blue, gui = 'bold' },
      v = { fg = colors.magenta, gui = 'bold' },
      V = { fg = colors.magenta, gui = 'bold' },
      ['\22'] = { fg = colors.magenta, gui = 'bold' },
      c = { fg = colors.yellow, gui = 'bold' },
      s = { fg = colors.orange, gui = 'bold' },
      S = { fg = colors.orange, gui = 'bold' },
      ['\19'] = { fg = colors.orange, gui = 'bold' },
      R = { fg = colors.red, gui = 'bold' },
      r = { fg = colors.red, gui = 'bold' },
      ['!'] = { fg = colors.red, gui = 'bold' },
      t = { fg = colors.cyan, gui = 'bold' },
    }
    return mode_colors[vim.fn.mode()] or { fg = colors.green, gui = 'bold' }
  end,
  padding = { left = 1, right = 0 },
}

-- Buffer size (like 3.5k in doom)
local buffer_size = {
  function()
    local lines = vim.api.nvim_buf_line_count(0)
    if lines >= 1000 then
      return string.format('%.1fk', lines / 1000)
    end
    return tostring(lines) .. 'L'
  end,
  color = { fg = colors.fg, gui = 'bold' },
  padding = { left = 1, right = 1 },
}

-- Position in file (Top/Bot/All/percentage)
local file_position = {
  function()
    local cur = vim.fn.line('.')
    local total = vim.fn.line('$')
    if cur == 1 then
      -- Arrow up icon
      return 'Top'
    elseif cur == total then
      return 'Bot'
    elseif total == vim.api.nvim_win_get_height(0) then
      return 'All'
    else
      return string.format('%.0f%%%%', (cur / total) * 100)
    end
  end,
  color = { fg = colors.fg_alt, gui = 'bold' },
  padding = { left = 1, right = 1 },
}

-- Lazy load marlin to avoid startup delay
local marlin_component = function()
  local ok, marlin = pcall(require, 'marlin')
  if not ok then
    return ''
  end
  local indexes = marlin.num_indexes()
  if indexes == 0 then
    return ''
  end
  local cur_index = marlin.cur_index()
  return ' ' .. cur_index .. '/' .. indexes
end

-- File icon component
local file_icon = {
  function()
    local filename = vim.fn.expand('%:t')
    local extension = vim.fn.expand('%:e')
    local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
    if devicons_ok then
      local icon = devicons.get_icon(filename, extension)
      if icon then
        return icon .. ' '
      end
    end
    return '󰈙 '
  end,
  color = function()
    local filename = vim.fn.expand('%:t')
    local extension = vim.fn.expand('%:e')
    local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
    if devicons_ok then
      local _, icon_color = devicons.get_icon_color(filename, extension)
      if icon_color then
        return { fg = icon_color, gui = 'bold' }
      end
    end
    return { fg = colors.cyan, gui = 'bold' }
  end,
  padding = { left = 1, right = 0 },
}

-- LSP status component
local lsp_status = {
  function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
      return ''
    end
    return '󰒋 ' .. #clients
  end,
  color = { fg = colors.fg_alt, gui = 'bold' },
  padding = { left = 1, right = 1 },
  cond = function()
    return #vim.lsp.get_clients({ bufnr = 0 }) > 0
  end,
  on_click = function()
    vim.cmd('LspInfo')
  end,
}

lualine.setup {
  options = {
    theme = doom_theme,
    globalstatus = true,
    disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'intro' } },
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = {
      mode_circle,
      buffer_size,
    },
    lualine_b = {
      file_icon,
      {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = '󰏫',
          readonly = '󰌾',
          unnamed = '󰡯',
          newfile = '󰝒',
        },
        color = { fg = colors.green, gui = 'bold' },
        padding = { left = 0, right = 1 },
      },
      {
        'marlin',
        fmt = marlin_component,
        color = { fg = colors.magenta, gui = 'bold' },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_c = {
      {
        'location',
        fmt = function()
          return 'Ln %l, Col %c'
        end,
        color = { fg = colors.fg_alt, gui = 'bold' },
        padding = { left = 1, right = 1 },
      },
      file_position,
    },
    lualine_x = {
      {
        -- Recording Macro
        function()
          local reg = vim.fn.reg_recording()
          return reg ~= '' and '@' .. reg or ''
        end,
        color = { fg = colors.red, gui = 'bold' },
        cond = function()
          return vim.fn.reg_recording() ~= ''
        end,
        padding = { left = 1, right = 1 },
      },
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
        diagnostics_color = {
          error = { fg = colors.red, gui = 'bold' },
          warn = { fg = colors.yellow, gui = 'bold' },
          info = { fg = colors.blue, gui = 'bold' },
          hint = { fg = colors.cyan, gui = 'bold' },
        },
        padding = { left = 1, right = 1 },
      },
      lsp_status,
    },
    lualine_y = {
      {
        -- Filetype with cached version from asdf
        function()
          local ft = vim.bo.filetype
          if ft == '' then
            return ''
          end
          local version = vim.g.lang_versions and vim.g.lang_versions[ft]
          if version then
            return ft .. ' ' .. version
          end
          return ft
        end,
        color = function()
          local ft = vim.bo.filetype
          local filename = vim.fn.expand('%:t')
          local extension = vim.fn.expand('%:e')
          local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
          if devicons_ok then
            local _, icon_color = devicons.get_icon_color(filename, extension)
            if not icon_color then
              _, icon_color = devicons.get_icon_color_by_filetype(ft)
            end
            if icon_color then
              return { fg = icon_color, gui = 'bold' }
            end
          end
          return { fg = colors.fg, gui = 'bold' }
        end,
        padding = { left = 1, right = 1 },
      },
      {
        'branch',
        icon = '󰘬',
        color = { fg = colors.magenta, gui = 'bold' },
        padding = { left = 1, right = 1 },
      },
      {
        'diff',
        symbols = {
          added = icons.git.added,
          modified = icons.git.modified,
          removed = icons.git.removed,
        },
        diff_color = {
          added = { fg = colors.green, gui = 'bold' },
          modified = { fg = colors.orange, gui = 'bold' },
          removed = { fg = colors.red, gui = 'bold' },
        },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {
      {
        function()
          return '▎'
        end,
        color = { fg = colors.fg_alt },
        padding = { left = 0, right = 0 },
      },
    },
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        path = 1,
        color = { fg = colors.fg_alt },
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}
