local events = require('neo-tree.events')

local function on_move(data)
  Snacks.rename.on_rename_file(data.source, data.destination)
end

local position = 'left'

require('neo-tree').setup({
  sources = {
    'filesystem',
    'document_symbols',
    'git_status',
  },
  source_selector = {
    winbar = false,
    statusline = false,
    sources = {
      {
        source = 'filesystem',
        display_name = '  Files ',
      },
      -- {
      --   source = 'git_status',
      --   display_name = '   Git ',
      -- },
    },
  },
  close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
  enable_git_status = true,
  enable_diagnostics = true,
  open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' }, -- when opening files, do not use windows containing these filetypes or buftypes
  open_files_using_relative_paths = false,
  sort_case_insensitive = false, -- used when sorting files and directories in the tree
  sort_function = nil, -- use a custom function for sorting files and directories in the tree
  default_component_configs = {
    container = {
      enable_character_fade = true,
    },
    indent = {
      indent_size = 2,
      padding = 1, -- extra padding on left hand side
      -- indent guides
      with_markers = true,
      indent_marker = '╎',
      last_indent_marker = '╰',
      highlight = 'NeoTreeIndentMarker',
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
    icon = {
      folder_closed = '\xef\x93\x93', -- U+F4D3 nf-oct-file_directory_fill
      folder_open = '\xef\x90\x93', -- U+F413 nf-oct-file_directory (outline)
      folder_empty = '\xef\x90\x93', -- U+F413 nf-oct-file_directory (outline)
      folder_empty_open = '\xef\x90\x93', -- U+F413 nf-oct-file_directory (outline)
      default = '\xef\x80\x80', -- U+F000 nf-fa-file_o
      highlight = 'NeoTreeFileIcon',
    },
    modified = {
      symbol = '[+]',
      highlight = 'NeoTreeModified',
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = 'NeoTreeFileName',
    },
    git_status = {
      symbols = {
        -- Change type
        added = '✚',
        modified = '●',
        deleted = '✖',
        renamed = '➜',
        -- Status type
        untracked = '',
        ignored = '',
        unstaged = '󰄱',
        staged = '',
        conflict = '',
      },
    },
    -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
    file_size = {
      enabled = true,
      width = 12, -- width of the column
      required_width = 64, -- min width of window required to show this column
    },
    type = {
      enabled = true,
      width = 10, -- width of the column
      required_width = 122, -- min width of window required to show this column
    },
    last_modified = {
      enabled = true,
      width = 20, -- width of the column
      required_width = 88, -- min width of window required to show this column
    },
    created = {
      enabled = true,
      width = 20, -- width of the column
      required_width = 110, -- min width of window required to show this column
    },
    symlink_target = {
      enabled = false,
    },
  },
  nesting_rules = {},
  commands = {
    copy_selector = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local filename = node.name
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
        local result = vals[choice]
        if result then
          vim.notify(('Copied: `%s`'):format(result))
          vim.fn.setreg('+', result)
        end
      end)
    end,
  },
  filesystem = {
    components = {
      icon = function(config, node, state)
        local components = require('neo-tree.sources.common.components')
        -- No icon for root node
        if node:get_depth() == 1 then
          return {}
        end
        return components.icon(config, node, state)
      end,
      name = function(config, node, state)
        local components = require('neo-tree.sources.common.components')
        local highlight = config.highlight or 'NeoTreeFileName'

        -- Check if this is the root node
        if node:get_depth() == 1 then
          -- For root, show only the folder name (not full path)
          local name = vim.fn.fnamemodify(node.path, ':t')
          if name == '' then
            name = node.path
          end
          return {
            text = name,
            highlight = 'NeoTreeRootName',
          }
        end

        -- For all other nodes, use default component
        return components.name(config, node, state)
      end,
    },
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = true,
      hide_gitignored = true,
      hide_hidden = true, -- only works on Windows for hidden files/directories
      hide_by_name = {
        --"node_modules"
      },
      hide_by_pattern = { -- uses glob style patterns
        --"*.meta",
        --"*/src/*/tsconfig.json",
      },
      always_show = { -- remains visible even if other settings would normally hide it
        --".gitignored",
      },
      always_show_by_pattern = { -- uses glob style patterns
        --".env*",
      },
      never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
        --".DS_Store",
        --"thumbs.db"
      },
      never_show_by_pattern = { -- uses glob style patterns
        --".null-ls_*",
      },
    },
    follow_current_file = {
      enabled = true, -- This will find and focus the file in the active buffer every time
      --               -- the current file is changed while the tree is open.
      leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
    },
    group_empty_dirs = false, -- when true, empty folders will be grouped together
    hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_current",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
    -- instead of relying on nvim autocmd events.
    commands = {}, -- Add a custom command or override a global one using the same function name
    window = {
      position = position,
      width = 40,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        ['<2-LeftMouse>'] = 'open',
        ['l'] = 'open',
        ['<esc>'] = 'cancel', -- close preview or floating neo-tree window
        ['P'] = { 'toggle_preview', config = { use_float = true, use_image_nvim = true } },
        ['p'] = 'focus_preview',
        ['s'] = 'open_split',
        ['v'] = 'open_vsplit',
        ['t'] = 'open_tabnew',
        ['w'] = 'open_with_window_picker',
        ['C'] = 'close_node',
        ['z'] = 'close_all_nodes',
        ['F'] = 'clear_filter',
        ['a'] = {
          'add',
          config = {
            show_path = 'none', -- "none", "relative", "absolute"
          },
        },
        ['A'] = 'add_directory', -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
        ['d'] = 'delete',
        ['r'] = 'rename',
        ['b'] = 'rename_basename',
        ['y'] = 'copy_to_clipboard',
        ['x'] = 'cut_to_clipboard',
        ['p'] = 'paste_from_clipboard',
        ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like "add":
        ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like "add".
        ['q'] = 'close_window',
        ['R'] = 'refresh',
        ['?'] = 'show_help',
        ['<'] = 'prev_source',
        ['>'] = 'next_source',
        ['i'] = 'show_file_details',
        Y = 'copy_selector',
      },
    },
  },
  git_status = {
    window = {
      position = position,
      mappings = {
        ['<2-LeftMouse>'] = 'open',
        ['l'] = 'open',
        ['<esc>'] = 'cancel', -- close preview or floating neo-tree window
        ['P'] = { 'toggle_preview', config = { use_float = true, use_image_nvim = true } },
        ['p'] = 'focus_preview',
        ['s'] = 'open_split',
        ['v'] = 'open_vsplit',
        ['t'] = 'open_tabnew',
        ['w'] = 'open_with_window_picker',
        ['C'] = 'close_node',
        ['z'] = 'close_all_nodes',
        ['S'] = 'git_add_all',
        ['u'] = 'git_unstage_file',
        ['s'] = 'git_add_file',
        ['r'] = 'git_revert_file',
        ['gc'] = 'git_commit',
        ['gp'] = 'git_push',
        ['gg'] = 'git_commit_and_push',
        ['o'] = {
          'show_help',
          nowait = false,
          config = { title = 'Order by', prefix_key = 'o' },
        },
        ['oc'] = { 'order_by_created', nowait = false },
        ['od'] = { 'order_by_diagnostics', nowait = false },
        ['om'] = { 'order_by_modified', nowait = false },
        ['on'] = { 'order_by_name', nowait = false },
        ['os'] = { 'order_by_size', nowait = false },
        ['ot'] = { 'order_by_type', nowait = false },
      },
    },
  },
  event_handlers = {
    { event = events.FILE_MOVED, handler = on_move },
    { event = events.FILE_RENAMED, handler = on_move },
  },
})
