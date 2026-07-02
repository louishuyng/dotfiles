local snacks = require('snacks')

snacks.setup {
  bigfile = { enabled = true },
  gitbrowse = { enabled = true },
  zen = { enabled = true },
  rename = { enabled = true },
  quickfile = { enabled = true },
  input = { enabled = true },
  picker = {
    enabled = true,
    ui_select = true,
    layout = { preset = 'ivy', preview = true },
    prompt = '  ',
    win = {
      input = {
        keys = {
          ['<C-/>'] = { 'toggle_help', mode = { 'i', 'n' } },
          ['<C-c>'] = { 'close', mode = { 'i', 'n' } },
          ['<Esc>'] = { 'close', mode = { 'i', 'n' } },
        },
      },
    },
  },
  notifier = {
    enabled = true,
    timeout = 3000,
    style = 'compact',
    top_down = false,
    margin = { top = 0, right = 1, bottom = 1 },
    icons = {
      error = ' ',
      warn = ' ',
      info = ' ',
      debug = ' ',
      trace = ' ',
    },
  },
  styles = {
    notification = {
      border = 'rounded',
      wo = {
        winhl = 'NormalFloat:Normal,FloatBorder:SnacksNotifierBorderInfo',
      },
    },
  },
  scroll = {
    enabled = false,
    animate = {
      duration = { step = 15, total = 250 },
      easing = 'linear',
    },
    animate_repeat = {
      delay = 100,
      duration = { step = 5, total = 50 },
      easing = 'linear',
    },
    filter = function(buf)
      return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= 'terminal'
    end,
  },
  terminal = {
    enabled = true,
    open_cmd = '50vnew',
    close_on_exit = true,
  },
  indent = {
    enabled = false,
    indent = {
      char = '│',
      only_scope = false,
      only_current = false,
      hl = 'SnacksIndent',
    },
    scope = {
      enabled = true,
      char = '│',
      underline = false,
      only_current = true,
      hl = 'SnacksIndentScope',
    },
    animate = {
      enabled = true,
      style = 'out',
      easing = 'linear',
      duration = { step = 20, total = 500 },
    },
    filter = function(buf)
      local ft = vim.bo[buf].filetype
      local skip = {
        snacks_dashboard = true,
        terminal = true,
        help = true,
        lazy = true,
        mason = true,
        TelescopePrompt = true,
        snacks_picker_input = true,
        snacks_picker_list = true,
        snacks_notif_history = true,
        qf = true,
        NvimTree = true,
        ['neo-tree'] = true,
        Outline = true,
      }
      return vim.bo[buf].buftype == '' and not skip[ft]
    end,
  },
  scope = {
    enabled = true,
    min_size = 2,
    keys = {
      textobject = {
        ii = {
          min_size = 2,
          edge = false,
          cursor = false,
          treesitter = { blocks = { enabled = false } },
          desc = 'inner scope',
        },
        ai = {
          cursor = false,
          min_size = 2,
          treesitter = { blocks = { enabled = false } },
          desc = 'around scope',
        },
      },
      jump = {
        ['[i'] = {
          min_size = 1,
          bottom = false,
          cursor = false,
          edge = true,
          treesitter = { blocks = { enabled = false } },
          desc = 'jump to top edge of scope',
        },
        [']i'] = {
          min_size = 1,
          bottom = true,
          cursor = false,
          edge = true,
          treesitter = { blocks = { enabled = false } },
          desc = 'jump to bottom edge of scope',
        },
      },
    },
  },
  words = {
    enabled = false,
    debounce = 200,
    notify_jump = false,
    notify_end = true,
    foldopen = true,
    jump = { ['[['] = false, [']]'] = false },
    modes = { 'n', 'i', 'c' },
  },
  dim = {
    enabled = false,
    scope = {
      min_size = 5,
      max_size = 20,
      siblings = true,
    },
    animate = {
      enabled = true,
      easing = 'outQuad',
      duration = { step = 20, total = 300 },
    },
  },
  statuscolumn = {
    enabled = true,
    left = { 'mark', 'sign' },
    right = { 'fold', 'git' },
    folds = { open = true, git_hl = true },
    git = { patterns = { 'GitSign', 'MiniDiffSign' } },
    refresh = 50,
  },
  image = {
    enabled = true,
    doc = {
      enabled = true,
      inline = true,
      float = true,
      max_width = 80,
      max_height = 40,
    },
    convert = { notify = true },
  },
  dashboard = {
    enabled = true,
    width = 90,
    formats = {
      header = { '%s', align = 'left' },
    },
    preset = {
      header = [[
                                                            /7
                                                           //
                                                          //
                                                         //
      `.                                                 //        ,'7
      `.`.                                              //       ,' ,'
        `.`.                                           //      ,' ,'
<--__     `.`.                                        //     ,' ,'
 `-. ~-_    `.`.                                     //    ,' ,'
    `-. ~-_   `.`.                                  //   ,' ,'
       `-. ~-._ `.`.                               //  ,' ,'
          `-.  ~- `.`,              __       .md##`. ,' ,'            _.--
---.._       `-._`-.'.`.         .md###bm..md####// \ ,'      ___..==~
~~--..~~~---..__ `-/==..`_d##b.md##()()#######"  \,',\  _..-~~__.-~
      ~~~---..__~~-|___>' ~~"Y#####\  /###"~   >  `---|~_..-~~
                ~~-|...|   |   ~~'`/~~\"~     ,|  |---|=-------------......
===================]===|   |     | `--' .     '|  |=--|----------~~~~~~~~~'
              __..-|~~~|   | `-..| _><_ |    ' | _'."-._
       __.-~~~__..->~~=`-.._\    |  ><  `__.mmm~~   `/`.~"-._
   _,-~ _.-~~~  ,-',\'      Y####\  `'   )###P        `.`;._ ~"-._
,-'_.-~~     ,-',-'          "Y###>-~~~`/###P_          `.`.~~-.. ~-._
 ~~       ,-',-'               """'    '|)--..)           `.`.   ~~...~-.
       ,-',-'                    |    , |`-._)              `.`.      ~~'
    ,-',-'                       |     / \                    `.`.
 .-~,-~                          |   _/  |\                     `.`.
 `-'                             |,-'/   | `.                     `.`.
                               _-~ ,'|   '   `.                     `.;
                              /   ,  |  |      >
                             /   '|  |  |     |
                            |   ` |  |  |     '
                            `._   |  |  |  __-'
                               ~~\|  |  |/~
                                  '  |  |
                                  `  |   .
                                  `  |   '
                                  `--|--'
                                   |_|_|
                                   > | <
                                   | | |
                                    \|/

                              "Moose Takes Action"
                                  --Dov Sherman
]],
    },
    sections = {
      { section = 'header' },
    },
  },
}

local snacks_grp = vim.api.nvim_create_augroup('SnacksConfig', { clear = true })

-- Disable cursorline / numbers in the dashboard buffer
vim.api.nvim_create_autocmd('FileType', {
  group = snacks_grp,
  pattern = 'snacks_dashboard',
  callback = function()
    vim.opt_local.cursorline = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Theme-agnostic highlights for snacks UI surfaces. Driven by the semantic
-- palette so dark/light flips and theme swaps both stay coherent.
local palette = require('config.theme.palette')

local function apply_snacks_hl(c)
  c = c or palette.colors
  if not next(c) then
    return
  end

  local set = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  set('SnacksDashboardHeader', { fg = c.primary })

  set('SnacksNotifierBorderInfo', { fg = c.primary })
  set('SnacksNotifierBorderWarn', { fg = c.warn })
  set('SnacksNotifierBorderError', { fg = c.error })
  set('SnacksNotifierBorderDebug', { fg = c.tertiary })
  set('SnacksNotifierBorderTrace', { fg = c.subtle })
  set('SnacksNotifierTitleInfo', { fg = c.primary, bold = true })
  set('SnacksNotifierTitleWarn', { fg = c.warn, bold = true })
  set('SnacksNotifierTitleError', { fg = c.error, bold = true })

  set('SnacksIndent', { fg = c.overlay })
  set('SnacksIndentScope', { fg = c.tertiary, bold = true })

  set('SnacksDim', { link = 'Comment' })

  set('SnacksWordsActive', { bg = c.surface, fg = c.primary, bold = true })

  set('SnacksPickerBorder', { fg = c.primary })
  set('SnacksPickerTitle', { fg = c.tertiary, bold = true })
  set('SnacksPickerInput', { fg = c.primary })
  set('SnacksPickerPrompt', { fg = c.primary, bold = true })

  set('SnacksImageBorder', { fg = c.primary })
end
palette.on_change(apply_snacks_hl)

-- Key bindings
vim.keymap.set('n', '<C-w>o', ":lua require('snacks').zen() <CR>", { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader>go', ":lua require('snacks').gitbrowse() <CR>", { desc = 'Open git browser url' })

-- Terminal keymaps
vim.keymap.set('n', '<leader>tt', function()
  Snacks.terminal.toggle()
end, { desc = 'Terminal Open' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>tH', function()
  Snacks.terminal.toggle(nil, { win = { position = 'bottom', height = 0.3 } })
end, { desc = 'Terminal Horizontal' })

vim.keymap.set('n', '<leader>tV', function()
  Snacks.terminal.toggle(nil, { win = { position = 'right', width = 0.4 } })
end, { desc = 'Terminal Vertical' })

vim.keymap.set(
  'n',
  '<leader>fn',
  ":lua require('snacks').notifier.show_history()<CR>",
  { desc = 'Find Notification History' }
)

-- Notifier dismiss
vim.keymap.set('n', '<leader>un', function()
  Snacks.notifier.hide()
end, { desc = 'Dismiss All Notifications' })

-- UI toggles
vim.keymap.set('n', '<leader>ui', function()
  Snacks.toggle.indent():toggle()
end, { desc = 'Toggle Indent Guides' })

vim.keymap.set('n', '<leader>uw', function()
  Snacks.toggle.words():toggle()
end, { desc = 'Toggle LSP Word References' })

vim.keymap.set('n', '<leader>ud', function()
  Snacks.toggle.dim():toggle()
end, { desc = 'Toggle Dim Inactive Code' })

vim.keymap.set('n', '<leader>us', function()
  Snacks.toggle.scroll():toggle()
end, { desc = 'Toggle Scroll' })

-- LSP word reference jumps (registered manually because words.jump = false above)
vim.keymap.set('n', ']]', function()
  Snacks.words.jump(vim.v.count1, true)
end, { desc = 'Next LSP Word Reference' })

vim.keymap.set('n', '[[', function()
  Snacks.words.jump(-vim.v.count1, true)
end, { desc = 'Prev LSP Word Reference' })

-- Buffer delete (preserve window layout)
vim.keymap.set('n', '<leader>bd', function()
  Snacks.bufdelete()
end, { desc = 'Delete Buffer (preserve layout)' })

vim.keymap.set('n', '<leader>bo', function()
  Snacks.bufdelete.other()
end, { desc = 'Delete Other Buffers' })

-- ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
-- local progress = vim.defaulttable()
-- vim.api.nvim_create_autocmd('LspProgress', {
--   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
--     if not client or type(value) ~= 'table' then
--       return
--     end
--     local p = progress[client.id]
--
--     for i = 1, #p + 1 do
--       if i == #p + 1 or p[i].token == ev.data.params.token then
--         p[i] = {
--           token = ev.data.params.token,
--           msg = ('[%3d%%] %s%s'):format(
--             value.kind == 'end' and 100 or value.percentage or 100,
--             value.title or '',
--             value.message and (' **%s**'):format(value.message) or ''
--           ),
--           done = value.kind == 'end',
--         }
--         break
--       end
--     end
--
--     local msg = {} ---@type string[]
--     progress[client.id] = vim.tbl_filter(function(v)
--       return table.insert(msg, v.msg) or not v.done
--     end, p)
--
--     local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
--     vim.notify(table.concat(msg, '\n'), 'info', {
--       id = 'lsp_progress',
--       title = client.name,
--       opts = function(notif)
--         notif.icon = #progress[client.id] == 0 and ' '
--           or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
--       end,
--     })
--   end,
-- })
