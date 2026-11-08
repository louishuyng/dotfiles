import { useEffect, useState } from 'react';
import { Check, CircleHelp, GitCompareArrows, LoaderCircle, Plus, RefreshCw, Server, Workflow } from 'lucide-react';
import { diffLines } from 'diff';
import { api } from '../api';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from './ui/dialog';
import { Avatar, Empty, PanelHeading, Toggle } from './common';

type ServerConfig = { type: 'stdio' | 'http'; command?: string; args?: string[]; env?: Record<string, string>; url?: string; headers?: Record<string, string>; enabled: boolean };
type HookEvent = 'sessionStart' | 'promptSubmit' | 'beforeTool' | 'permissionRequest' | 'afterTool' | 'stop';
type HookConfig = { id: string; event: HookEvent; command?: string; text?: string; skill?: string; context?: 'adhd' | 'ponytail'; enabled: boolean; disabledAgents?: string[] };
type Setup = { servers: Record<string, ServerConfig>; hooks: HookConfig[] };
type Target = { id: string; name: string; available: boolean; mcp: boolean; hooks: boolean; commandHooks?: boolean; status: string; matched: number; issues: string[]; notes?: string[]; extra: string[] };
type SharedState = {
  value: Setup; revision: string; path: string; pending: boolean;
  targets: Target[];
  imports: { tool: string; name: string; revision: string }[];
  contexts: Record<string, { content?: string; path?: string; documentId?: string; error?: string }>;
  skills: { name: string; description: string }[];
};
type HookType = 'text' | 'skill' | 'command' | 'preset';

const eventNames: Record<HookEvent, string> = { sessionStart: 'Session start', promptSubmit: 'Prompt submitted', beforeTool: 'Before tool use', permissionRequest: 'Approval requested', afterTool: 'After tool use', stop: 'Response complete' };
const contextNames = { adhd: 'ADHD', ponytail: 'Ponytail' };
const typeNames: Record<HookType, string> = { text: 'Context text', skill: 'Skill reference', command: 'Command', preset: 'Shared source' };
const hasContext = (hook: HookConfig) => hook.context !== undefined || hook.text !== undefined || hook.skill !== undefined;
const hookType = (hook?: HookConfig): HookType => hook?.context ? 'preset' : hook?.skill !== undefined ? 'skill' : hook?.command !== undefined ? 'command' : 'text';
const hookName = (hook: HookConfig) => hook.context ? contextNames[hook.context] : hook.id;
const format = (value: unknown) => JSON.stringify(value, null, 2);
const ID_PATTERN = /^[a-zA-Z0-9][a-zA-Z0-9_-]{0,79}$/;

export function SharedSetup({ section, refreshKey, onEditContext }: { section: 'servers' | 'hooks'; refreshKey: string; onEditContext: (id: string) => void }) {
  const [state, setState] = useState<SharedState>();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');
  const [editor, setEditor] = useState<'server' | 'hook'>();
  const [original, setOriginal] = useState<string>();
  const [name, setName] = useState('');
  const [draft, setDraft] = useState('');
  const [preview, setPreview] = useState<Setup>();
  const [type, setType] = useState<HookType>('text');
  const [hookText, setHookText] = useState('');
  const [hookSkill, setHookSkill] = useState('');
  const [hookCommand, setHookCommand] = useState('');
  const [hookEvent, setHookEvent] = useState<HookEvent>('afterTool');
  const [initialForm, setInitialForm] = useState('');

  const currentForm = JSON.stringify(editor === 'server' ? [name, draft] : [name, type, type === 'text' ? hookText : type === 'skill' ? hookSkill : type === 'command' ? hookCommand : undefined, type === 'command' ? hookEvent : undefined]);
  const dirty = editor ? currentForm !== initialForm : !!preview && !!state && format(preview) !== format(state.value);

  useEffect(() => {
    let active = true;
    void api<SharedState>('shared').then(next => { if (active) setState(next); }).catch(cause => { if (active) setError(cause.message); });
    return () => { active = false; };
  }, [refreshKey]);
  useEffect(() => {
    if (!dirty) return;
    const guard = (event: BeforeUnloadEvent) => event.preventDefault();
    window.addEventListener('beforeunload', guard);
    return () => window.removeEventListener('beforeunload', guard);
  }, [dirty]);
  useEffect(() => {
    if (!message) return;
    const timer = setTimeout(() => setMessage(''), 6000);
    return () => clearTimeout(timer);
  }, [message]);

  async function action(work: () => Promise<void>) {
    setBusy(true); setError(''); setMessage('');
    try { await work(); }
    catch (cause) { setError(cause instanceof Error ? cause.message : 'Shared setup failed. Refresh and retry.'); }
    finally { setBusy(false); }
  }
  function close() {
    if (busy || (dirty && !window.confirm('Discard this configuration draft?'))) return;
    setEditor(undefined); setPreview(undefined); setError('');
  }
  function openServer(id?: string) {
    const content = format(id ? state?.value.servers[id] : { type: 'stdio', command: 'npx', args: ['-y', '@modelcontextprotocol/server-everything'], env: {}, enabled: true });
    setError(''); setOriginal(id); setName(id || ''); setDraft(content); setInitialForm(JSON.stringify([id || '', content])); setEditor('server');
  }
  function openHook(hook?: HookConfig) {
    const kind = hookType(hook);
    setError(''); setOriginal(hook?.id); setName(hook?.id || ''); setType(kind);
    setInitialForm(JSON.stringify([hook?.id || '', kind, kind === 'text' ? hook?.text || '' : kind === 'skill' ? hook?.skill || '' : kind === 'command' ? hook?.command || '' : undefined, kind === 'command' ? hook?.event || 'afterTool' : undefined]));
    setHookText(hook?.text || ''); setHookSkill(hook?.skill || ''); setHookCommand(hook?.command || ''); setHookEvent(hook?.event || 'afterTool'); setEditor('hook');
  }
  function review() {
    if (!state) return;
    try {
      const next = structuredClone(state.value);
      if (editor === 'server') {
        const value = JSON.parse(draft);
        if (!ID_PATTERN.test(name)) throw new Error('Use a server name with letters, numbers, underscores, and hyphens.');
        if (name !== original && Object.hasOwn(next.servers, name)) throw new Error('A shared server already has this name.');
        if (original) delete next.servers[original];
        Object.defineProperty(next.servers, name, { value, enumerable: true, writable: true, configurable: true });
      } else {
        if (!ID_PATTERN.test(name)) throw new Error('Use a hook name with letters, numbers, underscores, and hyphens.');
        const existing = state.value.hooks.find(hook => hook.id === original);
        const value: HookConfig = { id: name, event: type === 'command' ? hookEvent : 'sessionStart', enabled: existing?.enabled ?? true, disabledAgents: existing?.disabledAgents || [] };
        if (type === 'text') { if (!hookText.trim()) throw new Error('Enter the context text.'); value.text = hookText; }
        if (type === 'skill') { if (!state.skills.some(skill => skill.name === hookSkill)) throw new Error('Choose a shared skill.'); value.skill = hookSkill; }
        if (type === 'command') { if (!hookCommand.trim()) throw new Error('Enter a command.'); value.command = hookCommand; }
        if (type === 'preset') value.context = existing?.context;
        if (value.id !== original && next.hooks.some(hook => hook.id === value.id)) throw new Error('A shared hook already has this id.');
        next.hooks = original ? next.hooks.map(hook => hook.id === original ? value : hook) : [...next.hooks, value];
      }
      setPreview(next); setError('');
    } catch (cause) { setError(cause instanceof Error ? cause.message : 'Fix the JSON before continuing.'); }
  }
  async function save() {
    if (!preview || !state) return;
    const next = await api<SharedState>('shared/save', { value: preview, revision: state.revision });
    setState(next); setPreview(undefined); setEditor(undefined);
    setMessage('Shared setup saved and synced. Restart agents to load the change.');
  }
  function stage(next: Setup) { setPreview(next); }
  function removeHook(hook: HookConfig) {
    if (!state || !window.confirm(`Remove the shared hook “${hookName(hook)}” from every agent?`)) return;
    stage({ ...state.value, hooks: state.value.hooks.filter(item => item.id !== hook.id) });
  }
  function removeServer(id: string) {
    if (!state || !window.confirm(`Remove the shared MCP server “${id}” from every agent?`)) return;
    const next = structuredClone(state.value); delete next.servers[id]; stage(next);
  }

  if (!state) {
    return <div className="empty">{error ? <><p role="alert">{error}</p><Button onClick={() => void action(async () => setState(await api<SharedState>('shared')))}>Retry</Button></> : <><LoaderCircle className="spin" aria-hidden="true" /><p>Loading shared setup…</p></>}</div>;
  }

  const enabledServers = Object.values(state.value.servers).filter(server => server.enabled).length;
  const enabledHooks = state.value.hooks.filter(hook => hook.enabled).length;
  const available = state.targets.filter(target => target.available);
  const missing = state.targets.filter(target => !target.available);

  function hookAgents(hook: HookConfig) {
    return (
      <div className="hook-agent-switches">
        {available.map(target => {
          const supported = hasContext(hook) ? target.hooks : !!target.commandHooks;
          const active = hook.enabled && !(hook.disabledAgents || []).includes(target.id);
          return (
            <label className={`hook-agent-switch ${supported ? '' : 'unsupported'}`} key={target.id}>
              <span>{target.name}<small>{supported ? active ? 'On' : 'Off' : 'Unsupported'}</small></span>
              <Toggle on={active && supported} label={`Enable ${hookName(hook)} for ${target.name}`} disabled={busy || !supported || !hook.enabled} onChange={() => {
                const disabledAgents = active ? [...(hook.disabledAgents || []), target.id] : (hook.disabledAgents || []).filter(id => id !== target.id);
                stage({ ...state!.value, hooks: state!.value.hooks.map(item => item.id === hook.id ? { ...item, disabledAgents } : item) });
              }} />
            </label>
          );
        })}
      </div>
    );
  }

  function hookContext(hook: HookConfig) {
    const context = state!.contexts[hook.id];
    return (
      <div className="hook-context">
        {context?.path && <p className="muted">Source: <code className="path">{context.path}</code></p>}
        {context?.content ? <pre className="hook-context-text" tabIndex={0} aria-label={`${hookName(hook)} injected context`}>{context.content}</pre> : <p role="alert">{context?.error || 'Context unavailable. Refresh to retry.'}</p>}
        <Button variant="outline" size="sm" disabled={busy} onClick={() => context?.documentId ? onEditContext(context.documentId) : openHook(hook)}>Edit context</Button>
      </div>
    );
  }

  function hookForm() {
    const existing = state?.value.hooks.find(hook => hook.id === original);
    return (
      <div className="form">
        <label htmlFor="hook-name">Hook name<Input id="hook-name" value={name} onChange={event => setName(event.target.value)} maxLength={80} placeholder="my-hook" /></label>
        <label htmlFor="hook-type">Hook type
          <select id="hook-type" value={type} onChange={event => setType(event.target.value as HookType)}>
            <option value="text">Context text</option><option value="skill">Skill reference</option><option value="command">Command</option>
            {existing?.context && <option value="preset">Existing shared source</option>}
          </select>
        </label>
        {type === 'text' && <label htmlFor="hook-text">Context text<textarea id="hook-text" rows={8} value={hookText} onChange={event => setHookText(event.target.value)} placeholder="Instructions to add to the agent’s context…" /><small>Loaded into new sessions. No command runs.</small></label>}
        {type === 'skill' && <label htmlFor="hook-skill">Shared skill<select id="hook-skill" value={hookSkill} onChange={event => setHookSkill(event.target.value)}><option value="">Choose a shared skill</option>{state?.skills.map(skill => <option key={skill.name} value={skill.name}>{skill.name}</option>)}</select><small>Loads the current SKILL.md text at session start. Its scripts do not run.</small></label>}
        {type === 'command' && (
          <>
            <label htmlFor="hook-event">Event<select id="hook-event" value={hookEvent} onChange={event => setHookEvent(event.target.value as HookEvent)}>{Object.entries(eventNames).map(([value, label]) => <option key={value} value={value}>{label}</option>)}</select></label>
            <label htmlFor="hook-command">Command<textarea id="hook-command" rows={4} value={hookCommand} onChange={event => setHookCommand(event.target.value)} placeholder="/absolute/path/to/hook-script" /><small>Runs in each agent’s native hook runtime and receives that agent’s event JSON.</small></label>
          </>
        )}
        {type === 'preset' && <p className="muted">Uses the {existing?.context && contextNames[existing.context]} source. Expand the hook and choose Edit context to change its instructions.</p>}
      </div>
    );
  }

  return (
    <div className="shared-setup">
      {message && <div className="notice success" role="status"><Check size={16} aria-hidden="true" />{message}</div>}
      {error && !editor && !preview && <div className="notice danger" role="alert"><CircleHelp size={16} aria-hidden="true" />{error}</div>}
      {state.pending && <div className="notice danger" role="alert"><CircleHelp size={16} aria-hidden="true" />An interrupted sync needs recovery. Restart Agent Hub; inspect its private journal if recovery reports a conflict.</div>}

      {section === 'servers' ? (
        <section className="panel">
          <PanelHeading title="MCP servers" badge={`${enabledServers} enabled`} description="Stdio commands and Streamable HTTP endpoints, defined once in the repository and written to every supported agent.">
            <div className="button-row">
              <Button variant="outline" size="sm" disabled={busy || state.pending} onClick={() => void action(async () => { setState(await api<SharedState>('shared/sync', {})); setMessage('Sync checked. Agent results are updated below.'); })}><RefreshCw size={14} className={busy ? 'spin' : ''} aria-hidden="true" />Sync now</Button>
              <Button size="sm" disabled={busy} onClick={() => openServer()}><Plus size={14} aria-hidden="true" />Add server</Button>
            </div>
          </PanelHeading>
          <div className="row-list">
            {Object.entries(state.value.servers).map(([id, server]) => (
              <div className="row" key={id}>
                <Avatar name={id}><Server size={16} aria-hidden="true" /></Avatar>
                <div className="row-copy"><h3>{id}</h3><small className="path">{server.type === 'stdio' ? [server.command, ...(server.args ?? [])].join(' ') : server.url}</small></div>
                <Badge variant="secondary">{server.type === 'stdio' ? 'stdio' : 'HTTP'}</Badge>
                <Button variant="ghost" size="sm" disabled={busy} onClick={() => openServer(id)}>Edit</Button>
                <Button variant="ghost" size="sm" disabled={busy} onClick={() => removeServer(id)}>Remove</Button>
                <Toggle on={server.enabled} label={`Enable ${id}`} disabled={busy} onChange={() => stage({ ...state.value, servers: { ...state.value.servers, [id]: { ...server, enabled: !server.enabled } } })} />
              </div>
            ))}
          </div>
          {!Object.keys(state.value.servers).length && <Empty icon={<Server size={22} aria-hidden="true" />}>Add a server, or import one an agent already has.</Empty>}
          {!!state.imports.length && (
            <details className="inline-notes">
              <summary>Import servers found in native settings ({state.imports.length})</summary>
              <p>Importing copies the definition into the repository and shares it with every supported agent. Do not import entries with inline credentials.</p>
              {state.imports.map(item => (
                <div className="row compact" key={`${item.tool}:${item.name}`}>
                  <div className="row-copy"><h3>{item.name}</h3><small>{state.targets.find(target => target.id === item.tool)?.name}</small></div>
                  <Button variant="outline" size="sm" disabled={busy} onClick={() => { if (!window.confirm(`Share ${item.name} with all supported agents?`)) return; void action(async () => { setState(await api<SharedState>('shared/import', { ...item, sourceRevision: state.revision })); setMessage('Server imported. Check agent results for conflicts.'); }); }}>Import & sync</Button>
                </div>
              ))}
            </details>
          )}
        </section>
      ) : (
        <section className="panel">
          <PanelHeading title="Shared hooks" badge={`${enabledHooks} enabled`} description="Context hooks inject instructions at session start. Command hooks run at a native event. Each agent can opt out of any hook without changing the shared source.">
            <div className="button-row">
              <Button variant="outline" size="sm" disabled={busy || state.pending} onClick={() => void action(async () => { setState(await api<SharedState>('shared/sync', {})); setMessage('Sync checked. Agent results are updated below.'); })}><RefreshCw size={14} className={busy ? 'spin' : ''} aria-hidden="true" />Sync now</Button>
              <Button size="sm" disabled={busy} onClick={() => openHook()}><Plus size={14} aria-hidden="true" />Add hook</Button>
            </div>
          </PanelHeading>
          <div className="row-list">
            {state.value.hooks.map(hook => {
              const optedOut = (hook.disabledAgents || []).length;
              return (
                <details className="hook-item" key={hook.id}>
                  <summary className="row">
                    <Avatar name={hook.id}><Workflow size={16} aria-hidden="true" /></Avatar>
                    <div className="row-copy">
                      <h3>{hookName(hook)}<Badge variant="secondary">{typeNames[hookType(hook)]}</Badge></h3>
                      <small>{eventNames[hook.event]}{hook.skill && ` · skill ${hook.skill}`}{optedOut ? ` · ${optedOut} ${optedOut === 1 ? 'agent' : 'agents'} opted out` : ''}</small>
                    </div>
                    <Button variant="ghost" size="sm" disabled={busy} onClick={event => { event.preventDefault(); openHook(hook); }}>Edit</Button>
                    <Button variant="ghost" size="sm" disabled={busy} onClick={event => { event.preventDefault(); removeHook(hook); }}>Remove</Button>
                    <span onClick={event => event.preventDefault()}>
                      <Toggle on={hook.enabled} label={`Enable ${hookName(hook)} for all agents`} disabled={busy} onChange={() => stage({ ...state.value, hooks: state.value.hooks.map(item => item.id === hook.id ? { ...item, enabled: !item.enabled } : item) })} />
                    </span>
                  </summary>
                  <div className="hook-body">
                    <h4>Agents</h4>
                    {hookAgents(hook)}
                    {hasContext(hook) && <><h4>Injected context</h4>{hookContext(hook)}</>}
                    {hook.command && <><h4>Command</h4><pre className="hook-context-text">{hook.command}</pre></>}
                  </div>
                </details>
              );
            })}
          </div>
          {!state.value.hooks.length && <Empty icon={<Workflow size={22} aria-hidden="true" />}>No shared hooks yet.</Empty>}
        </section>
      )}

      <section className="panel">
        <PanelHeading title="Agent sync status" badge={`${available.length} detected`} description="Configuration checks only. Connection health, OAuth, and project overrides need each agent’s own tools." />
        <div className="parity-targets padded">
          {available.map(target => {
            const synced = target.status === 'synced';
            const label = synced ? 'Synced' : target.status === 'unsupported' ? 'No adapter' : target.status === 'error' ? 'Blocked' : 'Needs attention';
            return (
              <details className={`parity-target ${synced ? 'synced' : 'drift'}`} key={target.id}>
                <summary>
                  {synced ? <Check size={14} aria-hidden="true" /> : <CircleHelp size={14} aria-hidden="true" />}
                  <strong>{target.name}</strong>
                  <span>{label}{section === 'servers' ? ` · ${target.matched}/${enabledServers} servers` : ` · ${target.hooks ? 'context hooks' : 'no context hooks'}${target.commandHooks ? ', commands' : ''}`}</span>
                </summary>
                {section === 'servers' && !!target.extra.length && <p>Additional native servers: {target.extra.join(', ')}</p>}
                {target.issues.length ? <ul>{target.issues.map((issue, index) => <li key={index}>{issue}</li>)}</ul> : <p>No issues reported.</p>}
                {!!target.notes?.length && <ul className="notes">{target.notes.map((note, index) => <li key={index}>{note}</li>)}</ul>}
              </details>
            );
          })}
        </div>
        {!!missing.length && <div className="panel-footer">Not detected: {missing.map(target => target.name).join(', ')}. They join automatically when their command or config directory appears.</div>}
      </section>

      <p className="footnote">Source of truth: <code className="path">{state.path}</code>. Native files are generated from it and each write keeps a private backup under <code className="path">~/.local/share/agent-hub/shared-backups/</code>. Do not put secrets in server definitions or hook commands.</p>

      <Dialog open={!!editor || !!preview} onOpenChange={open => { if (!open) close(); }}>
        <DialogContent className="editor-dialog">
          <DialogHeader>
            <DialogTitle>{preview ? 'Review changes' : editor === 'server' ? original ? 'Edit MCP server' : 'Add MCP server' : original ? 'Edit shared hook' : 'Add shared hook'}</DialogTitle>
            <DialogDescription>{preview ? 'Saving writes these changes to every supported detected agent.' : editor === 'server' ? 'Use type "stdio" with command, args, and env, or "http" with url and headers.' : 'Context text, a shared skill reference, or a native command. Agents can opt out individually.'}</DialogDescription>
          </DialogHeader>
          {preview ? (
            <div className="diff-view" aria-label="Shared setup changes">{diffLines(format(state.value), format(preview)).map((part, index) => <pre className={part.added ? 'diff-added' : part.removed ? 'diff-removed' : ''} key={index}>{part.value}</pre>)}</div>
          ) : editor === 'hook' ? hookForm() : (
            <div className="form">
              <label htmlFor="shared-server-name">Server name<Input id="shared-server-name" value={name} onChange={event => setName(event.target.value)} maxLength={80} required /></label>
              <label htmlFor="shared-configuration">Configuration (JSON)<textarea id="shared-configuration" className="code-editor" value={draft} onChange={event => setDraft(event.target.value)} spellCheck={false} rows={12} /></label>
            </div>
          )}
          {error && <p className="dialog-error" role="alert">{error}</p>}
          <div className="dialog-actions">
            <Button variant="outline" disabled={busy} onClick={close}>Cancel</Button>
            {preview && editor && <Button variant="outline" disabled={busy} onClick={() => setPreview(undefined)}>Back to editor</Button>}
            <Button disabled={busy} onClick={() => preview ? void action(save) : review()}>
              {busy ? <LoaderCircle size={15} className="spin" aria-hidden="true" /> : <GitCompareArrows size={15} aria-hidden="true" />}{preview ? 'Save & sync' : 'Review changes'}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
