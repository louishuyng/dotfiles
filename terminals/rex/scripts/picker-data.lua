-- rex do picker-data.lua: everything project-picker.sh needs in one round trip.
-- tabs: one per window, in session order. blocks: every terminal with its cwd.
local terminal = 'com.superlogical.terminal'
local tabs, blocks = {}, {}
local list = rex.call 'session.list' or { sessions = {} }
for _, s in ipairs(list.sessions) do
  -- Block calls answer only for sessions this connection is attached to.
  local att = rex.call('session.attach', { session_id = s.session_id })
  local view = att and att.view or {}
  for i, w in ipairs(view.windows or {}) do
    tabs[#tabs + 1] = {
      session_id = s.session_id,
      session = s.label,
      index = i,
      window_id = w.window_id,
      label = w.label,
      active = w.window_id == view.active_window_id,
    }
  end
  local bl = rex.call('session.list_blocks', { session_id = s.session_id }) or { blocks = {} }
  for _, b in ipairs(bl.blocks) do
    if b.creator_name == terminal and b.window_id then
      local pwd = rex.block.call(terminal, 'pwd', { session_id = s.session_id, block_id = b.block_id }) or {}
      blocks[#blocks + 1] = {
        session_id = s.session_id,
        window_id = b.window_id,
        cwd = (pwd.pwd or ''):gsub('^file://[^/]*', ''),
      }
    end
  end
end
return { tabs = tabs, blocks = blocks }
