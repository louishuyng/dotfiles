local colors = require 'ui.statusline_colors'

local diagnos  = require 'config.cores.statusline.components.diagnos';
local file  = require 'config.cores.statusline.components.file';
local git  = require 'config.cores.statusline.components.git';
local lsp  = require 'config.cores.statusline.components.lsp';
local package_info  = require 'config.cores.statusline.components.package_info';
local utils  = require 'config.cores.statusline.components.utils';
local vi_mode  = require 'config.cores.statusline.components.vi_mode';

local components = {
  active = {},
  inactive = {},
}

table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.inactive, {})
table.insert(components.inactive, {})
table.insert(components.inactive, {})

table.insert(components.active[1], vi_mode.left)
table.insert(components.active[1], file.info)
table.insert(components.active[1], git.add)
table.insert(components.active[1], git.change)
table.insert(components.active[1], git.remove)
table.insert(components.inactive[1], vi_mode.left)
table.insert(components.inactive[1], file.info)
table.insert(components.active[3], diagnos.err)
table.insert(components.active[3], diagnos.warn)
table.insert(components.active[3], diagnos.hint)
table.insert(components.active[3], diagnos.info)
table.insert(components.active[3], lsp.name)
table.insert(components.active[3], file.os)
table.insert(components.active[3], file.position)
table.insert(components.active[3], utils.line_percentage)
table.insert(components.active[3], utils.scroll_bar)
table.insert(components.active[3], vi_mode.right)
table.insert(components.active[2], package_info)

local vi_mode_colors = {
    NORMAL = colors.green,
    INSERT = colors.red,
    VISUAL = colors.magenta,
    OP = colors.green,
    BLOCK = colors.blue,
    REPLACE = colors.violet,
    ['V-REPLACE'] = colors.violet,
    ENTER = colors.cyan,
    MORE = colors.cyan,
    SELECT = colors.orange,
    COMMAND = colors.green,
    SHELL = colors.green,
    TERM = colors.green,
    NONE = colors.yellow
}

require'feline'.setup {
    colors = { bg = colors.bg, fg = colors.fg },
    components = components,
    vi_mode_colors = vi_mode_colors,
    force_inactive = {
        filetypes = {
            'packer',
            'NvimTree',
            'fugitive',
            'fugitiveblame'
        },
        buftypes = {'terminal'},
        bufnames = {}
    }
}
