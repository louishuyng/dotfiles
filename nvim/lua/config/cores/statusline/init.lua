local present, feline = pcall(require, "feline")

if not present then
   return
end

local colors = require 'ui.main_colors'

-- Components
local diagnostic  = require 'config.cores.statusline.components.diagnostic';
local diff  = require 'config.cores.statusline.components.diff';
local dir_name  = require 'config.cores.statusline.components.dir_name';
local file_name  = require 'config.cores.statusline.components.file_name';
local git_branch  = require 'config.cores.statusline.components.git_branch';
local lsp_icon  = require 'config.cores.statusline.components.lsp_icon';
local lsp_progress  = require 'config.cores.statusline.components.lsp_progress';
local others  = require 'config.cores.statusline.components.others';

local function add_table(a, b)
   table.insert(a, b)
end

-- components are divided in 3 sections
local left = {}
local middle = {}
local right = {}

-- left
add_table(left, others.main_icon)
add_table(left, file_name)
add_table(left, dir_name)
add_table(left, diff.add)
add_table(left, diff.change)
add_table(left, diff.remove)
add_table(left, diagnostic.error)
add_table(left, diagnostic.warning)
add_table(left, diagnostic.hint)
add_table(left, diagnostic.info)

add_table(middle, lsp_progress)

-- right
add_table(right, lsp_icon)
add_table(right, git_branch)
add_table(right, others.empty_space)
add_table(right, others.empty_spaceColored)
add_table(right, others.mode_icon)
add_table(right, others.empty_space2)
add_table(right, others.separator_right)
add_table(right, others.separator_right2)
add_table(right, others.position_icon)
add_table(right, others.current_line)

-- Initialize the components table
local components = {
   active = {},
}

components.active[1] = left
components.active[2] = middle
components.active[3] = right

feline.setup {
   theme = {
      bg = colors.statusline_bg,
      fg = colors.fg,
   },
   components = components,
}
