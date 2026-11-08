import { useState } from 'react';
import { ChevronRight, ExternalLink, Search } from 'lucide-react';
import { Input } from '../components/ui/input';
import { Empty, PanelHeading, Toggle, ToolIcon } from '../components/common';
import { api } from '../api';
import { Vendors } from '../components/Vendors';
import type { Workspace } from '../App';

export function Plugins({ workspace }: { workspace: Workspace }) {
  const { state, busy, action, refresh } = workspace;
  const [search, setSearch] = useState('');
  const pluginTools = state.tools.filter(tool => tool.capabilities.includes('plugins'));
  const groups = pluginTools
    .map(tool => ({ tool, plugins: state.plugins.filter(plugin => plugin.tool === tool.id && plugin.name.toLowerCase().includes(search.toLowerCase())) }))
    .filter(group => group.plugins.length || !search);

  return (
    <>
      <Vendors workspace={workspace} />
      <div className="toolbar">
        <div className="search-field"><Search size={16} aria-hidden="true" /><Input aria-label="Search plugins" placeholder="Search plugins…" value={search} onChange={event => setSearch(event.target.value)} /></div>
        <div className="toolbar-end marketplace-links">
          {pluginTools.map(tool => <a key={tool.id} href={tool.url} target="_blank" rel="noreferrer"><ToolIcon tool={tool} size={16} />{tool.name} docs<ExternalLink size={13} aria-hidden="true" /></a>)}
        </div>
      </div>

      {groups.map(({ tool, plugins }) => (
        <details className="panel group" key={tool.id} open={!!search}>
          <summary>
            <ChevronRight size={16} className="group-chevron" aria-hidden="true" />
            <PanelHeading title={<span className="tool-heading"><ToolIcon tool={tool} size={20} />{tool.name}</span>} badge={`${plugins.filter(plugin => plugin.enabled).length}/${plugins.length} enabled`} description={plugins[0]?.note} />
          </summary>
          <div className="row-list">
            {plugins.map(plugin => (
              <div className="row compact" key={`${plugin.tool}:${plugin.id}`}>
                <div className="row-copy">
                  <h3>{plugin.name}</h3>
                  {(plugin.version || plugin.path) && <small className="path">{plugin.version || plugin.path}</small>}
                </div>
                {plugin.manageable
                  ? <Toggle on={plugin.enabled} label={`Enable ${plugin.name}`} disabled={busy} onChange={() => void action(async () => { await api('plugins/toggle', { tool: plugin.tool, id: plugin.id, enabled: !plugin.enabled }); await refresh(); }, `${plugin.name} ${plugin.enabled ? 'disabled' : 'enabled'}. Restart ${tool.name} to apply.`)} />
                  : <a className="text-button" href={tool.url} target="_blank" rel="noreferrer">Manage in {tool.name}<ExternalLink size={13} aria-hidden="true" /></a>}
              </div>
            ))}
          </div>
          {!plugins.length && <Empty>No plugins recorded for {tool.name}. Install them through its own marketplace.</Empty>}
        </details>
      ))}
      {!groups.length && <Empty>No plugin matches this search.</Empty>}
    </>
  );
}
