#!/usr/bin/env node
/**
 * Factory completion bridge — Claude Code Stop / Notification → Grok Bot webhook.
 * Safe defaults: never blocks Claude (always exit 0 for observational delivery),
 * no full transcripts, no full last_assistant_message, scoped to allowlisted cwd,
 * disabled until credentials + enabled=1 exist.
 *
 * Official webhook auth (cursor.com/help/grok-bot/routines):
 *   POST <webhook_url>
 *   Authorization: Bearer <webhook_key>
 *   Content-Type: application/json
 */
import { readFileSync, writeFileSync, appendFileSync, mkdirSync, existsSync, renameSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { createHash } from 'node:crypto';

const CFG = join(homedir(), '.config/rex-factory-completion-bridge');
const LOG = join(CFG, 'logs/dispatch.log');
const STATE = join(CFG, 'state');
const DEDUP = join(STATE, 'dedup.json');
const CRED = join(CFG, 'credentials.json');
const ALLOW = join(CFG, 'allowlist.json');
const ENABLED = join(CFG, 'enabled');
const TIMEOUT_MS = 2500;
const DEDUP_TTL_MS = 10 * 60 * 1000;
const MARKER_RE = /FACTORY_(?:STEP_DONE|GATE|STATUS)\s*:\s*(REG-\d+)\s*:\s*([A-Za-z0-9._-]{1,64})/i;
const TICKET_FROM_CWD = /REG-\d+/;

function log(line) {
  try {
    mkdirSync(join(CFG, 'logs'), { recursive: true, mode: 0o700 });
    appendFileSync(LOG, `${new Date().toISOString()} ${line}\n`, { mode: 0o600 });
  } catch { /* best-effort */ }
}

function readJson(path, fallback) {
  try {
    if (!existsSync(path)) return fallback;
    return JSON.parse(readFileSync(path, 'utf8'));
  } catch {
    return fallback;
  }
}

function stdinJson() {
  try {
    const raw = readFileSync(0, 'utf8');
    if (!raw.trim()) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function enabled() {
  try {
    return String(readFileSync(ENABLED, 'utf8')).trim() === '1';
  } catch {
    return false;
  }
}

function credentials() {
  const c = readJson(CRED, null);
  if (!c || typeof c !== 'object') return null;
  const url = typeof c.webhook_url === 'string' ? c.webhook_url.trim() : '';
  const key = typeof c.webhook_key === 'string' ? c.webhook_key.trim() : '';
  if (!url || !key) return null;
  if (!/^https:\/\//i.test(url)) return null;
  if (/PASTE_|example|changeme/i.test(url) || /PASTE_|example|changeme/i.test(key)) return null;
  return { url, key };
}

function cwdAllowed(cwd, allow) {
  if (!cwd || typeof cwd !== 'string') return false;
  const prefixes = Array.isArray(allow.cwd_prefixes) ? allow.cwd_prefixes : [];
  const subs = Array.isArray(allow.cwd_substring_any) ? allow.cwd_substring_any : [];
  const prefixOk = prefixes.some((p) => cwd === p || cwd.startsWith(p.endsWith('/') ? p : p + '/'));
  const subOk = subs.some((s) => cwd.includes(s));
  // require at least one match class if listed
  if (prefixes.length && prefixOk) return true;
  if (!prefixes.length && subOk) return true;
  // prefer both when configured: must be under prefix (RegAsk root)
  return prefixOk;
}

function extractMarkers(text) {
  if (!text || typeof text !== 'string') return { ticket: null, step: null, kind: null };
  const m = text.match(MARKER_RE);
  if (!m) return { ticket: null, step: null, kind: null };
  const kind = (text.match(/FACTORY_(STEP_DONE|GATE|STATUS)/i) || [])[1] || null;
  return { ticket: m[1], step: m[2], kind: kind ? kind.toUpperCase() : null };
}

function loadDedup() {
  const now = Date.now();
  const data = readJson(DEDUP, { entries: {} });
  const entries = data.entries || {};
  for (const [k, ts] of Object.entries(entries)) {
    if (typeof ts !== 'number' || now - ts > DEDUP_TTL_MS) delete entries[k];
  }
  return entries;
}

function saveDedup(entries) {
  try {
    mkdirSync(STATE, { recursive: true, mode: 0o700 });
    const tmp = DEDUP + '.tmp';
    writeFileSync(tmp, JSON.stringify({ entries }, null, 2), { mode: 0o600 });
    renameSync(tmp, DEDUP);
  } catch { /* best-effort */ }
}

async function postWebhook(url, key, body) {
  const ac = new AbortController();
  const t = setTimeout(() => ac.abort(), TIMEOUT_MS);
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${key}`,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(body),
      signal: ac.signal,
    });
    return { status: res.status, ok: res.status === 200 };
  } finally {
    clearTimeout(t);
  }
}

async function main() {
  // Observational: never block Claude Stop/Notification (exit 0 always).
  const input = stdinJson();
  if (!input) {
    log('skip empty_or_invalid_stdin');
    process.exit(0);
  }

  const event = input.hook_event_name || 'unknown';
  if (event !== 'Stop' && event !== 'Notification') {
    log(`skip unsupported_event=${event}`);
    process.exit(0);
  }

  const cwd = typeof input.cwd === 'string' ? input.cwd : '';
  const allow = readJson(ALLOW, { cwd_prefixes: [] });
  if (!cwdAllowed(cwd, allow)) {
    log(`skip cwd_not_allowlisted event=${event}`);
    process.exit(0);
  }

  // Stop = end-of-response (NOT human gate / NOT approval).
  // Notification = needs attention (NOT permission auto-approval).
  const notifType = typeof input.notification_type === 'string'
    ? input.notification_type
    : (typeof input.message === 'string' && /permission/i.test(input.message) ? 'permission_prompt_guess' : null);

  const last = typeof input.last_assistant_message === 'string' ? input.last_assistant_message : '';
  const msg = typeof input.message === 'string' ? input.message : '';
  const fromLast = extractMarkers(last);
  const fromMsg = extractMarkers(msg);
  let ticket = fromLast.ticket || fromMsg.ticket;
  let step = fromLast.step || fromMsg.step;
  let markerKind = fromLast.kind || fromMsg.kind;
  if (!ticket) {
    const m = cwd.match(TICKET_FROM_CWD);
    if (m) ticket = m[0];
  }

  // For Stop without factory marker: still wake with minimal metadata so parent can poll/capture.
  // Do NOT upload transcript or full last_assistant_message.
  const payload = {
    source: 'claude-code-factory-bridge',
    bridge_version: 1,
    event,
    // semantic labels for the receiving routine — not approvals
    meaning: event === 'Stop' ? 'end_of_response' : 'needs_attention',
    session_id: typeof input.session_id === 'string' ? input.session_id : null,
    cwd,
    ticket: ticket || null,
    step: step || null,
    marker_kind: markerKind || null,
    notification_type: notifType,
    stop_hook_active: input.stop_hook_active === true,
    background_tasks_count: Array.isArray(input.background_tasks) ? input.background_tasks.length : 0,
    synthetic: false,
    ts: new Date().toISOString(),
  };
  // Include prompt_id only when Claude actually sent it (do not invent).
  if (typeof input.prompt_id === 'string' && input.prompt_id) {
    payload.prompt_id = input.prompt_id;
  }

  const dedupMaterial = [
    payload.event,
    payload.session_id || '',
    payload.prompt_id || '',
    payload.ticket || '',
    payload.step || '',
    payload.notification_type || '',
    // coarse second bucket to collapse burst duplicates without inventing ids
    payload.ts.slice(0, 16),
  ].join('|');
  const dedupKey = createHash('sha256').update(dedupMaterial).digest('hex').slice(0, 24);
  payload.dedup_key = dedupKey;

  const entries = loadDedup();
  if (entries[dedupKey]) {
    log(`skip dedup=${dedupKey} event=${event}`);
    process.exit(0);
  }

  if (!enabled()) {
    log(`disabled event=${event} ticket=${ticket || '-'} step=${step || '-'} dedup=${dedupKey}`);
    process.exit(0);
  }

  const creds = credentials();
  if (!creds) {
    log(`no_credentials event=${event} ticket=${ticket || '-'} (place credentials.json + set enabled=1)`);
    process.exit(0);
  }

  try {
    const result = await postWebhook(creds.url, creds.key, payload);
    entries[dedupKey] = Date.now();
    saveDedup(entries);
    log(`posted status=${result.status} ok=${result.ok} event=${event} ticket=${ticket || '-'} dedup=${dedupKey}`);
  } catch (err) {
    log(`post_failed event=${event} err=${err && err.name ? err.name : 'error'}`);
  }
  process.exit(0);
}

main();
