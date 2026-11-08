import { useState } from 'react';
import { ArrowUpRight, ChevronRight, FileText, Settings2 } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Badge } from '../components/ui/badge';
import { Empty, PanelHeading, ToolIcon } from '../components/common';
import { api, type Document } from '../api';
import type { Workspace } from '../App';

const kindNames: Record<string, string> = { hook: 'Hooks', plugin: 'Plugins', 'hook-source': 'Hook source', config: 'Native config' };

export function Instructions({ workspace }: { workspace: Workspace }) {
  const { state, busy, action, refresh, edit, tool } = workspace;
  const [projectPath, setProjectPath] = useState('');
  const globalDocs = state.documents.filter(document => document.kind === 'instruction' && !document.id.startsWith('project:'));
  const projectDocs = state.documents.filter(document => document.kind === 'instruction' && document.id.startsWith('project:'));
  const configDocs = state.documents.filter(document => ['hook', 'plugin', 'hook-source', 'config'].includes(document.kind));

  const row = (document: Document, title: string, subtitle: string) => (
    <button type="button" className="row clickable" key={document.id} onClick={() => edit(document.id)} disabled={busy}>
      <span className="row-symbol">{document.kind === 'instruction' ? <ToolIcon tool={tool(document.tool)} size={18} /> : <Settings2 size={17} aria-hidden="true" />}</span>
      <div className="row-copy"><h3>{title}</h3><small className="path">{subtitle}</small></div>
      {!document.exists && <Badge variant="secondary">Not created yet</Badge>}
      {!document.editable && <Badge variant="secondary">Read only</Badge>}
      <ChevronRight size={16} className="muted" aria-hidden="true" />
    </button>
  );

  return (
    <>
      <section className="panel">
        <PanelHeading title="Global instructions" badge={globalDocs.length} description={<>Every supported agent links to the shared <code className="path">ai/AGENTS.md</code>. Optional policies such as ADHD or Ponytail are managed in Hooks.</>} />
        <div className="row-list">{globalDocs.map(document => row(document, tool(document.tool)?.name || document.tool, document.path))}</div>
      </section>

      <section className="panel">
        <PanelHeading title="Project instructions" badge={projectDocs.length} description="Add a local project to edit the instruction files agents read inside it." />
        <form className="project-form" onSubmit={event => { event.preventDefault(); void action(async () => { await api('project/select', { path: projectPath }); setProjectPath(''); await refresh(); }, 'Project added.'); }}>
          <label htmlFor="project-path" className="sr-only">Project directory</label>
          <Input id="project-path" placeholder="/Users/you/projects/my-app" value={projectPath} onChange={event => setProjectPath(event.target.value)} required />
          <Button disabled={busy || !projectPath.trim()} type="submit">Add project <ArrowUpRight size={15} aria-hidden="true" /></Button>
        </form>
        {projectDocs.length
          ? <div className="row-list">{projectDocs.map(document => row(document, `${document.name} · ${tool(document.tool)?.name || document.tool}`, document.path))}</div>
          : <Empty icon={<FileText size={22} aria-hidden="true" />}>No project selected yet.</Empty>}
      </section>

      <section className="panel">
        <PanelHeading title="Managed configuration" badge={configDocs.length} description={<>Hook definitions, plugin registrations, and native settings sections that Agent Hub owns under <code className="path">ai/</code>.</>} />
        <div className="row-list">{configDocs.map(document => row(document, `${kindNames[document.kind] ?? document.kind} · ${tool(document.tool)?.name || document.name}`, document.path))}</div>
      </section>
    </>
  );
}
