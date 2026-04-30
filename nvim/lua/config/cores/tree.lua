local icons = require('config.libs.icons')

-- nvim-tree, configured to feel like Emacs Treemacs.
-- Visual highlights live in nvim/lua/ui/treemacs_highlights.lua.

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local ok, nvim_tree = pcall(require, 'nvim-tree')
if not ok then
  return
end

local function copy_selector()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  if not node then
    return
  end
  local filepath = node.absolute_path
  local filename = vim.fn.fnamemodify(filepath, ':t')
  local modify = vim.fn.fnamemodify

  local vals = {
    ['BASENAME'] = modify(filename, ':r'),
    ['EXTENSION'] = modify(filename, ':e'),
    ['FILENAME'] = filename,
    ['PATH (CWD)'] = modify(filepath, ':.'),
    ['PATH (HOME)'] = modify(filepath, ':~'),
    ['PATH'] = filepath,
    ['URI'] = vim.uri_from_fname(filepath),
  }

  local options = vim.tbl_filter(function(val)
    return vals[val] ~= ''
  end, vim.tbl_keys(vals))
  if vim.tbl_isempty(options) then
    vim.notify('No values to copy', vim.log.levels.WARN)
    return
  end
  table.sort(options)
  vim.ui.select(options, {
    prompt = 'Choose to copy to clipboard:',
    format_item = function(item)
      return ('%s: %s'):format(item, vals[item])
    end,
  }, function(choice)
    if not choice then
      return
    end
    local result = vals[choice]
    if result then
      vim.notify(('Copied: `%s`'):format(result))
      vim.fn.setreg('+', result)
    end
  end)
end

local function on_attach(bufnr)
  local api = require('nvim-tree.api')
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, {
      buffer = bufnr,
      noremap = true,
      nowait = true,
      silent = true,
      desc = desc,
    })
  end

  -- Open / navigate
  map('l', api.node.open.edit, 'open')
  map('<2-LeftMouse>', api.node.open.edit, 'open')
  map('<CR>', api.node.open.edit, 'open')
  map('P', api.node.open.preview, 'preview')
  map('s', api.node.open.horizontal, 'open: split')
  map('v', api.node.open.vertical, 'open: vsplit')
  map('t', api.node.open.tab, 'open: tab')
  map('w', api.node.open.edit, 'open: window-picker')
  map('<esc>', api.node.navigate.parent_close, 'close node / parent')
  map('C', api.node.navigate.parent_close, 'close node')
  map('z', api.tree.collapse_all, 'collapse all')

  -- Filesystem ops
  map('a', api.fs.create, 'add file')
  map('A', function()
    api.fs.create()
  end, 'add directory (append "/" when prompted)')
  map('d', api.fs.remove, 'delete')
  map('r', api.fs.rename, 'rename')
  map('b', api.fs.rename_basename, 'rename basename')
  map('y', api.fs.copy.node, 'clipboard: copy')
  map('x', api.fs.cut, 'clipboard: cut')
  map('p', api.fs.paste, 'clipboard: paste')
  map('c', api.fs.copy.absolute_path, 'copy absolute path')
  map('m', api.fs.rename_full, 'move (rename full path)')

  -- Window
  map('q', api.tree.close, 'close window')
  map('R', api.tree.reload, 'reload tree')
  map('?', api.tree.toggle_help, 'help')
  map('i', api.node.show_info_popup, 'file details')
  map('H', api.tree.toggle_hidden_filter, 'toggle hidden')
  map(']c', api.node.navigate.git.next, 'git: next change')
  map('[c', api.node.navigate.git.prev, 'git: prev change')
  map('Y', copy_selector, 'copy path / name (selector)')
  map('gg', function()
    if Snacks and Snacks.lazygit then
      Snacks.lazygit()
    else
      vim.notify('Snacks.lazygit not available', vim.log.levels.WARN)
    end
  end, 'lazygit')
end

nvim_tree.setup({
  on_attach = on_attach,
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  view = {
    width = 36,
    side = 'left',
    signcolumn = 'yes',
    number = false,
    relativenumber = false,
  },
  renderer = {
    add_trailing = false,
    group_empty = false,
    highlight_git = true,
    highlight_opened_files = 'name',
    highlight_modified = 'name',
    root_folder_label = function(path)
      return '▾ ' .. vim.fn.fnamemodify(path, ':t')
    end,
    indent_width = 2,
    indent_markers = {
      enable = true,
      inline_arrows = true,
      icons = {
        corner = '╰',
        edge = '│',
        item = '├',
        bottom = '─',
        none = ' ',
      },
    },
    icons = {
      web_devicons = {
        file = { enable = true, color = true },
        folder = { enable = false, color = true },
      },
      git_placement = 'signcolumn',
      modified_placement = 'after',
      padding = ' ',
      symlink_arrow = ' ➜ ',
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
        modified = true,
      },
      glyphs = {
        default = '',
        symlink = '',
        bookmark = '󰆤',
        modified = '●',
        folder = {
          arrow_closed = '',
          arrow_open = '',
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = '',
        },
      },
    },
  },
  filters = {
    dotfiles = true,
    git_ignored = true,
    custom = {},
    exclude = {},
  },
  filesystem_watchers = {
    enable = true,
    debounce_delay = 50,
    ignore_dirs = { 'node_modules', '.git/objects' },
  },
  update_focused_file = {
    enable = true,
    update_root = false,
    ignore_list = {},
  },
  actions = {
    change_dir = { enable = true, global = false, restrict_above_cwd = false },
    open_file = {
      quit_on_open = false,
      eject = true,
      resize_window = false,
      window_picker = {
        enable = true,
        picker = 'default',
        chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        exclude = {
          filetype = { 'notify', 'qf', 'trouble', 'terminal' },
          buftype = { 'terminal', 'quickfix' },
        },
      },
    },
  },
  git = {
    enable = true,
    show_on_dirs = true,
    show_on_open_dirs = true,
    timeout = 200,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = false,
    show_on_open_dirs = true,
    icons = {
      hint = icons.diagnostics.Hint,
      info = icons.diagnostics.Info,
      warning = icons.diagnostics.Warn,
      error = icons.diagnostics.Error,
    },
  },
  modified = {
    enable = true,
    show_on_dirs = true,
    show_on_open_dirs = true,
  },
})

local Event = require('nvim-tree.api').events.Event
require('nvim-tree.api').events.subscribe(Event.NodeRenamed, function(data)
  if Snacks and Snacks.rename and Snacks.rename.on_rename_file then
    Snacks.rename.on_rename_file(data.old_name, data.new_name)
  end
end)
if Event.FileRenamed then
  require('nvim-tree.api').events.subscribe(Event.FileRenamed, function(data)
    if Snacks and Snacks.rename and Snacks.rename.on_rename_file then
      Snacks.rename.on_rename_file(data.old_name, data.new_name)
    end
  end)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NvimTree',
  callback = function()
    vim.opt_local.cursorline = true
    vim.opt_local.winhighlight = table.concat({
      'Normal:NvimTreeNormal',
      'NormalNC:NvimTreeNormalNC',
      'EndOfBuffer:NvimTreeEndOfBuffer',
      'CursorLine:NvimTreeCursorLine',
      'SignColumn:NvimTreeSignColumn',
    }, ',')
  end,
})

vim.keymap.set('n', '<leader>tw', function()
  vim.ui.input({ prompt = 'New tree root: ', completion = 'dir', default = vim.fn.getcwd() }, function(input)
    if not input or input == '' then
      return
    end
    require('nvim-tree.api').tree.change_root(vim.fn.fnamemodify(input, ':p'))
  end)
end, { desc = 'nvim-tree: change root (workspace switch)' })
