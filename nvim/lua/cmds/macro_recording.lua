vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
  callback = function(ev)
    local msg
    local reg = vim.fn.reg_recording()

    if ev.event == 'RecordingEnter' then
      vim.notify('🔴 Recording @' .. reg, vim.log.levels.WARN, {
        title = '🎬 Macro Recording',
        timeout = false,
        icon = '',
      })
    else
      Snacks.notifier.hide()
      vim.cmd('noh')

      vim.notify('✅ Recorded @' .. reg, vim.log.levels.INFO, {
        title = '🎬 Macro Recording',
        timeout = 2000,
        icon = '',
      })
    end
  end,
})
