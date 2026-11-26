import { useEffect, useState } from 'react';
import { Check, ExternalLink, Search } from 'lucide-react';
import { Input } from '../components/ui/input';
import { Badge } from '../components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '../components/ui/dialog';
import { Empty, PanelHeading, ToolIcon } from '../components/common';
import { api } from '../api';
import type { Tool } from '../api';
import type { Workspace } from '../App';

const capabilityNames: Record<string, string> = { skills: 'Skills', plugins: 'Plugins', hooks: 'Hooks', instructions: 'Instructions', usage: 'Usage' };
const COMPUTER_SERVER = 'cua-driver';
type Shared = { value: { servers: Record<string, { enabled: boolean }> }; targets: { id: string; available: boolean; mcp: boolean; status: string }[] };

export function Agents({ workspace }: { workspace: Workspace }) {
  const { state } = workspace;
  const [search, setSearch] = useState('');
  const [inspect, setInspect] = useState<Tool>();
  const [shared, setShared] = useState<Shared | null>();
  useEffect(() => { api<Shared>('shared').then(setShared).catch(() => setShared(null)); }, [state.refreshedAt]);
  const computerControl = (tool: Tool) => {
    if (!shared) return shared === null ? 'Unknown' : 'Checking…';
    const target = shared.targets.find(target => target.id === tool.id);
    if (!target?.mcp) return 'No MCP adapter';
    if (!target.available) return 'Not installed';
    if (!shared.value.servers[COMPUTER_SERVER]?.enabled) return 'Off';
    return target.status === 'synced' ? 'On' : 'Not synced';
  };
  const matches = (tool: Tool) => `${tool.name} ${tool.note}`.toLowerCase().includes(search.toLowerCase());
  const installed = state.tools.filter(tool => tool.installed && matches(tool));
  const others = state.tools.filter(tool => !tool.installed && matches(tool));

  const table = (tools: Tool[]) => (
    <div className="table-scroll agents-table">
      <table className="stack">
        <thead><tr><th>Agent</th><th>Kind</th><th>Notes</th><th>Managed by Agent Hub</th><th>Computer control</th></tr></thead>
        <tbody>
          {tools.map(tool => (
            <tr key={tool.id}>
              <td><div className="agent-name"><ToolIcon tool={tool} size={20} /><h3><button type="button" className="row-link" onClick={() => setInspect(tool)}>{tool.name}</button></h3></div></td>
              <td data-label="Kind">{tool.kind}</td>
              <td data-label="Notes">{tool.note}</td>
              <td data-label="Managed by Agent Hub">{tool.capabilities.length ? tool.capabilities.map(capability => capabilityNames[capability] ?? capability).join(', ') : <span className="muted">No adapter yet</span>}</td>
              <td data-label="Computer control" className={computerControl(tool) === 'On' ? undefined : 'muted'}>{computerControl(tool)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  return (
    <>
      <div className="toolbar">
        <div className="search-field"><Search size={16} aria-hidden="true" /><Input aria-label="Search agents" placeholder="Search agents…" value={search} onChange={event => setSearch(event.target.value)} /></div>
      </div>
      <section className="panel">
        <PanelHeading title="Installed on this Mac" badge={installed.length} description="Capabilities show what Agent Hub can manage for each tool." />
        {installed.length ? table(installed) : <Empty>No installed agent matches this search.</Empty>}
      </section>
      <details className="panel catalog-rest" open={!!search}>
        <summary>Not detected on this Mac ({others.length})</summary>
        <p className="muted">Catalogue entries join automatically once their command or configuration directory appears.</p>
        {table(others)}
      </details>

      <Dialog open={!!inspect} onOpenChange={open => { if (!open) setInspect(undefined); }}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle><span className="tool-heading"><ToolIcon tool={inspect} size={28} />{inspect?.name}</span></DialogTitle>
            <DialogDescription>{inspect?.note}</DialogDescription>
          </DialogHeader>
          {inspect && (
            <>
              <div className="badge-row">
                <Badge variant="secondary">{inspect.installed ? 'Installed locally' : 'Not detected locally'}</Badge>
                <Badge variant="secondary">{inspect.kind}</Badge>
                {inspect.subscription && <Badge variant="secondary">{inspect.subscription}</Badge>}
                <Badge variant="secondary">Computer control: {computerControl(inspect)}</Badge>
              </div>
              <h3 className="dialog-subheading">Managed by Agent Hub</h3>
              <div className="capability-list">
                {inspect.capabilities.map(capability => <span key={capability}><Check size={15} aria-hidden="true" />{capabilityNames[capability] ?? capability}</span>)}
                {!inspect.capabilities.length && <p>Nothing yet. Configure this tool in its own app.</p>}
              </div>
              <div className="dialog-actions">
                <a className="external-button" href={inspect.url} target="_blank" rel="noreferrer">Open docs<ExternalLink size={15} aria-hidden="true" /></a>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
}
