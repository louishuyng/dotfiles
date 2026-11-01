import { useEffect, useRef, useState } from 'react';
import { Activity, ChevronDown, CircleHelp, Layers, Terminal, Workflow } from 'lucide-react';
import { Area, AreaChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Empty, PanelHeading, Segmented, Select, ToolIcon } from '../components/common';
import { api, type Session, type Tool, type Usage } from '../api';
import { count, date, day, money } from '../lib/format';
import type { Workspace } from '../App';

const PAGE_SIZE = 20;
const series: { key: 'codex' | 'claude' | 'opencode' | 'pi'; color: string }[] = [
  { key: 'codex', color: 'var(--series-1)' },
  { key: 'claude', color: 'var(--series-2)' },
  { key: 'opencode', color: 'var(--series-3)' },
  { key: 'pi', color: 'var(--series-4)' },
];

export function Dashboard({ workspace }: { workspace: Workspace }) {
  const { state, tool } = workspace;
  const [usage, setUsage] = useState<Usage>();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [days, setDays] = useState<'1' | '7' | '30' | 'custom'>('7');
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [agent, setAgent] = useState('all');
  const [model, setModel] = useState('all');
  const [project, setProject] = useState('all');
  const [interval, setInterval] = useState<'daily' | 'weekly'>('daily');
  const [expanded, setExpanded] = useState<string>();
  const [pageIndex, setPageIndex] = useState(0);
  const request = useRef(0);

  useEffect(() => {
    if (days === 'custom' && (!from || !to)) return;
    const id = ++request.current;
    const query = new URLSearchParams({ days: days === 'custom' ? '30' : days, agent, model, project });
    if (days === 'custom') { query.set('from', from); query.set('to', to); }
    setLoading(true); setError('');
    api<Usage>(`usage?${query}`)
      .then(data => { if (id === request.current) setUsage(data); })
      .catch(failure => { if (id === request.current) { setUsage(undefined); setError(failure.message); } })
      .finally(() => { if (id === request.current) setLoading(false); });
  }, [state.refreshedAt, days, from, to, agent, model, project]);
  useEffect(() => { setPageIndex(0); setExpanded(undefined); }, [days, from, to, agent, model, project]);

  const summary = usage?.summary;
  const uncached = summary ? Math.max(0, summary.input - summary.cacheRead - summary.cacheWrite) : 0;
  const usageTools = state.tools.filter(item => item.capabilities.includes('usage'));
  const activeSeries = series.filter(item => agent === 'all' || item.key === agent);
  const sessions = usage?.sessions ?? [];
  const pageSessions = sessions.slice(pageIndex * PAGE_SIZE, (pageIndex + 1) * PAGE_SIZE);
  const metrics = [
    { label: 'Total tokens', value: summary ? count(summary.tokens) : '—', icon: Layers, tone: 'violet', detail: summary ? `${count(uncached)} uncached · ${count(summary.cacheRead + summary.cacheWrite)} cached` : 'Input and output, including cached input' },
    { label: 'Sessions', value: summary ? count(summary.sessions) : '—', icon: Terminal, tone: 'blue', detail: `${summary?.activeDays ?? 0} active days in range` },
    { label: 'Tool calls', value: summary ? count(summary.toolCalls) : '—', icon: Workflow, tone: 'orange', detail: `${count(summary?.turns ?? 0)} turns · ${count(summary?.errors ?? 0)} errors` },
    { label: 'Recorded cost', value: summary?.cost != null ? money(summary.cost) : 'Unavailable', icon: Activity, tone: 'green', detail: summary?.cost != null ? `${Math.round(summary.costCoverage / Math.max(1, summary.sessions) * 100)}% of sessions record cost` : 'Subscriptions do not expose spend' },
  ];

  return (
    <>
      <div className="toolbar">
        <Segmented label="Date range" value={days} onChange={setDays} options={[['1', 'Today'], ['7', '7 days'], ['30', '30 days'], ['custom', 'Custom']]} />
        {days === 'custom' && (
          <div className="custom-dates">
            <label>From<Input type="date" value={from} onChange={event => setFrom(event.target.value)} max={to || undefined} /></label>
            <label>To<Input type="date" value={to} onChange={event => setTo(event.target.value)} min={from || undefined} /></label>
          </div>
        )}
        <div className="toolbar-end">
          <Select label="Agent" value={agent} onChange={value => { setAgent(value); setModel('all'); setProject('all'); }}>
            <option value="all">All agents</option>
            {usageTools.map(item => <option key={item.id} value={item.id}>{item.name}</option>)}
          </Select>
          <Select label="Model" value={model} onChange={setModel}>
            <option value="all">All models</option>
            {usage?.models.map(item => <option key={item}>{item}</option>)}
          </Select>
          <Select label="Project" value={project} onChange={setProject}>
            <option value="all">All projects</option>
            {usage?.projects.map(item => <option key={item} value={item}>{item.replace(/^\/Users\/[^/]+/, '~')}</option>)}
          </Select>
        </div>
      </div>

      {error && <div className="notice danger" role="alert"><CircleHelp size={16} aria-hidden="true" /><span>{error}</span></div>}

      <div className="metric-grid" aria-busy={loading}>
        {metrics.map(metric => (
          <section className="metric-card" key={metric.label}>
            <div className="metric-top"><span>{metric.label}</span><span className={`metric-icon ${metric.tone}`}><metric.icon size={16} aria-hidden="true" /></span></div>
            {loading && !usage ? <span className="skeleton metric-skeleton" aria-hidden="true" /> : <strong>{metric.value}</strong>}
            <small>{metric.detail}</small>
          </section>
        ))}
      </div>

      <div className="charts-grid">
        <section className="panel">
          <PanelHeading title="Usage over time" description={interval === 'daily' ? 'Tokens per day by agent' : 'Tokens per week, all agents'}>
            <Segmented small label="Chart interval" value={interval} onChange={setInterval} options={[['daily', 'Daily'], ['weekly', 'Weekly']]} />
          </PanelHeading>
          {interval === 'daily' && (
            <div className="chart-legend">
              {activeSeries.map(item => <span key={item.key}><i style={{ background: item.color }} />{tool(item.key)?.name ?? item.key}</span>)}
            </div>
          )}
          <div className="chart" role="img" aria-label="Token usage over time. Exact values are in the sessions table below.">
            {loading ? <div className="skeleton chart-skeleton" aria-label="Loading activity" />
              : !sessions.length ? <Empty>No recorded sessions in this date range.</Empty>
              : (
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={interval === 'daily' ? usage!.daily : usage!.weekly} margin={{ top: 12, right: 12, left: -10, bottom: 0 }}>
                    <defs>
                      <linearGradient id="usageFill" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="var(--primary)" stopOpacity={0.25} /><stop offset="100%" stopColor="var(--primary)" stopOpacity={0.02} /></linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 4" vertical={false} stroke="var(--border)" />
                    <XAxis dataKey="date" tickFormatter={day} axisLine={false} tickLine={false} tick={{ fill: 'var(--muted-foreground)', fontSize: 11 }} minTickGap={28} />
                    <YAxis tickFormatter={count} axisLine={false} tickLine={false} tick={{ fill: 'var(--muted-foreground)', fontSize: 11 }} width={56} />
                    <Tooltip labelFormatter={value => day(String(value))} formatter={value => count(Number(value))} contentStyle={{ background: 'var(--card)', border: '1px solid var(--border)', borderRadius: 10, color: 'var(--foreground)', fontSize: 12 }} />
                    {interval === 'weekly'
                      ? <Area type="monotone" dataKey="total" name="All agents" stroke="var(--primary)" fill="url(#usageFill)" strokeWidth={2} />
                      : activeSeries.map(item => <Area key={item.key} type="monotone" dataKey={item.key} name={tool(item.key)?.name ?? item.key} stroke={item.color} fill="transparent" strokeWidth={2} />)}
                  </AreaChart>
                </ResponsiveContainer>
              )}
          </div>
        </section>

        <section className="panel">
          <PanelHeading title="Token breakdown" description="Cumulative for this range" />
          <div className="token-total"><strong>{count(summary?.tokens ?? 0)}</strong><span>tokens</span></div>
          {(() => {
            const parts = [
              ['Uncached input', uncached, 'var(--series-1)'],
              ['Output', summary?.output ?? 0, 'var(--series-3)'],
              ['Cache read', summary?.cacheRead ?? 0, 'var(--series-2)'],
              ['Cache write', summary?.cacheWrite ?? 0, 'var(--series-4)'],
            ] as const;
            return (
              <>
                <div className="token-stack" aria-hidden="true">{parts.map(([label, value, color]) => <span key={label} style={{ flex: value || 0.001, background: color }} title={`${label}: ${count(value)}`} />)}</div>
                <div className="token-list">{parts.map(([label, value, color]) => <div key={label}><span><i style={{ background: color }} />{label}</span><strong>{count(value)}</strong></div>)}</div>
              </>
            );
          })()}
          <div className="panel-footer">Reasoning: {count(summary?.reasoning ?? 0)} tokens · {summary?.compactions ?? 0} compactions</div>
        </section>
      </div>

      <section className="panel">
        <PanelHeading title="Sessions" badge={sessions.length} description="Latest request input is a context proxy, not a live context meter." />
        {sessions.length ? (
          <div className="table-scroll">
            <table>
              <thead>
                <tr><th>Agent / model</th><th>Project</th><th>Last active</th><th className="num">Tokens</th><th className="num">Tool calls</th><th className="num">Latest input</th><th><span className="sr-only">Details</span></th></tr>
              </thead>
              <tbody>
                {pageSessions.map(session => <SessionRows key={session.id} session={session} tool={tool(session.agent)} expanded={expanded === session.id} onExpand={() => setExpanded(expanded === session.id ? undefined : session.id)} />)}
              </tbody>
            </table>
          </div>
        ) : loading ? <div className="skeleton-rows" aria-label="Loading sessions">{Array.from({ length: 6 }, (_, index) => <span key={index} className="skeleton" />)}</div> : <Empty>No sessions found. Use an agent, then refresh.</Empty>}
        <div className="panel-footer split">
          <span>{sessions.length ? `${pageIndex * PAGE_SIZE + 1}–${Math.min((pageIndex + 1) * PAGE_SIZE, sessions.length)} of ${sessions.length}` : '0 sessions'} · times in {usage?.timezone || 'local time'}</span>
          <div className="button-row">
            <Button variant="outline" size="sm" disabled={pageIndex === 0} onClick={() => setPageIndex(pageIndex - 1)}>Previous</Button>
            <Button variant="outline" size="sm" disabled={(pageIndex + 1) * PAGE_SIZE >= sessions.length} onClick={() => setPageIndex(pageIndex + 1)}>Next</Button>
          </div>
        </div>
      </section>

      {!!usage?.warnings.length && (
        <details className="data-notes">
          <summary><CircleHelp size={15} aria-hidden="true" /> Usage data notes ({usage.warnings.length})</summary>
          <ul>{usage.warnings.map((warning, index) => <li key={index}>{warning}</li>)}</ul>
        </details>
      )}
    </>
  );
}

function SessionRows({ session, tool, expanded, onExpand }: { session: Session; tool?: Tool; expanded: boolean; onExpand: () => void }) {
  const details: [string, string][] = [
    ['Input', count(session.input)], ['Output', count(session.output)], ['Cache read', count(session.cacheRead)], ['Cache write', count(session.cacheWrite)], ['Reasoning', count(session.reasoning)],
    ['Latest request input', session.context != null ? count(session.context) : 'Unavailable'], ['Peak request input', session.peakContext != null ? count(session.peakContext) : 'Unavailable'],
    ['Context limit', session.contextLimit != null ? count(session.contextLimit) : 'Unavailable'], ['Compactions', String(session.compactions)], ['Errors', String(session.errors)],
    ['Cost', session.cost != null ? money(session.cost, 4) : 'Unavailable'], ['Started', date(session.startedAt)],
  ];
  return (
    <>
      <tr className={expanded ? 'expanded' : ''}>
        <td><div className="session-agent"><ToolIcon tool={tool} size={22} /><span><strong>{tool?.name || session.agent}</strong><small>{session.model || 'Model unavailable'}{session.subagent ? ' · subagent' : ''}</small></span></div></td>
        <td><span className="project-name" title={session.project}>{session.project.split('/').filter(Boolean).pop() || 'Unavailable'}</span></td>
        <td className="nowrap">{date(session.updatedAt)}</td>
        <td className="num">{count(session.input + session.output)}</td>
        <td className="num">{session.toolCalls}</td>
        <td className="num">{session.context != null ? count(session.context) : <span className="muted">—</span>}</td>
        <td><button type="button" className="icon-button" onClick={onExpand} aria-expanded={expanded} aria-label={`${expanded ? 'Collapse' : 'Expand'} session details`}><ChevronDown size={16} className={expanded ? 'rotated' : ''} aria-hidden="true" /></button></td>
      </tr>
      {expanded && (
        <tr className="session-detail">
          <td colSpan={7}>
            <div className="detail-grid">{details.map(([label, value]) => <span key={label}>{label}<strong>{value}</strong></span>)}</div>
            <p className="detail-meta"><span>Project: <code>{session.project || 'Unavailable'}</code></span><span>Session: <code>{session.id}</code></span></p>
          </td>
        </tr>
      )}
    </>
  );
}
