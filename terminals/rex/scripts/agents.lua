-- rex do agents.lua: one JSON array of the terminals whose program reports a status
-- (Rex's program status protocol, which claude-code, codex and others speak), for
-- sketchybar's pilo. One call instead of a CLI round trip per block.
local terminal = 'com.superlogical.terminal'
local out = {}
local list = rex.call 'session.list' or { sessions = {} }
for _, s in ipairs(list.sessions) do
  -- Block calls answer only for sessions this connection is attached to.
  rex.call('session.attach', { session_id = s.session_id })
  local blocks = rex.call('session.list_blocks', { session_id = s.session_id }) or { blocks = {} }
  for _, b in ipairs(blocks.blocks) do
    if b.creator_name == terminal and b.window_id then
      local args = { session_id = s.session_id, block_id = b.block_id }
      local st = rex.block.call(terminal, 'program_status', args)
      local rec = st and st.records and st.records[1]
      if rec then
        local pwd = rex.block.call(terminal, 'pwd', args) or {}
        out[#out + 1] = {
          app = rec.effective_app or rec.app,
          state = rec.state,
          msg = rec.msg,
          updated_at = rec.updated_at,
          cwd = (pwd.pwd or ''):gsub('^file://[^/]*', ''),
          session_id = s.session_id,
          window_id = b.window_id,
          block_id = b.block_id,
        }
      end
    end
  end
end
return out
