import { useEffect, useState } from 'react';
import { Check, CircleHelp, GitCompareArrows, LoaderCircle, Plus, RefreshCw, Server, Sparkles, Workflow } from 'lucide-react';
import { diffLines } from 'diff';
import { api } from '../api';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from './ui/dialog';

type ServerConfig = { type: 'stdio' | 'http'; command?: string; args?: string[]; env?: Record<string, string>; url?: string; headers?: Record<string, string>; enabled: boolean };
type HookConfig = { id: string; event: 'sessionStart' | 'beforeTool' | 'afterTool' | 'stop'; command?: string; text?: string; skill?: string; context?: 'adhd' | 'ponytail' | 'plannotator'; enabled: boolean; disabledAgents?: string[] };
type Setup = { servers: Record<string, ServerConfig>; hooks: HookConfig[] };
type SharedState = {
  value: Setup; revision: string; path: string; pending: boolean;
  targets: { id: string; name: string; available: boolean; mcp: boolean; hooks: boolean; commandHooks?: boolean; status: string; matched: number; issues: string[]; extra: string[] }[];
  imports: { tool: string; name: string; revision: string }[];
  contexts: Record<string, { content?: string; path?: string; documentId?: string; error?: string }>;
  skills: { name: string; description: string }[];
};
const eventNames = { sessionStart: 'Session context', beforeTool: 'Before tool use', afterTool: 'After tool use', stop: 'Response complete' };
const contextNames = { adhd: 'ADHD', ponytail: 'Ponytail', plannotator: 'Plannotator' };
const hasContext = (hook: HookConfig) => hook.context !== undefined || hook.text !== undefined || hook.skill !== undefined;
const format = (value: unknown) => JSON.stringify(value, null, 2);

export function SharedSetup({ refreshKey, hooksOnly = false, onEditContext }: { refreshKey: string; hooksOnly?: boolean; onEditContext: (id: string) => void }) {
  const [state, setState] = useState<SharedState>();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');
  const [editor, setEditor] = useState<'server' | 'hook'>();
  const [original, setOriginal] = useState<string>();
  const [name, setName] = useState('');
  const [draft, setDraft] = useState('');
  const [preview, setPreview] = useState<Setup>();
  const [hookType, setHookType] = useState<'text' | 'skill' | 'command' | 'preset'>('text');
  const [hookText, setHookText] = useState('');
  const [hookSkill, setHookSkill] = useState('');
  const [hookCommand, setHookCommand] = useState('');
  const [hookEvent, setHookEvent] = useState<HookConfig['event']>('afterTool');
  const [initialForm, setInitialForm] = useState('');
  const currentForm = JSON.stringify(editor === 'server' ? [name, draft] : [name, hookType, hookType === 'text' ? hookText : hookType === 'skill' ? hookSkill : hookType === 'command' ? hookCommand : undefined, hookType === 'command' ? hookEvent : undefined]);
  const dirty = editor ? currentForm !== initialForm : !!preview && !!state && format(preview) !== format(state.value);

  async function load() { const next = await api<SharedState>('shared'); setState(next); }
  useEffect(() => { let active = true; void api<SharedState>('shared').then(next => { if (active) setState(next); }).catch(cause => { if (active) setError(cause.message); }); return () => { active = false; }; }, [refreshKey]);
  useEffect(() => {
    if (!dirty) return;
    const guard = (event: BeforeUnloadEvent) => event.preventDefault();
    window.addEventListener('beforeunload', guard); return () => window.removeEventListener('beforeunload', guard);
  }, [dirty]);
  async function action(work: () => Promise<void>) {
    setBusy(true); setError(''); setMessage('');
    try { await work(); } catch (cause) { setError(cause instanceof Error ? cause.message : 'Shared setup failed. Refresh and retry.'); }
    finally { setBusy(false); }
  }
  function close() {
    if (busy || dirty && !window.confirm('Discard this configuration draft?')) return;
    setEditor(undefined); setPreview(undefined);
  }
  function openServer(id?: string) {
    const content = format(id ? state?.value.servers[id] : { type: 'stdio', command: 'npx', args: ['-y', '@modelcontextprotocol/server-everything'], env: {}, enabled: true });
    setError(''); setOriginal(id); setName(id || ''); setDraft(content); setInitialForm(JSON.stringify([id || '', content])); setEditor('server');
  }
  function openHook(hook?: HookConfig) {
    setError(''); setOriginal(hook?.id); setName(hook?.id || '');
    const type = hook?.context ? 'preset' : hook?.skill !== undefined ? 'skill' : hook?.command !== undefined ? 'command' : 'text';
    setHookType(type);
    setInitialForm(JSON.stringify([hook?.id || '', type, type === 'text' ? hook?.text || '' : type === 'skill' ? hook?.skill || '' : type === 'command' ? hook?.command || '' : undefined, type === 'command' ? hook?.event || 'afterTool' : undefined]));
    setHookText(hook?.text || ''); setHookSkill(hook?.skill || ''); setHookCommand(hook?.command || ''); setHookEvent(hook?.event || 'afterTool'); setEditor('hook');
  }
  function review() {
    if (!state) return;
    try {
      const next = structuredClone(state.value);
      if (editor === 'server') {
        const value = JSON.parse(draft);
        if (!/^[a-zA-Z0-9][a-zA-Z0-9_-]{0,79}$/.test(name)) throw new Error('Use a server name with letters, numbers, underscores, and hyphens.');
        if (name !== original && Object.hasOwn(next.servers, name)) throw new Error('A shared server already has this name.');
        if (original) delete next.servers[original];
        Object.defineProperty(next.servers, name, { value, enumerable: true });
      } else {
        if (!/^[a-zA-Z0-9][a-zA-Z0-9_-]{0,79}$/.test(name)) throw new Error('Use a hook name with letters, numbers, underscores, and hyphens.');
        const existing = state.value.hooks.find(hook => hook.id === original);
        const value: HookConfig = { id: name, event: hookType === 'command' ? hookEvent : 'sessionStart', enabled: existing?.enabled ?? true, disabledAgents: existing?.disabledAgents || [] };
        if (hookType === 'text') { if (!hookText.trim()) throw new Error('Enter the context text.'); value.text = hookText; }
        if (hookType === 'skill') { if (!state.skills.some(skill => skill.name === hookSkill)) throw new Error('Choose a shared skill.'); value.skill = hookSkill; }
        if (hookType === 'command') { if (!hookCommand.trim()) throw new Error('Enter a command.'); value.command = hookCommand; }
        if (hookType === 'preset') value.context = existing?.context;
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
    setMessage('Shared setup saved. Inspect each agent’s sync status below. Restart agents to load changes.');
  }
  function hookAgents(hook: HookConfig) {
    if (!state) return null;
    return <details className="shared-imports hook-agent-preferences"><summary>Choose agents · {(hook.disabledAgents || []).length} opted out</summary><p>Shared content stays identical. Switching an agent off removes only this hook from its exports. Start a new session after changing context hooks.</p><div className="hook-agent-switches">{state.targets.filter(target => target.available).map(target => {
      const supported = hasContext(hook) ? target.hooks : !!target.commandHooks;
      const active = hook.enabled && !(hook.disabledAgents || []).includes(target.id);
      return <label className="hook-agent-switch" key={target.id}><span>{target.name}<small>{supported ? active ? 'On' : 'Off' : 'Unsupported'}</small></span><button className={`toggle ${active && supported ? 'on' : ''}`} role="switch" aria-checked={active && supported} aria-label={`Enable ${hook.context ? contextNames[hook.context] : hook.id} for ${target.name}`} disabled={busy || !supported || !hook.enabled} onClick={() => {
        const disabledAgents = active ? [...(hook.disabledAgents || []), target.id] : (hook.disabledAgents || []).filter(id => id !== target.id);
        setPreview({ ...state.value, hooks: state.value.hooks.map(item => item.id === hook.id ? { ...item, disabledAgents } : item) });
      }}><span /></button></label>;
    })}</div></details>;
  }
  function hookContext(hook: HookConfig) {
    if (!hasContext(hook) || !state) return null;
    const context = state.contexts[hook.id]; const label = hook.context ? contextNames[hook.context] : hook.id;
    return <details className="shared-imports hook-context"><summary>View context · {label}</summary><p>This is the exact text injected when this hook is enabled. It gives the agent instructions; it does not execute or enforce them.</p>{context?.path && <p className="file-location">Source: <code>{context.path}</code></p>}{context?.content ? <pre className="hook-context-text" tabIndex={0} aria-label={`${label} injected context`}>{context.content}</pre> : <p role="alert">{context?.error || 'Context unavailable. Refresh to retry.'}</p>}<Button variant="outline" size="sm" disabled={busy} onClick={() => context?.documentId ? onEditContext(context.documentId) : openHook(hook)}>Edit context</Button></details>;
  }
  function hookForm() {
    const existing = state?.value.hooks.find(hook => hook.id === original);
    return <div className="skill-form"><label htmlFor="hook-name">Hook name<Input id="hook-name" value={name} onChange={event => setName(event.target.value)} maxLength={80} placeholder="my-hook" /></label><label htmlFor="hook-type">Hook type<select id="hook-type" value={hookType} onChange={event => setHookType(event.target.value as typeof hookType)}><option value="text">Context text</option><option value="skill">Skill reference</option><option value="command">Command</option>{existing?.context && <option value="preset">Existing shared source</option>}</select></label>
      {hookType === 'text' && <label htmlFor="hook-text">Context text<textarea id="hook-text" rows={8} value={hookText} onChange={event => setHookText(event.target.value)} placeholder="Instructions to add to the agent’s context…" /><small>Saved in shared configuration. Loaded into new sessions; no command is executed.</small></label>}
      {hookType === 'skill' && <label htmlFor="hook-skill">Shared skill<select id="hook-skill" value={hookSkill} onChange={event => setHookSkill(event.target.value)}><option value="">Choose a shared skill</option>{state?.skills.map(skill => <option key={skill.name} value={skill.name}>{skill.name}</option>)}</select><small>Loads the current SKILL.md instructions each time this hook runs. This does not run the skill’s scripts.</small></label>}
      {hookType === 'command' && <><label htmlFor="hook-event">Event<select id="hook-event" value={hookEvent} onChange={event => setHookEvent(event.target.value as HookConfig['event'])}>{Object.entries(eventNames).map(([value, label]) => <option key={value} value={value}>{label}</option>)}</select></label><label htmlFor="hook-command">Command<textarea id="hook-command" rows={4} value={hookCommand} onChange={event => setHookCommand(event.target.value)} placeholder="/absolute/path/to/hook-script" /><small>Runs in the agent’s native hook runtime and receives native event JSON.</small></label></>}
      {hookType === 'preset' && <p className="shared-note">Uses the existing {existing?.context && contextNames[existing.context]} source. Use View context → Edit context to change its instructions.</p>}
    </div>;
  }
  if (!state) return <div className="empty">{error ? <><p role="alert">{error}</p><Button onClick={() => void action(load)}>Retry</Button></> : <><LoaderCircle className="spin" aria-hidden="true" /><p>Loading shared setup…</p></>}</div>;
  const enabled = Object.values(state.value.servers).filter(server => server.enabled).length;
  const available = state.targets.filter(target => target.available);
  return <div className="shared-setup">
    <div aria-live="polite">{message && <p className="notice success"><Check size={17} aria-hidden="true" />{message}</p>}</div>
    {error && !editor && !preview && <p className="notice danger" role="alert">{error}</p>}
    <section className="library-banner"><span className="library-banner-icon"><Server size={25} aria-hidden="true" /></span><div className="library-banner-copy"><h2>Configure once. Sync every agent.</h2><p>{enabled} enabled MCP servers · {state.value.hooks.filter(hook => hook.enabled).length} enabled shared hooks</p><p className="library-runtime-note">Saves update supported agents immediately. Background sync runs every 60 seconds and includes newly detected agents.</p></div><Button variant="outline" disabled={busy || state.pending} onClick={() => void action(async () => { setState(await api<SharedState>('shared/sync', {})); setMessage('Sync checked. Inspect agent results below.'); })}><RefreshCw size={15} className={busy ? 'spin' : ''} aria-hidden="true" />Sync now</Button></section>
    {state.pending && <p className="notice danger" role="alert">An interrupted sync needs recovery. Restart Agent Hub; inspect its private journal if recovery reports a conflict.</p>}
    {!hooksOnly && <>
    <section className="panel"><div className="panel-heading"><div><h2>MCP servers</h2><p>Stdio commands and Streamable HTTP endpoints shared across supported agents.</p></div><Button disabled={busy} onClick={() => openServer()}><Plus size={16} aria-hidden="true" />Add MCP server</Button></div>
      {Object.entries(state.value.servers).map(([id, server]) => <div className="integration-row" key={id}><Server size={22} aria-hidden="true" /><div className="integration-copy"><h3>{id}</h3><p>{server.type === 'stdio' ? server.command : 'Streamable HTTP'} · {server.enabled ? 'Enabled' : 'Disabled'}</p></div><Button variant="outline" size="sm" disabled={busy} onClick={() => openServer(id)}>Edit</Button><button className={`toggle ${server.enabled ? 'on' : ''}`} role="switch" aria-checked={server.enabled} aria-label={`Enable ${id}`} disabled={busy} onClick={() => setPreview({ ...state.value, servers: { ...state.value.servers, [id]: { ...server, enabled: !server.enabled } } })}><span /></button><Button variant="ghost" size="sm" disabled={busy} onClick={() => { const next = structuredClone(state.value); delete next.servers[id]; setPreview(next); }}>Remove</Button></div>)}
      {!Object.keys(state.value.servers).length && <div className="empty"><Server size={26} aria-hidden="true" /><p>Add a server or import an existing native server below.</p></div>}
      {!!state.imports.length && <details className="shared-imports"><summary>Import existing servers ({state.imports.length})</summary><p>Imports copy MCP settings into .dotfiles/ai. Do not import inline credentials. Native-only options need manual setup. Conflicting names remain unchanged and appear in sync status.</p>{state.imports.map(item => <div className="integration-row" key={`${item.tool}:${item.name}`}><div className="integration-copy"><strong>{item.name}</strong><p>{state.targets.find(target => target.id === item.tool)?.name}</p></div><Button variant="outline" size="sm" disabled={busy} onClick={() => { if (!window.confirm(`Share ${item.name} from native settings into .dotfiles/ai and share it with all supported agents?`)) return; void action(async () => { setState(await api<SharedState>('shared/import', { ...item, sourceRevision: state.revision })); setMessage('Server imported. Inspect sync status for conflicts or unsupported settings.'); }); }}>Import & sync</Button></div>)}</details>}
    </section>
    </>}
    <section className="panel"><div className="panel-heading"><div><h2>Shared hooks</h2><p>ADHD, Ponytail, and Plannotator share one source. Set defaults here, then choose agents below.</p></div><Button variant="outline" disabled={busy} onClick={() => openHook()}><Plus size={16} aria-hidden="true" />Add hook</Button></div>
      <p className="shared-note">Context hooks load repository instructions into new sessions. Per-agent switches never change the shared content. Custom command hooks receive native event JSON.</p>
      {state.value.hooks.map(hook => <div className="shared-hook" key={hook.id}><div className="integration-row"><Workflow size={22} aria-hidden="true" /><div className="integration-copy"><h3>{hook.context ? contextNames[hook.context] : hook.id}</h3><p>{eventNames[hook.event]} · Shared default {hook.enabled ? 'on' : 'off'}</p></div><Button variant="outline" size="sm" disabled={busy} onClick={() => openHook(hook)}>Edit</Button><button className={`toggle ${hook.enabled ? 'on' : ''}`} role="switch" aria-checked={hook.enabled} aria-label={`Enable ${hook.id} shared default`} disabled={busy} onClick={() => setPreview({ ...state.value, hooks: state.value.hooks.map(item => item.id === hook.id ? { ...item, enabled: !item.enabled } : item) })}><span /></button><Button variant="ghost" size="sm" disabled={busy} onClick={() => setPreview({ ...state.value, hooks: state.value.hooks.filter(item => item.id !== hook.id) })}>Remove</Button></div>{hookContext(hook)}{hookAgents(hook)}</div>)}
      {!state.value.hooks.length && <div className="empty"><Workflow size={26} aria-hidden="true" /><p>Add an action for before tool use, after tool use, or response completion.</p></div>}
    </section>
    {!hooksOnly && <>
    <section className="panel"><div className="panel-heading"><div><h2>Shared skills</h2><p>Skills already use the repository library. New skills and enablement changes sync automatically.</p></div><a className="text-button" href="#skills"><Sparkles size={16} aria-hidden="true" />Open skill library</a></div><p className="shared-note">The Skills page shows enabled-set checks and native discovery limitations for each managed agent.</p></section>
    </>}
    <section className="panel"><div className="panel-heading"><div><h2>Agent sync status</h2><p>Configuration checks only. Connection health, OAuth login, and project overrides require the agent’s native tools.</p></div><Badge variant="secondary">{available.length} detected</Badge></div><div className="parity-targets">{available.map(target => <div className={`parity-target ${target.status === 'synced' ? 'synced' : 'drift'}`} key={target.id}><strong>{target.name}</strong><span>{target.status === 'synced' ? 'Configuration synced' : target.status === 'unsupported' ? 'Adapter unavailable' : target.status === 'error' ? 'Sync blocked' : 'Needs attention'} · {target.matched}/{enabled} enabled MCP servers</span><span>Shared context hooks: {target.hooks ? 'Supported' : 'Unsupported'}</span>{!!target.extra.length && <p>Additional native servers: {target.extra.join(', ')}</p>}{!!target.issues.length && <ul>{target.issues.map((issue, index) => <li key={index}>{issue}</li>)}</ul>}</div>)}</div><details className="shared-imports"><summary>Agents not detected ({state.targets.length - available.length})</summary><p>{state.targets.filter(target => !target.available).map(target => target.name).join(', ')}</p><p>Supported agents join automatically when their command or configuration directory appears.</p></details></section>
    <details className="shared-imports"><summary><CircleHelp size={15} aria-hidden="true" />Storage and recovery</summary><p>The source of truth lives in .dotfiles/ai: <code>{state.path}</code>. Native files are generated from this source. Do not put secrets in server definitions or hook commands.</p><p>Each write keeps a private backup under ~/.local/share/agent-hub/shared-backups/. Interrupted writes roll back on restart. Restart agents after setup changes.</p></details>
    <Dialog open={!!editor || !!preview} onOpenChange={open => { if (!open) close(); }}><DialogContent className="editor-dialog"><DialogHeader><DialogTitle>{preview ? 'Review shared setup changes' : editor === 'server' ? original ? 'Edit MCP server' : 'Add MCP server' : original ? 'Edit shared hook' : 'Add shared hook'}</DialogTitle><DialogDescription>{preview ? 'Saving applies these changes to every supported detected agent. Conflicts remain visible below.' : editor === 'server' ? 'Use stdio with command, args, and env; or http with url and headers. Keep enabled as a boolean.' : 'Choose context text, a reference to a shared skill, or a native command. The hook is shared with supported agents; each agent can opt out.'}</DialogDescription></DialogHeader>
      {preview ? <div className="diff-view" aria-label="Shared setup changes">{diffLines(format(state.value), format(preview)).map((part, index) => <pre className={part.added ? 'diff-added' : part.removed ? 'diff-removed' : ''} key={index}>{part.value}</pre>)}</div> : editor === 'hook' ? hookForm() : <div className="skill-form">{editor === 'server' && <label htmlFor="shared-server-name">Server name<Input id="shared-server-name" value={name} onChange={event => setName(event.target.value)} maxLength={80} required /></label>}<label htmlFor="shared-configuration">Server configuration (JSON)<textarea id="shared-configuration" className="code-editor" value={draft} onChange={event => setDraft(event.target.value)} spellCheck={false} rows={12} /></label></div>}
      {error && <p className="dialog-error" role="alert">{error}</p>}<div className="dialog-actions"><Button variant="outline" disabled={busy} onClick={close}>Cancel</Button>{preview && editor && <Button variant="outline" disabled={busy} onClick={() => setPreview(undefined)}>Back to editor</Button>}<Button disabled={busy} onClick={() => preview ? void action(save) : review()}>{busy ? <LoaderCircle size={15} className="spin" aria-hidden="true" /> : <GitCompareArrows size={15} aria-hidden="true" />}{preview ? 'Save & sync all' : 'Review changes'}</Button></div>
    </DialogContent></Dialog>
  </div>;
}
