import { useCallback, useEffect, useState } from 'react';
import { ExternalLink, Package, RefreshCw, Download, Plug } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from './ui/dialog';
import { Avatar, Empty, PanelHeading, ToolIcon } from './common';
import { api, type Vendor, type VendorPlan } from '../api';
import { date } from '../lib/format';
import type { Workspace } from '../App';

const short = (commit?: string) => commit?.slice(0, 7) ?? 'unknown';

function updateStatus(vendor: Vendor) {
  const latest = vendor.latest;
  if (!latest?.checkedAt) return { label: 'Not checked', text: 'Not checked against upstream yet.', variant: 'secondary' as const };
  if (latest.error) return { label: 'Check failed', text: `${latest.error} Last tried ${date(latest.checkedAt)}.`, variant: 'destructive' as const };
  if (latest.commit && latest.commit !== vendor.commit) return { label: 'Update available', text: `Update available on ${vendor.ref}: ${short(vendor.commit)} → ${short(latest.commit)}. Checked ${date(latest.checkedAt)}.`, variant: 'default' as const };
  return { label: 'Up to date', text: `Up to date with ${vendor.ref}. Checked ${date(latest.checkedAt)}.`, variant: 'secondary' as const };
}

export function Vendors({ workspace }: { workspace: Workspace }) {
  const { state, busy, action, tool } = workspace;
  const [vendors, setVendors] = useState<Vendor[]>();
  const [error, setError] = useState('');
  const [updating, setUpdating] = useState<Vendor>();
  const [ref, setRef] = useState('');
  const [plan, setPlan] = useState<VendorPlan>();

  const load = useCallback(async () => {
    try { setVendors((await api<{ vendors: Vendor[] }>('vendors')).vendors); setError(''); }
    catch (cause) { setError(cause instanceof Error ? cause.message : 'Vendored plugins could not be read.'); }
  }, []);
  useEffect(() => { void load(); }, [load]);

  function openUpdate(vendor: Vendor) { setUpdating(vendor); setRef(vendor.ref); setPlan(undefined); }
  function closeUpdate() {
    if (busy || !updating) return;
    if (plan) void api('vendors/discard', { name: updating.name }).catch(() => {});
    setUpdating(undefined); setPlan(undefined);
  }

  if (error) return <p className="notice danger" role="alert">{error}</p>;
  if (!vendors) return null;

  return (
    <section className="panel">
      <PanelHeading title="Vendored plugins" badge={vendors.length} description={<>Plugin code copied into <code className="path">ai/vendor</code> and shared through a library skill. Updates show the changed files first; review and commit them yourself.</>} />
      <div className="row-list">
        {vendors.map(vendor => {
          const status = updateStatus(vendor);
          const skill = state.skills.find(item => item.name === vendor.skill);
          return (
            <div className="row vendor-row" key={vendor.name}>
              <Avatar name={vendor.name}><Package size={16} aria-hidden="true" /></Avatar>
              <div className="row-copy">
                <h3>{vendor.title || vendor.name}<Badge variant={status.variant}>{status.label}</Badge></h3>
                <p>v{vendor.version} · <code className="path">{short(vendor.commit)}</code> · {vendor.date} · tracks <code className="path">{vendor.ref}</code></p>
                <small role="status" aria-atomic="true">{status.text}</small>
                <ul className="vendor-links" aria-label={`${vendor.name} links`}>
                  <li>Skill <code className="path">{vendor.skill}</code>: {skill ? (skill.enabled ? 'enabled and shared' : 'disabled') : 'missing from the library'}</li>
                  {Object.entries(vendor.native).map(([target, native]) => {
                    const mismatch = native.installed && native.version && native.version !== vendor.version;
                    return (
                      <li key={target}>
                        <ToolIcon tool={tool(target)} size={14} />{tool(target)?.name ?? target} plugin:{' '}
                        {native.error ? native.error : native.installed ? <>v{native.version ?? '?'}{mismatch && <span className="text-warn"> (vendored v{vendor.version})</span>}</> : 'not installed'}
                      </li>
                    );
                  })}
                  <li><a className="text-button" href={vendor.repo} target="_blank" rel="noreferrer">Upstream<ExternalLink size={13} aria-hidden="true" /></a></li>
                </ul>
              </div>
              <div className="button-row vendor-actions">
                <Button variant="outline" size="sm" disabled={busy} onClick={() => void action(async () => { await api('vendors/check', { name: vendor.name }); await load(); })}><RefreshCw size={14} aria-hidden="true" /> Check</Button>
                {!!Object.keys(vendor.native).length && <Button variant="outline" size="sm" disabled={busy} onClick={() => void action(async () => {
                  const { results } = await api<{ results: { target: string; ok: boolean; action?: string; error?: string }[] }>('vendors/native', { name: vendor.name });
                  await load();
                  const failed = results.filter(result => !result.ok);
                  if (failed.length) throw new Error(failed.map(result => `${tool(result.target)?.name ?? result.target}: ${result.error}`).join(' '));
                }, 'Native plugins synced. Restart those agents to load them.')}><Plug size={14} aria-hidden="true" /> Sync native</Button>}
                <Button variant={status.label === 'Update available' ? 'default' : 'outline'} size="sm" disabled={busy} onClick={() => openUpdate(vendor)}><Download size={14} aria-hidden="true" /> Update…</Button>
              </div>
            </div>
          );
        })}
      </div>
      {!vendors.length && <Empty>No vendored plugins. Add a folder with a <code className="path">vendor.json</code> under <code className="path">ai/vendor</code>.</Empty>}

      <Dialog open={!!updating} onOpenChange={open => { if (!open) closeUpdate(); }}>
        <DialogContent className="sync-dialog">
          <DialogHeader>
            <DialogTitle>Update {updating?.title || updating?.name}</DialogTitle>
            <DialogDescription>Fetches upstream into a temporary folder and lists what would change in <code className="path">ai/vendor/{updating?.name}</code>. Nothing changes until you apply.</DialogDescription>
          </DialogHeader>
          <form className="form" onSubmit={event => { event.preventDefault(); if (updating) void action(async () => setPlan(await api<VendorPlan>('vendors/preview', { name: updating.name, ref }))); }}>
            <label htmlFor="vendor-ref">Branch, tag, or commit
              <Input id="vendor-ref" value={ref} onChange={event => { setRef(event.target.value); setPlan(undefined); }} pattern={'[A-Za-z0-9._\\/\\-]{1,128}'} maxLength={128} required aria-describedby="vendor-ref-help" />
              <small id="vendor-ref-help">The tracked ref stays {updating?.ref}; use a tag or commit to pin a specific version.</small>
            </label>
            {!plan && <div className="dialog-actions"><Button type="button" variant="outline" disabled={busy} onClick={closeUpdate}>Cancel</Button><Button type="submit" disabled={busy}><RefreshCw size={15} className={busy ? 'spin' : ''} aria-hidden="true" />Preview changes</Button></div>}
          </form>
          {plan && (
            <>
              <p role="status" aria-atomic="true"><strong>v{plan.from.version} ({short(plan.from.commit)}) → v{plan.version} ({short(plan.commit)})</strong>, committed {plan.date}. {plan.changes.length ? `${plan.changes.length} ${plan.changes.length === 1 ? 'file changes' : 'files change'}.` : 'No file changes.'}</p>
              <div className="sync-changes">
                {plan.changes.map(change => <div key={change.path}><Badge variant={change.status === 'removed' ? 'destructive' : 'secondary'}>{change.status}</Badge><code className="path">{change.path}</code></div>)}
                {!plan.changes.length && <Empty>The vendored files already match this ref.</Empty>}
              </div>
              <p className="notice warning">Vendored prompts run in every agent. Review the diff with git before committing.</p>
              <div className="dialog-actions">
                <Button variant="outline" disabled={busy} onClick={closeUpdate}>Cancel</Button>
                <Button disabled={busy || !plan.changes.length} onClick={() => void action(async () => { await api('vendors/apply', { name: plan.name, id: plan.id }); setUpdating(undefined); setPlan(undefined); await load(); }, `${plan.name} updated to v${plan.version}. Sync native plugins next, then commit ai/vendor/${plan.name}.`)}><Download size={15} aria-hidden="true" />Apply update</Button>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>
    </section>
  );
}
