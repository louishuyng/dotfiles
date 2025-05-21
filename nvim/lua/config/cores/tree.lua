require('neo-tree').setup({
  sources = {
    'filesystem',
    'document_symbols',
    'git_status',
  },
  source_selector = {
    winbar = true,
    statusline = false,
    sources = {
      {
        source = 'filesystem',
        display_name = '  Files ',
      },
      {
        source = 'git_status',
        display_name = '   Git ',
      },
      {
        source = 'document_symbols',
        display_name = '  Symbols ',
      },
    },
  },
  close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
  popup_border_style = 'rounded',
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
      indent_marker = '│',
      last_indent_marker = '└',
      highlight = 'NeoTreeIndentMarker',
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
    icon = {
      folder_closed = '',
      folder_open = '',
      folder_empty = '󰜌',
      default = '*',
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
        added = '', -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified = '', -- or "", but this is redundant info if you use git_status_colors on the name
        deleted = '✖', -- this can only be used in the git_status source
        renamed = '󰁕', -- this can only be used in the git_status source
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
  filesystem = {
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
      position = 'right',
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
      },
    },
  },
  git_status = {
    window = {
      position = 'float',
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
  document_symbols = {
    window = {
      position = 'right',
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
      },
    },
  },
})
