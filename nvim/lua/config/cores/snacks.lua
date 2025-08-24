local snacks = require('snacks')

snacks.setup {
  bigfile = { enabled = true },
  gitbrowse = { enabled = true },
  zen = { enabled = true },
  rename = { enabled = true },
  quickfile = { enabled = true },
  input = { enabled = true },
  picker = { enabled = true },
  notifier = {
    enabled = true,
    level = vim.log.levels.INFO,
  },
  styles = {
    notification = {
      border = 'rounded',
      wo = {
        winhl = 'NormalFloat:Normal,FloatBorder:DiagnosticOk'
      }
    }
  },
  -- scroll = {
  --   enabled = true,
  --   animate = {
  --     duration = { step = 15, total = 250 },
  --     easing = 'linear',
  --   },
  --   animate_repeat = {
  --     delay = 100, -- delay in ms before using the repeat animation
  --     duration = { step = 5, total = 50 },
  --     easing = 'linear',
  --   },
  --   -- what buffers to animate
  --   filter = function(buf)
  --     return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= 'terminal'
  --   end,
  -- },
  dashboard = {
    enabled = false,
    sections = {
      {
        icon = ' ',
        desc = 'Browse Repo',
        padding = 1,
        key = 'b',
        action = function()
          Snacks.gitbrowse()
        end,
      },
      function()
        local in_git = Snacks.git.get_root() ~= nil
        local cmds = {
          -- {
          --   title = 'Notifications',
          --   cmd = 'gh notify -s -a -n5',
          --   action = function()
          --     vim.ui.open('https://github.com/notifications')
          --   end,
          --   key = 'n',
          --   icon = ' ',
          --   height = 5,
          --   enabled = true,
          -- },
          {
            title = 'Open Issues',
            cmd = 'clear; gh issue list -L 3',
            key = 'i',
            action = function()
              vim.fn.jobstart('gh issue list --web', { detach = true })
            end,
            icon = ' ',
            height = 10,
          },
          {
            icon = ' ',
            title = 'Open PRs',
            cmd = 'clear;gh pr list -L 3',
            key = 'P',
            action = function()
              vim.fn.jobstart('gh pr list --web', { detach = true })
            end,
            height = 10,
          },
          -- {
          --   icon = ' ',
          --   title = 'Git Status',
          --   cmd = 'git --no-pager diff --stat -B -M -C',
          --   height = 5,
          -- },
        }
        return vim.tbl_map(function(cmd)
          return vim.tbl_extend('force', {
            section = 'terminal',
            enabled = in_git,
            padding = 0,
            ttl = 30,
            indent = 3,
          }, cmd)
        end, cmds)
      end,
      { section = 'startup' },
    },
  },
}

-- Key bindings
vim.keymap.set('n', '<C-w>o', ":lua require('snacks').zen() <CR>", { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader>go', ":lua require('snacks').gitbrowse() <CR>", { desc = 'Open git browser url' })

vim.keymap.set(
  'n',
  '<leader>fn',
  ":lua require('snacks').notifier.show_history()<CR>",
  { desc = 'Find Notification History' }
)

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
--         notif.icon = #progress[client.id] == 0 and ' '
--           or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
--       end,
--     })
--   end,
-- })
