-- Rex Beta keymap, mirroring the Herdr app (terminals/herdr-app/keys.json and the
-- ctrl-a prefix mod in terminals/herdr-app/mods/prefix/main.js). Herdr spaces map to
-- Rex sessions. Docs: https://www.superlogical.com/rex/docs/customize/keyboard-shortcuts

local home = os.getenv 'HOME'
local rex_cli = '/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex'

-- tmux display-popup: a floating layer running the tool, gone when the tool exits.
-- A string goes through fish (for ~ and fish syntax); a list runs as is, skipping fish's startup.
local function popup(ctx, command)
  local _, err = rex.session.new_layer {
    bounds = { 0.05, 0.05, 0.9, 0.9 },
    focus = true,
    layout = rex.layout.block {
      flavor = 'com.superlogical.terminal.shell',
      options = { command = type(command) == 'table' and command or { 'fish', '-c', command } },
    },
  }
  if err ~= nil then error(err, 0) end
end

rex.action {
  name = 'popup',
  title = 'Popup Command',
  args = { command = 'string' },
  run = function(ctx, args) popup(ctx, args.command) end,
}

-- prefix s: project picker. Must return at once: the app takes no keys until a key's
-- action returns, so waiting here for the pick freezes Rex.
local picker = '~/.dotfiles/terminals/rex/scripts/project-picker.sh'
rex.action {
  name = 'project_picker',
  title = 'Projects',
  run = function(ctx)
    if ctx.session_id then return popup(ctx, { home .. '/.dotfiles/terminals/rex/scripts/project-picker.sh' }) end
    -- No session yet, so no window to float a popup over: start one in ~ running the picker.
    local s, err = rex.call('session.create', {
      label = 'home',
      initial_windows = {
        {
          layout = rex.layout.block {
            flavor = 'com.superlogical.terminal.shell',
            options = { cwd = home, command = { 'fish', '-c', picker .. '; exec fish' } },
          },
        },
      },
    })
    if err ~= nil then error(err, 0) end
    rex.client.queue('session.select', { session_id = s.session_id })
  end,
}

-- prefix v / [: the pane's scrollback in nvim (herdr's edit_scrollback).
rex.action {
  name = 'scrollback_nvim',
  title = 'Scrollback in Neovim',
  run = function(ctx)
    if not ctx.block_id then return end
    popup(ctx, string.format("'%s' capture -b %s | nvim -R -c 'normal G' -", rex_cli, ctx.block_id))
  end,
}

-- Herdr's space.select:N; Rex only selects sessions by ID.
rex.action {
  name = 'session_nth',
  title = 'Go to Session N',
  args = { index = 'integer' },
  run = function(_, args)
    local list, err = rex.call 'session.list'
    if err ~= nil then error(err, 0) end
    local s = list.sessions[args.index]
    if s then rex.client.queue('session.select', { session_id = s.session_id }) end
  end,
}

-- Phosphor, the Herdr app's theme (themes/phosphor, Ghostty format). Rex keeps imported
-- themes in its own settings, so import once from the palette: "Use Phosphor Theme".
rex.action {
  name = 'phosphor_theme',
  title = 'Use Phosphor Theme',
  run = function()
    rex.client.queue('client.theme.import', { path = home .. '/.dotfiles/terminals/rex/themes/phosphor' })
  end,
}

-- prefix j/k: walk the sidebar top to bottom. Next/previous tab in this session; past its
-- last (first) tab, the next (previous) session at its first (last) tab. The app reopens a
-- session on the tab it remembers, so the switch names the tab.
rex.action {
  name = 'sidebar_step',
  title = 'Next Tab in Sidebar',
  args = { step = 'integer' },
  run = function(ctx, args)
    if not ctx.session_id then return end
    local att, err = rex.call('session.attach', { session_id = ctx.session_id })
    if err ~= nil then error(err, 0) end
    local windows = att.view.windows or {}
    local at = 1
    for i, w in ipairs(windows) do
      if w.window_id == att.view.active_window_id then at = i end
    end
    if windows[at + args.step] then
      return rex.client.queue(args.step > 0 and 'client.tab.next' or 'client.tab.previous')
    end

    local list, lerr = rex.call 'session.list'
    if lerr ~= nil then error(lerr, 0) end
    local n = #list.sessions
    for i, s in ipairs(list.sessions) do
      if s.session_id == ctx.session_id then
        local other = list.sessions[(i - 1 + args.step) % n + 1]
        local oatt = rex.call('session.attach', { session_id = other.session_id })
        local ow = oatt and oatt.view.windows or {}
        local target = ow[args.step > 0 and 1 or #ow]
        if not target then return rex.client.queue('session.select', { session_id = other.session_id }) end
        rex.call('session.focus_window', { session_id = other.session_id, window_id = target.window_id })
        return rex.client.queue('session.select', { session_id = other.session_id, window_id = target.window_id })
      end
    end
  end,
}

-- Herdr's space.move (prefix { and }): one step left or right in the session order.
rex.action {
  name = 'session_move',
  title = 'Move Session',
  args = { step = 'integer' },
  run = function(ctx, args)
    local list, err = rex.call 'session.list'
    if err ~= nil then error(err, 0) end
    local ids = {}
    local at
    for i, s in ipairs(list.sessions) do
      ids[i] = s.session_id
      if s.session_id == ctx.session_id then at = i end
    end
    if not at then return end
    local to = at + args.step
    if to < 1 or to > #ids then return end
    -- session.move places a session before another; moving right means before the one after `to`.
    local before = args.step < 0 and ids[to] or ids[to + 1]
    local _, merr = rex.call('session.move', { session_id = ctx.session_id, before_session_id = before })
    if merr ~= nil then error(merr, 0) end
  end,
}

rex.action {
  name = 'toggle_appearance',
  title = 'Toggle Appearance',
  run = function()
    rex.exec.start({ home .. '/.dotfiles/terminals/herdr/scripts/toggle-appearance.sh' }, { detach = true })
  end,
}

-- prefix H/J/K/L resizes, then stays in resize mode so h/j/k/l keep going (tmux bind -r).
for key, dir in pairs { h = 'left', j = 'down', k = 'up', l = 'right' } do
  rex.action {
    name = 'resize_' .. dir,
    title = 'Resize Pane ' .. dir,
    run = function()
      rex.client.queue('pane.resize', { direction = dir })
      rex.client.queue('client.mode.enter', { name = 'resize' })
    end,
  }
  rex.bind('ctrl+a>shift+' .. key, 'resize_' .. dir)
  rex.bind('resize/' .. key, 'pane.resize', { direction = dir })
  rex.bind('resize/shift+' .. key, 'pane.resize', { direction = dir })
end
rex.bind('resize/escape', 'client.mode.exit')
rex.bind('resize/enter', 'client.mode.exit')

-- Global keys (keys.json "global").
rex.bind('cmd+t', 'client.tab.new')
rex.bind('cmd+w', 'client.tab.close')
rex.bind('ctrl+tab', 'client.tab.next')
rex.bind('ctrl+shift+tab', 'client.tab.previous')
rex.bind('shift+cmd+]', 'client.tab.next')
rex.bind('shift+cmd+[', 'client.tab.previous')
rex.bind('alt+cmd+]', 'session.next')
rex.bind('alt+cmd+[', 'session.previous')
rex.bind('cmd+n', 'session.new')
rex.bind('cmd+p', 'project_picker')
rex.bind('cmd+i', 'pane.view_activity')
rex.bind('shift+cmd+p', 'client.palette.toggle')
rex.bind('cmd+,', 'client.settings')
rex.bind('cmd+d', 'pane.split', { direction = 'right' })
rex.bind('shift+cmd+d', 'pane.split', { direction = 'down' })
rex.bind('shift+cmd+w', 'pane.close')
rex.bind('shift+cmd+enter', 'pane.zoom')
for _, dir in ipairs { 'left', 'right', 'up', 'down' } do
  rex.bind('alt+cmd+' .. dir, 'pane.focus', { direction = dir })
  rex.bind('shift+alt+cmd+' .. dir, 'pane.move', { direction = dir })
end
rex.bind('f2', 'client.tab.rename')
rex.bind('shift+f2', 'session.rename')
rex.bind('cmd+b', 'client.sidebar.toggle')
rex.bind('cmd+s', 'client.sidebar.toggle')
rex.bind('cmd+=', 'client.font.increase')
rex.bind('shift+cmd+=', 'client.font.increase')
rex.bind('cmd+-', 'client.font.decrease')
rex.bind('cmd+0', 'client.font.reset')
for n = 1, 9 do
  rex.bind('cmd+' .. n, 'client.tab.goto', { index = n })
  rex.bind('ctrl+' .. n, 'session_nth', { index = n })
end

-- Readline keys (keys.json "terminal").
rex.bind('alt+left', 'pane.send_key', { key = 'alt+b' })
rex.bind('alt+right', 'pane.send_key', { key = 'alt+f' })
rex.bind('alt+backspace', 'pane.send_key', { key = 'ctrl+w' })
rex.bind('cmd+left', 'pane.send_key', { key = 'ctrl+a' })
rex.bind('cmd+right', 'pane.send_key', { key = 'ctrl+e' })
rex.bind('cmd+backspace', 'pane.send_key', { key = 'ctrl+u' })

-- ctrl+a prefix (prefix mod KEYS).
local P = 'ctrl+a>'
rex.bind(P .. 'h', 'pane.focus', { direction = 'left' })
rex.bind(P .. 'l', 'pane.focus', { direction = 'right' })
-- Same with ctrl still held after the prefix, so a slow release can't change what a key does.
for key, step in pairs { j = 1, k = -1 } do
  rex.bind(P .. key, 'sidebar_step', { step = step })
  rex.bind(P .. 'ctrl+' .. key, 'sidebar_step', { step = step })
end
for key, dir in pairs { h = 'left', l = 'right' } do
  rex.bind(P .. 'ctrl+' .. key, 'pane.focus', { direction = dir })
end
for _, dir in ipairs { 'left', 'right', 'up', 'down' } do
  rex.bind(P .. dir, 'pane.move', { direction = dir })
end
rex.bind(P .. '-', 'pane.split', { direction = 'down' })
rex.bind(P .. '\\', 'pane.split', { direction = 'right' })
rex.bind(P .. 'shift+\\', 'pane.split', { direction = 'right' })
rex.bind(P .. 'x', 'pane.close')
rex.bind(P .. 'z', 'pane.zoom')
rex.bind(P .. 'c', 'client.tab.new')
rex.bind(P .. 'shift+x', 'client.tab.close')
rex.bind(P .. ',', 'client.tab.rename')
rex.bind(P .. 'shift+,', 'client.tab.move.backward')
rex.bind(P .. 'shift+.', 'client.tab.move.forward')
rex.bind(P .. 'ctrl+c', 'session.new')
rex.bind(P .. 'shift+4', 'session.rename')
rex.bind(P .. 'shift+[', 'session_move', { step = -1 })
rex.bind(P .. 'shift+]', 'session_move', { step = 1 })
rex.bind(P .. 'b', 'client.sidebar.toggle')
rex.bind(P .. 's', 'project_picker')
rex.bind(P .. 'w', 'session.switch')
rex.bind(P .. 'shift+/', 'client.palette.toggle')
rex.bind(P .. 'shift+s', 'client.settings')
rex.bind(P .. 'shift+t', 'toggle_appearance')
rex.bind(P .. 'v', 'scrollback_nvim')
rex.bind(P .. '[', 'scrollback_nvim')
rex.bind(P .. 'ctrl+a', 'pane.send_key', { key = 'ctrl+a' })
for n = 1, 9 do
  rex.bind(P .. n, 'client.tab.goto', { index = n })
end
-- prefix shift+1..9 picks a session; shift+4 stays session.rename, as in herdr.
for n = 1, 9 do
  if n ~= 4 then rex.bind(P .. 'shift+' .. n, 'session_nth', { index = n }) end
end

local popups = {
  ['/'] = 'yazi',
  i = 'lazydocker',
  t = 'tuxedo',
  ['shift+r'] = 'serpl',
  ['ctrl+r'] = 'tuicr',
  g = 'lazygit',
  n = '~/.dotfiles/terminals/notes/note.sh',
  p = '~/.dotfiles/terminals/playzones/playzone-picker.sh',
}
for key, command in pairs(popups) do
  rex.bind(P .. key, 'popup', { command = command })
end
