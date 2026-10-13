import { DatabaseSync } from 'node:sqlite';
import { createReadStream } from 'node:fs';
import { mkdir, readdir, stat } from 'node:fs/promises';
import path from 'node:path';

const numeric = (value) => Number.isFinite(Number(value)) ? Math.max(0, Number(value)) : 0;
const totals = () => ({ input: 0, output: 0, cacheRead: 0, cacheWrite: 0, reasoning: 0, turns: 0, toolCalls: 0, errors: 0, compactions: 0, cost: null });
export function tokens(value = {}, agent) {
  const cacheRead = numeric(value.cached_input_tokens ?? value.cache_read_input_tokens ?? value.cache?.read ?? value.cacheRead);
  const cacheWrite = numeric(value.cache_write_input_tokens ?? value.cache_creation_input_tokens ?? value.cache?.write ?? value.cacheWrite);
  const input = numeric(value.input_tokens ?? value.input);
  return { input: input + (agent === 'codex' ? 0 : cacheRead + cacheWrite), output: numeric(value.output_tokens ?? value.output), cacheRead, cacheWrite, reasoning: numeric(value.reasoning_output_tokens ?? value.reasoning ?? value.output_tokens_details?.reasoning_tokens) };
}
export function emptyFile(agent, id) {
  return { agent, id, project: '', model: 'Unknown', startedAt: '', updatedAt: '', context: null, peakContext: null, contextLimit: null, subagent: false, items: {}, events: {}, previous: {}, errors: 0 };
}
function observeContext(state, value) {
  if (value === undefined || value === null) return;
  state.context = numeric(value);
  state.peakContext = Math.max(state.peakContext || 0, state.context);
}
function modelId(value) {
  if (typeof value === 'string') {
    try { value = JSON.parse(value); } catch { return value || null; }
  }
  return typeof value === 'string' ? value : value?.modelID || value?.id || null;
}
function item(state, id, timestamp, values, canonical = false) {
  if (!id || !timestamp || !Number.isFinite(Date.parse(timestamp))) return;
  const old = state.items[id];
  const next = { ...(old || totals()), ...values, timestamp: old?.timestamp || timestamp, model: state.model, canonical, id };
  if (old) for (const key of ['input', 'output', 'cacheRead', 'cacheWrite', 'reasoning']) next[key] = Math.max(old[key] || 0, next[key] || 0);
  state.items[id] = next;
}
function event(state, id, timestamp, values) {
  if (!timestamp || !Number.isFinite(Date.parse(timestamp))) return;
  state.events[id] = { ...totals(), ...values, timestamp, model: state.model, id };
}
export function consume(state, record) {
  const p = record.payload || {};
  let timestamp = record.timestamp;
  if (typeof timestamp === 'number') timestamp = new Date(timestamp).toISOString();
  if (timestamp && Number.isFinite(Date.parse(timestamp))) {
    state.startedAt ||= timestamp;
    state.updatedAt = timestamp > state.updatedAt ? timestamp : state.updatedAt;
  }
  if (state.agent === 'codex') {
    if (record.type === 'session_meta') {
      state.id = p.id || state.id; state.project = p.cwd || ''; state.contextLimit = p.context_window || null;
      state.subagent = !!p.source?.subagent || p.thread_source === 'subagent';
      state.imported = /claude|import/i.test(String(p.originator || ''));
    }
    if (record.type === 'turn_context') { state.model = p.model || state.model; event(state, `turn:${p.turn_id}`, timestamp, { turns: 1 }); }
    if (record.type === 'token_usage_record' && p.usage) {
      item(state, `response:${p.response_id || record.ordinal}`, timestamp, tokens(p.usage, 'codex'), true);
      observeContext(state, p.usage.input_tokens);
    }
    if (record.type === 'event_msg' && p.type === 'token_count' && p.info?.total_token_usage) {
      const total = tokens(p.info.total_token_usage, 'codex'); const delta = {};
      for (const key of Object.keys(total)) delta[key] = Math.max(0, total[key] - (state.previous[key] || 0));
      state.previous = total;
      item(state, `fallback:${record.ordinal ?? timestamp}`, timestamp, delta);
      observeContext(state, p.info.last_token_usage?.input_tokens);
      state.contextLimit = p.info.model_context_window || state.contextLimit;
    }
    if (record.type === 'response_item' && ['function_call', 'custom_tool_call'].includes(p.type)) event(state, `tool:${p.call_id || record.ordinal || timestamp}`, timestamp, { toolCalls: 1 });
    if (record.type === 'compacted' || (record.type === 'event_msg' && p.type === 'context_compacted')) event(state, `compact:${timestamp}`, timestamp, { compactions: 1 });
    if (record.type === 'event_msg' && p.type === 'error') event(state, `error:${timestamp}`, timestamp, { errors: 1 });
  } else if (state.agent === 'claude') {
    state.subagent ||= !!record.isSidechain;
    state.id = state.subagent ? `subagent:${record.agentId || state.id.replace(/^subagent:/,'')}` : record.sessionId || record.session_id || state.id;
    state.project = record.cwd || state.project;
    const message = record.message || {};
    state.model = message.model || state.model;
    if (message.usage && message.id) {
      item(state, `response:${message.id}`, timestamp, tokens(message.usage, 'claude'), true);
      observeContext(state, tokens(message.usage, 'claude').input);
    }
    if (record.type === 'user' && !record.isMeta && (typeof message.content === 'string' || Array.isArray(message.content) && message.content.some((p)=>p.type==='text') && !message.content.some((p)=>p.type==='tool_result'))) event(state, `turn:${record.uuid || timestamp}`, timestamp, { turns: 1 });
    if (Array.isArray(message.content)) for (const block of message.content) {
      if (block.type === 'tool_use') event(state, `tool:${block.id}`, timestamp, { toolCalls: 1 });
      if (block.type === 'tool_result' && block.is_error) event(state, `error:${block.tool_use_id}`, timestamp, { errors: 1 });
    }
    if (record.type === 'system' && record.subtype === 'compact_boundary') event(state, `compact:${record.uuid || timestamp}`, timestamp, { compactions: 1 });
  } else if (state.agent === 'pi') {
    if (record.type === 'session') { state.id = record.id || state.id; state.project = record.cwd || ''; }
    if (record.type === 'model_change') state.model = record.modelId || state.model;
    const message = record.message || {};
    state.model = message.model || state.model;
    if (message.role === 'assistant' && message.usage) {
      item(state, `response:${record.id}`, timestamp, { ...tokens(message.usage, 'pi'), cost: Number.isFinite(message.usage.cost?.total) ? message.usage.cost.total : null }, true);
      observeContext(state, tokens(message.usage, 'pi').input);
    }
    if (message.role === 'user') event(state, `turn:${record.id}`, timestamp, { turns: 1 });
    if (Array.isArray(message.content)) for (const block of message.content) if (block.type === 'toolCall') event(state, `tool:${block.id}`, timestamp, { toolCalls: 1 });
    if (message.role === 'toolResult' && message.isError) event(state, `error:${record.id}`, timestamp, { errors: 1 });
    if (record.type === 'compaction') event(state, `compact:${record.id}`, timestamp, { compactions: 1 });
  }
}
export function fileEvents(state) {
  const values = Object.values(state.items);
  const firstCanonical = values.filter((x) => x.canonical).map((x) => x.timestamp).sort()[0];
  // Keep legacy history before canonical response accounting became available.
  return [...values.filter((x) => state.agent !== 'codex' || !firstCanonical || x.canonical || x.timestamp < firstCanonical), ...Object.values(state.events)];
}
async function filesUnder(root, warnings, depth = 0) {
  let entries;
  try { entries = await readdir(root, { withFileTypes: true }); }
  catch (error) { if (error.code !== 'ENOENT') warnings.push(`Cannot read ${root}: ${error.code}`); return []; }
  if (depth > 12) return [];
  const result = [];
  for (const entry of entries) {
    const file = path.join(root, entry.name);
    if (entry.isDirectory()) result.push(...await filesUnder(file, warnings, depth + 1));
    else if (entry.isFile() && entry.name.endsWith('.jsonl')) result.push(file);
  }
  return result;
}
const dateFormatters=new Map();
export function localDate(timestamp, timezone) {
  if(!dateFormatters.has(timezone))dateFormatters.set(timezone,new Intl.DateTimeFormat('en-CA', { timeZone: timezone, year: 'numeric', month: '2-digit', day: '2-digit' }));
  const parts = dateFormatters.get(timezone).formatToParts(new Date(timestamp));
  return ['year', 'month', 'day'].map((key) => parts.find((x) => x.type === key).value).join('-');
}
export function weekOf(date) {
  const value = new Date(`${date}T12:00:00Z`); value.setUTCDate(value.getUTCDate() - (value.getUTCDay() + 6) % 7); return value.toISOString().slice(0, 10);
}
function add(target, source) {
  for (const key of Object.keys(totals())) {
    if (key === 'cost') { if (source.cost !== null && source.cost !== undefined) target.cost = (target.cost || 0) + source.cost; }
    else target[key] += numeric(source[key]);
  }
}
export class UsageIndex {
  constructor(home, cache) {
    this.home = home; this.cache = cache; this.timezone = Intl.DateTimeFormat().resolvedOptions().timeZone; this.warnings = []; this.refreshedAt = null; this.pending = null;
  }
  async refresh() {
    if (this.pending) return this.pending;
    if (this.refreshedAt && Date.now() - Date.parse(this.refreshedAt) < 20000) return;
    this.pending = this.index().finally(() => { this.pending = null; }); return this.pending;
  }
  async index() {
    await mkdir(this.cache, { recursive: true, mode: 0o700 });
    this.db ||= new DatabaseSync(path.join(this.cache, 'usage.sqlite'));
    this.db.exec('CREATE TABLE IF NOT EXISTS files (path TEXT PRIMARY KEY, size INTEGER, mtime REAL, offset INTEGER, data TEXT);');
    this.db.exec('CREATE TABLE IF NOT EXISTS failures (path TEXT PRIMARY KEY, size INTEGER, mtime REAL, message TEXT);');
    if (this.db.prepare('PRAGMA user_version').get().user_version !== 1) {
      this.db.exec('BEGIN; DELETE FROM files; PRAGMA user_version = 1; COMMIT;');
    }
    const roots = { codex: '.codex/sessions', claude: '.claude/projects', pi: '.pi/agent/sessions' }; this.warnings = [];
    const active = new Set();
    for (const [agent, relative] of Object.entries(roots)) {
      const files = await filesUnder(path.join(this.home, relative), this.warnings);
      if (!files.length) this.warnings.push(`${agent}: no local session history found.`);
      for (const file of files) {
        active.add(file);
        let info;
        try {
          info = await stat(file);
          const failure=this.db.prepare('SELECT * FROM failures WHERE path = ?').get(file);
          if(failure?.size===info.size && failure.mtime===info.mtimeMs) {this.warnings.push(`${agent}: cannot index ${path.basename(file)} (${failure.message}).`);continue;}
          const old = this.db.prepare('SELECT * FROM files WHERE path = ?').get(file);
          if (old?.size === info.size && old?.mtime === info.mtimeMs) continue;
          const append = old && info.size > old.size;
          const state = append ? JSON.parse(old.data) : emptyFile(agent, path.basename(file, '.jsonl'));
          const start = append ? old.offset : 0;
          let offset = start;
          // Only index complete records; a running agent can leave a partial final line.
          let pending = Buffer.alloc(0);
          if (info.size > start) {
            for await (const chunk of createReadStream(file, { start, end: info.size - 1 })) {
              pending = Buffer.concat([pending, chunk]); let boundary;
              while ((boundary = pending.indexOf(10)) !== -1) {
                const line = pending.subarray(0, boundary).toString('utf8'); offset += boundary + 1; pending = pending.subarray(boundary + 1);
                try { if (line.trim()) consume(state, JSON.parse(line)); } catch { state.errors++; }
              }
              // shortcut: records above 16 MB are skipped; use streaming JSON if their session metadata is needed.
              if (pending.length > 16 * 1024 * 1024) throw new Error('Oversized history record');
            }
          }
          this.db.prepare('INSERT OR REPLACE INTO files VALUES (?, ?, ?, ?, ?)').run(file, info.size, info.mtimeMs, offset, JSON.stringify(state));
          this.db.prepare('DELETE FROM failures WHERE path = ?').run(file);
        } catch (error) {
          const message=error.code || error.message;
          if(info)this.db.prepare('INSERT OR REPLACE INTO failures VALUES (?, ?, ?, ?)').run(file,info.size,info.mtimeMs,message);
          this.warnings.push(`${agent}: cannot index ${path.basename(file)} (${message}).`);
        }
      }
    }
    for (const row of this.db.prepare('SELECT path FROM files').all()) if (!active.has(row.path)) this.db.prepare('DELETE FROM files WHERE path = ?').run(row.path);
    for(const row of this.db.prepare('SELECT path FROM failures').all())if(!active.has(row.path))this.db.prepare('DELETE FROM failures WHERE path = ?').run(row.path);
    this.refreshedAt = new Date().toISOString();
  }
  async openCode() {
    const file = path.join(this.home, '.local/share/opencode/opencode.db');
    try { await stat(file); } catch { return []; }
    let db;
    try {
      db = new DatabaseSync(file, { readOnly: true });
      db.exec('PRAGMA busy_timeout = 1500');
      const sessions = db.prepare('SELECT id, directory, parent_id, agent, model, time_created, time_updated FROM session_v2').all();
      const result = sessions.map((s) => ({ ...emptyFile('opencode', s.id), project: s.directory || '', model: modelId(s.model) || 'Unknown', subagent: !!s.parent_id, startedAt: new Date(s.time_created).toISOString(), updatedAt: new Date(s.time_updated).toISOString() }));
      const byId = new Map(result.map((s) => [s.id, s]));
      for (const row of db.prepare('SELECT id, session_id, type, time_created, data FROM session_message ORDER BY time_created').iterate()) {
        const state = byId.get(row.session_id); if (!state) continue;
        try {
          const d = JSON.parse(row.data); const timestamp = new Date(row.time_created).toISOString();
          state.model = modelId(d.model) || state.model;
          if (row.type === 'assistant' && d.tokens) { item(state, `response:${row.id}`, timestamp, { ...tokens(d.tokens, 'opencode'), cost: Number.isFinite(d.cost) ? d.cost : null }, true); observeContext(state, tokens(d.tokens, 'opencode').input); }
          if (row.type === 'user') event(state, `turn:${row.id}`, timestamp, { turns: 1 });
          if (row.type === 'compaction') event(state, `compact:${row.id}`, timestamp, { compactions: 1 });
          for (const [i, part] of (d.content || []).entries()) if (part.type === 'tool' || part.type === 'tool-call') event(state, `tool:${part.callID || part.id || `${row.id}:${i}`}`, timestamp, { toolCalls: 1, errors: part.state?.status === 'error' ? 1 : 0 });
        } catch { state.errors++; }
      }
      return result;
    } catch (error) { this.warnings.push(`opencode: unsupported or unreadable history database (${error.message}).`); return []; }
    finally { db?.close(); }
  }
  async report(query) {
    const validDate = (value) => /^\d{4}-\d{2}-\d{2}$/.test(value) && Number.isFinite(Date.parse(value)) && new Date(value).toISOString().slice(0, 10) === value;
    const today = localDate(Date.now(), this.timezone);
    const days = Math.min(366, Math.max(1, Math.trunc(Number(query.get('days')) || 7)));
    const end = query.get('to') || today;
    const rangeError = 'Choose a valid date range of at most 366 days.';
    if (!validDate(end)) throw new Error(rangeError);
    const startDay = new Date(`${end}T12:00:00Z`); startDay.setUTCDate(startDay.getUTCDate() - days + 1);
    const start = query.get('from') || startDay.toISOString().slice(0, 10);
    if (!validDate(start) || start > end || (Date.parse(end) - Date.parse(start)) / 86400000 >= 366) throw new Error(rangeError);
    await this.refresh();
    const sources = [...this.db.prepare('SELECT data FROM files').all().map((x) => JSON.parse(x.data)), ...await this.openCode()];
    const visibleSources=sources.filter((s)=>!query.get('agent') || query.get('agent')==='all' || query.get('agent')===s.agent);
    const models = [...new Set(visibleSources.flatMap((s) => [s.model, ...fileEvents(s).map((e) => e.model)]))].sort();
    const projects = [...new Set(visibleSources.map((s) => s.project).filter(Boolean))].sort();
    const selected = (key, value) => !query.get(key) || query.get(key) === 'all' || query.get(key) === value;
    const summary = { ...totals(), sessions: 0, tokens: 0, activeDays: 0, costCoverage: 0 }; const daily = new Map(); const sessions = []; const seen = new Set(); const seenUsage = new Set();
    for (const state of sources.sort((a, b) => a.subagent - b.subagent)) {
      if (state.imported || seen.has(`${state.agent}:${state.id}`)) continue;
      seen.add(`${state.agent}:${state.id}`);
      if (!selected('agent', state.agent) || !selected('project', state.project)) continue;
      const events = fileEvents(state).filter((e) => { const date = localDate(e.timestamp, this.timezone); return date >= start && date <= end && selected('model', e.model); });
      const inRange = state.startedAt && localDate(state.startedAt, this.timezone) >= start && localDate(state.startedAt, this.timezone) <= end;
      if (!events.length && !(inRange && selected('model', state.model))) continue;
      const session = { ...totals(), id: state.id, agent: state.agent, model: state.model, project: state.project, startedAt: state.startedAt, updatedAt: state.updatedAt, context: state.context, peakContext: state.peakContext, contextLimit: state.contextLimit, subagent: state.subagent };
      for (const e of events) {
        const key = `${state.agent}:${e.id}`;
        if (e.canonical && seenUsage.has(key)) continue;
        if (e.canonical) seenUsage.add(key);
        add(session, e);
        const date = localDate(e.timestamp, this.timezone);
        if (!daily.has(date)) daily.set(date, { date, codex: 0, claude: 0, opencode: 0, pi: 0, total: 0, sessions: new Set() });
        const bucket = daily.get(date); const value = numeric(e.input) + numeric(e.output);
        bucket[state.agent] += value; bucket.total += value; bucket.sessions.add(`${state.agent}:${state.id}`);
      }
      sessions.push(session); add(summary, session);
      if (session.cost !== null) summary.costCoverage++;
      if (state.errors) this.warnings.push(`${state.agent}: skipped ${state.errors} malformed records in a session.`);
    }
    summary.sessions = sessions.length; summary.tokens = summary.input + summary.output;
    summary.activeDays = daily.size;
    for(let day=start;day<=end;) {
      if(!daily.has(day))daily.set(day,{date:day,codex:0,claude:0,opencode:0,pi:0,total:0,sessions:new Set()});
      const next=new Date(`${day}T12:00:00Z`);next.setUTCDate(next.getUTCDate()+1);day=next.toISOString().slice(0,10);
    }
    const weekly = new Map();
    const dailyRows = [...daily.values()].sort((a, b) => a.date.localeCompare(b.date)).map((d) => {
      const week = weekOf(d.date); const w = weekly.get(week) || { date: week, total: 0, sessions: new Set() }; w.total += d.total;
      for (const id of d.sessions) w.sessions.add(id); weekly.set(week, w);
      return { ...d, sessions: d.sessions.size };
    });
    return { summary, daily: dailyRows, weekly: [...weekly.values()].map((w) => ({ ...w, sessions: w.sessions.size })), sessions: sessions.sort((a, b) => b.updatedAt.localeCompare(a.updatedAt)), models, projects, warnings: [...new Set(this.warnings)], timezone: this.timezone, refreshedAt: this.refreshedAt };
  }
}
