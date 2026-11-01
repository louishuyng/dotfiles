import { useState } from 'react';
import { ArrowUpRight, Check, CircleHelp, Plus, RefreshCw, Search, Sparkles } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Badge } from '../components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '../components/ui/dialog';
import { Avatar, Empty, PanelHeading, Select, Toggle } from '../components/common';
import { api } from '../api';
import { date } from '../lib/format';
import type { Workspace } from '../App';

type SyncPlan = { revision: string; changes: { target: string; action: string; path: string; source: string }[]; warnings: string[] };

export function Skills({ workspace }: { workspace: Workspace }) {
  const { state, busy, action, refresh, edit, tool } = workspace;
  const [search, setSearch] = useState('');
  const [source, setSource] = useState('all');
  const [showDisabled, setShowDisabled] = useState(false);
  const [plan, setPlan] = useState<SyncPlan>();
  const [creating, setCreating] = useState(false);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [content, setContent] = useState('');

  const library = state.library?.name || 'Shared library';
  const sources = [...new Set(state.skills.map(skill => skill.source))];
  const enabled = state.skills.filter(skill => skill.enabled).length;
  const skills = state.skills.filter(skill => (showDisabled || skill.enabled) && (source === 'all' || skill.source === source) && `${skill.name} ${skill.description}`.toLowerCase().includes(search.toLowerCase()));
  const checks = state.sync.checks ?? [];
  const drifted = checks.filter(check => check.status !== 'synced').length;
  const draftDirty = !!(name || description || content);

  const pluginIssue = /^(.+?): enabled plugin contributes skills\/commands$/;
  function issueRow(target: string, issue: string) {
    const match = issue.match(pluginIssue);
    const plugin = match && state.plugins.find(item => item.tool === target && item.id === match[1] && item.manageable);
    if (!plugin) return issue;
    return (
      <span className="issue-action">
        <span><strong>{plugin.name}</strong> plugin bundles its own skills and commands.</span>
        <Button variant="outline" size="sm" disabled={busy} onClick={() => { if (!window.confirm(`Disable the ${plugin.name} plugin for ${tool(target)?.name}? Its skills, commands, and hooks stop loading.`)) return; void action(async () => { await api('plugins/toggle', { tool: target, id: plugin.id, enabled: false }); await refresh(); }, `${plugin.name} disabled. Restart ${tool(target)?.name} to apply.`); }}>Disable plugin</Button>
      </span>
    );
  }

  function closeCreate() {
    if (busy) return;
    if (draftDirty && !window.confirm('Discard the new skill draft?')) return;
    setCreating(false); setName(''); setDescription(''); setContent('');
  }

  return (
    <>
      <section className="panel">
        <PanelHeading title={library} badge={`${enabled} enabled`} description={<>Source: <code className="path">{state.library?.path || 'ai/skills'}</code>. Enabled skills are exported to every supported agent; checks compare each agent with this set.</>}>
          <div className="button-row">
            <Button variant="outline" size="sm" disabled={busy} onClick={() => void action(async () => setPlan(await api<SyncPlan>('sync/preview', {})))}><RefreshCw size={14} aria-hidden="true" /> Review sync</Button>
            <Button size="sm" disabled={busy} onClick={() => setCreating(true)}><Plus size={14} aria-hidden="true" /> New skill</Button>
          </div>
        </PanelHeading>
        <div className="parity-strip">
          <div className="parity-summary">
            {checks.length ? <>{drifted ? <CircleHelp size={15} className="text-warn" aria-hidden="true" /> : <Check size={15} className="text-ok" aria-hidden="true" />}<strong>{drifted ? `${drifted} of ${checks.length} agents need attention` : `All ${checks.length} agents match`}</strong></> : <strong>Not verified yet</strong>}
            <span>{state.sync.verifiedAt ? `Checked ${date(state.sync.verifiedAt)}` : 'Review sync to link agents'}</span>
          </div>
          {!!checks.length && (
            <div className="parity-targets">
              {checks.map(check => (
                <details key={check.target} className={`parity-target ${check.status}`}>
                  <summary>
                    {check.status === 'synced' ? <Check size={14} aria-hidden="true" /> : <CircleHelp size={14} aria-hidden="true" />}
                    <strong>{tool(check.target)?.name || (check.target === 'codex-user' ? 'Shared discovery' : check.target)}</strong>
                    <span>{check.matched}/{check.expected}{check.issues.length ? ` · ${check.issues.length} ${check.issues.length === 1 ? 'issue' : 'issues'}` : check.notes?.length ? ` · ${check.notes.length} ${check.notes.length === 1 ? 'note' : 'notes'}` : ''}</span>
                  </summary>
                  {check.issues.length ? <ul>{check.issues.map((issue, index) => <li key={index}>{issueRow(check.target, issue)}</li>)}</ul> : <p>Synced: every enabled skill resolves to the shared library.</p>}
                  {!!check.notes?.length && <ul className="notes">{check.notes.map((note, index) => <li key={index}>{issueRow(check.target, note)}</li>)}</ul>}
                </details>
              ))}
            </div>
          )}
          {!!state.sync.warnings?.length && (
            <details className="inline-notes">
              <summary>Runtime limitations ({state.sync.warnings.length})</summary>
              <ul>{state.sync.warnings.map((warning, index) => <li key={index}>{warning}</li>)}</ul>
            </details>
          )}
        </div>
      </section>

      <div className="toolbar">
        <div className="search-field"><Search size={16} aria-hidden="true" /><Input aria-label="Search skills" placeholder="Search skills…" value={search} onChange={event => setSearch(event.target.value)} /></div>
        <div className="toolbar-end">
          {sources.length > 1 && <Select label="Source" value={source} onChange={setSource}><option value="all">All sources</option>{sources.map(item => <option key={item}>{item}</option>)}</Select>}
          <label className="check-field"><input type="checkbox" checked={showDisabled} onChange={event => setShowDisabled(event.target.checked)} />Show disabled</label>
        </div>
      </div>

      <section className="panel">
        <div className="row-list">
          {skills.map(skill => (
            <div className="row" key={skill.id}>
              <Avatar name={skill.name}><Sparkles size={16} aria-hidden="true" /></Avatar>
              <div className="row-copy">
                <h3>{skill.name}{!skill.enabled && <Badge variant="secondary">Disabled</Badge>}</h3>
                <p className="clamp" title={skill.description}>{skill.description || 'No description provided.'}</p>
                <small>{sources.length > 1 && `${skill.source} · `}{skill.compatibility}</small>
              </div>
              {skill.documentId && <Button variant="ghost" size="sm" disabled={busy} onClick={() => edit(skill.documentId!)}>{skill.editable ? 'Edit' : 'Inspect'}<ArrowUpRight size={14} aria-hidden="true" /></Button>}
              <Toggle on={skill.enabled} label={`Enable ${skill.name}`} disabled={busy} onChange={() => void action(async () => { await api('skills/toggle', { id: skill.id, enabled: !skill.enabled }); await refresh(); }, `${skill.name} ${skill.enabled ? 'disabled' : 'enabled'}. Shared links are updated automatically.`)} />
            </div>
          ))}
        </div>
        {!skills.length && <Empty>{showDisabled ? 'No skills match this search.' : 'No enabled skill matches this search. Show disabled skills to see the rest.'}</Empty>}
      </section>

      <Dialog open={!!plan} onOpenChange={open => { if (!open && !busy) setPlan(undefined); }}>
        <DialogContent className="sync-dialog">
          <DialogHeader>
            <DialogTitle>Review shared skill sync</DialogTitle>
            <DialogDescription>Links point at the {library} source folders. Conflicting native files are preserved.</DialogDescription>
          </DialogHeader>
          {plan && (
            <>
              <div className="sync-changes">
                {plan.changes.map((change, index) => <div key={index}><Badge variant="secondary">{change.action}</Badge><span><strong>{tool(change.target)?.name ?? change.target}</strong><code className="path">{change.path}</code><small>Source: {change.source}</small></span></div>)}
                {!plan.changes.length && <Empty>No file changes needed. Check the per-agent results for runtime limitations.</Empty>}
              </div>
              {plan.warnings.map((warning, index) => <p className="notice warning" key={index}>{warning}</p>)}
              <div className="dialog-actions">
                <Button variant="outline" disabled={busy} onClick={() => setPlan(undefined)}>Cancel</Button>
                <Button disabled={busy || !plan.changes.length} onClick={() => void action(async () => { await api('sync/apply', { revision: plan.revision }); setPlan(undefined); await refresh(); }, 'Shared skill links updated.')}><RefreshCw size={15} className={busy ? 'spin' : ''} aria-hidden="true" />Apply sync</Button>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>

      <Dialog open={creating} onOpenChange={open => { if (!open) closeCreate(); }}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Create a shared skill</DialogTitle>
            <DialogDescription>Adds a folder with a SKILL.md to {library}; it is exported to agents automatically.</DialogDescription>
          </DialogHeader>
          <form className="form" onSubmit={event => { event.preventDefault(); void action(async () => { await api('skills/create', { name, description, content }); setCreating(false); setName(''); setDescription(''); setContent(''); await refresh(); }, 'Skill created and shared.'); }}>
            <label htmlFor="skill-name">Skill name<Input id="skill-name" placeholder="review-changes" value={name} onChange={event => setName(event.target.value)} pattern="[a-z0-9]+(-[a-z0-9]+)*" maxLength={80} required /><small>Lowercase words separated by hyphens.</small></label>
            <label htmlFor="skill-description">Description<Input id="skill-description" value={description} onChange={event => setDescription(event.target.value)} required /><small>Agents use this to decide when the skill applies.</small></label>
            <label htmlFor="skill-content">Instructions<textarea id="skill-content" value={content} onChange={event => setContent(event.target.value)} required placeholder="Explain when to use this skill and what the agent should do." rows={8} /></label>
            <div className="dialog-actions">
              <Button type="button" variant="outline" disabled={busy} onClick={closeCreate}>Cancel</Button>
              <Button disabled={busy} type="submit"><Plus size={15} aria-hidden="true" />Create skill</Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </>
  );
}
