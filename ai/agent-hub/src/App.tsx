import { useCallback, useEffect, useRef, useState } from 'react';
import { Blocks, Bot, Check, CircleHelp, FileText, LayoutDashboard, LoaderCircle, Moon, RefreshCw, Server, Sparkles, Sun, Workflow, X } from 'lucide-react';
import { Logo } from './components/common';
import { Button } from './components/ui/button';
import { api, type FileData, type State, type Tool } from './api';
import { SharedSetup } from './components/SharedSetup';
import { DocumentEditor } from './components/DocumentEditor';
import { Dashboard } from './pages/Dashboard';
import { Agents } from './pages/Agents';
import { Skills } from './pages/Skills';
import { Plugins } from './pages/Plugins';
import { Instructions } from './pages/Instructions';
import './styles.css';

export type Workspace = {
  state: State;
  busy: boolean;
  action: (work: () => Promise<unknown>, success?: string) => Promise<void>;
  notify: (message: string) => void;
  refresh: () => Promise<State>;
  edit: (id: string) => void;
  tool: (id: string) => Tool | undefined;
};

const pages = [
  { id: 'dashboard', name: 'Dashboard', icon: LayoutDashboard, group: 'Overview', description: 'Recorded activity across your local agents.' },
  { id: 'agents', name: 'Agents', icon: Bot, group: 'Overview', description: 'Detected tools and what Agent Hub can manage for each.' },
  { id: 'skills', name: 'Skills', icon: Sparkles, group: 'Configuration', description: 'One shared skill library, exported to every supported agent.' },
  { id: 'hooks', name: 'Hooks', icon: Workflow, group: 'Configuration', description: 'Context and command hooks shared across agents, with per-agent opt-outs.' },
  { id: 'setup', name: 'MCP servers', icon: Server, group: 'Configuration', description: 'MCP servers defined once and synced to every supported agent.' },
  { id: 'plugins', name: 'Plugins', icon: Blocks, group: 'Configuration', description: 'Native plugins per agent. Installation stays in each agent’s marketplace.' },
  { id: 'instructions', name: 'Instructions', icon: FileText, group: 'Configuration', description: 'Global and project instruction files, plus the managed configuration behind them.' },
] as const;
type PageId = (typeof pages)[number]['id'];

function route(): PageId {
  const value = location.hash.slice(1);
  return pages.some(page => page.id === value) ? (value as PageId) : 'dashboard';
}

function systemTheme() {
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

export default function App() {
  const [page, setPage] = useState<PageId>(route);
  const [state, setState] = useState<State>();
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [theme, setTheme] = useState(() => localStorage.getItem('agent-hub-theme') || systemTheme());
  const [file, setFile] = useState<FileData>();
  const main = useRef<HTMLElement>(null);

  const refresh = useCallback(async () => { const next = await api<State>('state'); setState(next); return next; }, []);
  const action = useCallback(async (work: () => Promise<unknown>, success?: string) => {
    setBusy(true); setError(''); setMessage('');
    try { await work(); if (success) setMessage(success); }
    catch (failure) { setError(failure instanceof Error ? failure.message : 'The action failed. Please retry.'); }
    finally { setBusy(false); }
  }, []);
  const edit = useCallback((id: string) => {
    void action(async () => setFile(await api<FileData>(`document?id=${encodeURIComponent(id)}`)));
  }, [action]);

  useEffect(() => { void action(refresh); }, [action, refresh]);
  useEffect(() => {
    const change = () => { setPage(route()); window.scrollTo({ top: 0 }); main.current?.focus({ preventScroll: true }); };
    window.addEventListener('hashchange', change);
    return () => window.removeEventListener('hashchange', change);
  }, []);
  useEffect(() => { document.documentElement.dataset.theme = theme; localStorage.setItem('agent-hub-theme', theme); }, [theme]);
  useEffect(() => {
    if (!message) return;
    const timer = setTimeout(() => setMessage(''), 6000);
    return () => clearTimeout(timer);
  }, [message]);

  const current = pages.find(item => item.id === page)!;
  const workspace: Workspace | undefined = state && { state, busy, action, notify: setMessage, refresh, edit, tool: id => state.tools.find(tool => tool.id === id) };
  const enabledSkills = state?.skills.filter(skill => skill.enabled).length ?? 0;

  return (
    <div className="app-shell">
      <a href="#main" className="skip-link">Skip to content</a>
      <aside className="sidebar">
        <a href="#dashboard" className="brand"><Logo size={30} /><span>Agent Hub</span></a>
        <nav aria-label="Main navigation">
          {['Overview', 'Configuration'].map(group => (
            <div key={group} className="nav-group">
              <div className="nav-label">{group}</div>
              {pages.filter(item => item.group === group).map(item => (
                <a key={item.id} href={`#${item.id}`} className={page === item.id ? 'nav-item active' : 'nav-item'} aria-current={page === item.id ? 'page' : undefined} title={item.name}>
                  <item.icon size={17} aria-hidden="true" />
                  <span>{item.name}</span>
                  {item.id === 'skills' && state && <span className="nav-count">{enabledSkills}</span>}
                </a>
              ))}
            </div>
          ))}
        </nav>
        <div className="sidebar-bottom">
          <div className="service-status">
            <span className={`status-dot ${state?.service.running ? 'ok' : 'neutral'}`} aria-hidden="true" />
            <span>
              <strong>{state ? state.service.running ? 'Service running' : 'Service not installed' : 'Connecting…'}</strong>
              {state && <small>{state.service.url.replace(/^https?:\/\//, '')}</small>}
            </span>
          </div>
          <Button variant="ghost" size="icon" aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} theme`} onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}>
            {theme === 'dark' ? <Sun size={17} /> : <Moon size={17} />}
          </Button>
        </div>
      </aside>

      <main id="main" ref={main} tabIndex={-1}>
        <div className="page-heading">
          <div>
            <h1>{current.name}</h1>
            <p>{current.description}</p>
          </div>
          <Button variant="outline" size="sm" disabled={busy} onClick={() => void action(refresh, 'Workspace refreshed.')}>
            <RefreshCw size={14} className={busy ? 'spin' : ''} aria-hidden="true" /> Refresh
          </Button>
        </div>

        {error && (
          <div className="notice danger" role="alert">
            <CircleHelp size={16} aria-hidden="true" /><span>{error}</span>
            <button type="button" className="notice-dismiss" onClick={() => setError('')} aria-label="Dismiss error"><X size={14} /></button>
          </div>
        )}

        {!workspace ? (
          <div className="initial-loading">
            {busy ? <><LoaderCircle className="spin" size={24} aria-hidden="true" /><p>Connecting to the local service…</p></> : <><CircleHelp size={24} aria-hidden="true" /><p>Unable to reach the local service. Refresh to retry.</p></>}
          </div>
        ) : (
          <>
            {page === 'dashboard' && <Dashboard workspace={workspace} />}
            {page === 'agents' && <Agents workspace={workspace} />}
            {page === 'skills' && <Skills workspace={workspace} />}
            {page === 'plugins' && <Plugins workspace={workspace} />}
            {page === 'hooks' && <SharedSetup section="hooks" refreshKey={state!.refreshedAt} onEditContext={edit} />}
            {page === 'setup' && <SharedSetup section="servers" refreshKey={state!.refreshedAt} onEditContext={edit} />}
            {page === 'instructions' && <Instructions workspace={workspace} />}
            {!!state!.warnings.length && (
              <details className="data-notes">
                <summary><CircleHelp size={15} aria-hidden="true" /> Workspace notes ({state!.warnings.length})</summary>
                <ul>{state!.warnings.map((warning, index) => <li key={index}>{warning}</li>)}</ul>
              </details>
            )}
          </>
        )}
      </main>

      <div className="toast-region" aria-live="polite" aria-atomic="true">
        {message && <div className="toast"><Check size={16} aria-hidden="true" />{message}</div>}
      </div>

      {workspace && <DocumentEditor workspace={workspace} file={file} onFile={setFile} />}
    </div>
  );
}
