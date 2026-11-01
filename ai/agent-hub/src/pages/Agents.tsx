import { useState } from 'react';
import { Check, ExternalLink, Search } from 'lucide-react';
import { Input } from '../components/ui/input';
import { Badge } from '../components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '../components/ui/dialog';
import { Empty, ToolIcon } from '../components/common';
import type { Tool } from '../api';
import type { Workspace } from '../App';

const capabilityNames: Record<string, string> = { skills: 'Skills', plugins: 'Plugins', hooks: 'Hooks', instructions: 'Instructions', usage: 'Usage' };

export function Agents({ workspace }: { workspace: Workspace }) {
  const { state } = workspace;
  const [search, setSearch] = useState('');
  const [inspect, setInspect] = useState<Tool>();
  const matches = (tool: Tool) => `${tool.name} ${tool.note}`.toLowerCase().includes(search.toLowerCase());
  const installed = state.tools.filter(tool => tool.installed && matches(tool));
  const others = state.tools.filter(tool => !tool.installed && matches(tool));

  const card = (tool: Tool) => (
    <button type="button" className="tool-card" key={tool.id} onClick={() => setInspect(tool)}>
      <div className="tool-card-top">
        <span className="tool-tile"><ToolIcon tool={tool} size={26} /></span>
        <span><h3>{tool.name}</h3><small>{tool.kind}</small></span>
        <Badge variant={tool.installed ? 'default' : 'secondary'}>{tool.installed ? 'Installed' : 'Not detected'}</Badge>
      </div>
      <p>{tool.note}</p>
      <div className="tool-capabilities">
        {tool.capabilities.length ? tool.capabilities.map(capability => <span key={capability}>{capabilityNames[capability] ?? capability}</span>) : <span className="muted">No adapter yet</span>}
      </div>
    </button>
  );

  return (
    <>
      <div className="toolbar">
        <div className="search-field"><Search size={16} aria-hidden="true" /><Input aria-label="Search agents" placeholder="Search agents…" value={search} onChange={event => setSearch(event.target.value)} /></div>
      </div>
      <div className="section-label"><h2>Installed on this Mac <span>{installed.length}</span></h2><span>Capabilities show what Agent Hub can manage for each tool.</span></div>
      {installed.length ? <div className="tool-catalog">{installed.map(card)}</div> : <Empty>No installed agent matches this search.</Empty>}
      <details className="catalog-rest" open={!!search}>
        <summary>Not detected on this Mac ({others.length})</summary>
        <p className="muted">Catalogue entries join automatically once their command or configuration directory appears.</p>
        <div className="tool-catalog">{others.map(card)}</div>
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
