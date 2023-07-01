local present, orgmode = pcall(require, "orgmode")
if not present then return end

orgmode.setup_ts_grammar()

orgmode.setup({
  org_agenda_files = {'~/Dev/org/*'},
  org_default_notes_file = '~/Dev/org/todo.org',
  win_split_mode = 'auto',
  org_capture_templates = {
    t = {description = 'Task', template = '* TODO %?\n  %U'},
    j = {
      description = 'Journal',
      template = '\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?',
      target = '~/Dev/org/journal.org'
    },
    r = {
      description = 'Reading',
      template = '* READING %?\n LINK [[]] \n %U',
      target = '~/Dev/org/reading.org'
    },
    e = 'Event',
    er = {
      description = 'recurring',
      template = '** %?\n %T',
      target = '~/Dev/org/calendar.org',
      headline = 'Recurring'
    },
    eo = {
      description = 'one-time',
      template = '** %?\n %T',
      target = '~/Dev/org/calendar.org',
      headline = 'One Time'
    }
  },
  notifications = {
    enabled = true,
    cron_enabled = true,
    repeater_reminder_time = {1, 5, 10},
    deadline_warning_reminder_time = {1, 5, 10},
    reminder_time = {1, 5, 10},
    deadline_reminder = true,
    scheduled_reminder = true,
    notifier = function(tasks)
      local result = {}
      for _, task in ipairs(tasks) do
        require('orgmode.utils').concat(result, {
          string.format('# %s (%s)', task.category, task.humanized_duration),
          string.format('%s %s %s', string.rep('*', task.level), task.todo,
                        task.title),
          string.format('%s: <%s>', task.type, task.time:to_string())
        })
      end

      if not vim.tbl_isempty(result) then
        require('orgmode.notifications.notification_popup'):new({
          content = result
        })
      end
    end,
    cron_notifier = function(tasks)
      for _, task in ipairs(tasks) do
        local title = string.format('%s (%s)', task.category,
                                    task.humanized_duration)
        local subtitle = string.format('%s %s %s', string.rep('*', task.level),
                                       task.todo, task.title)
        local date = string.format('%s: %s', task.type, task.time:to_string())

        -- Linux
        -- if vim.fn.executable('notify-send') == 1 then
        --   vim.loop.spawn('notify-send', {
        --     args = {string.format('%s\n%s\n%s', title, subtitle, date)}
        --   })
        -- end

        -- MacOS
        if vim.fn.executable('terminal-notifier') == 1 then
          vim.loop.spawn('terminal-notifier', {
            args = {'-title', title, '-subtitle', subtitle, '-message', date}
          })
        end
      end
    end
  }
})

require("headlines").setup {}
