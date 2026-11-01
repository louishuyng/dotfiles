import type { ReactNode } from 'react';
import { ChevronDown, CircleHelp, Terminal } from 'lucide-react';
import type { Tool } from '../api';

export function ToolIcon({ tool, size = 28 }: { tool?: Tool; size?: number }) {
  return tool
    ? <img className="tool-icon" src={tool.icon} alt="" width={size} height={size} />
    : <Terminal size={size} aria-hidden="true" />;
}

export function Empty({ children, icon }: { children: ReactNode; icon?: ReactNode }) {
  return (
    <div className="empty">
      {icon ?? <CircleHelp size={24} aria-hidden="true" />}
      <p>{children}</p>
    </div>
  );
}

export function Select({ label, value, onChange, children }: { label: string; value: string; onChange: (value: string) => void; children: ReactNode }) {
  return (
    <label className="select-wrap">
      <span>{label}</span>
      <select value={value} onChange={event => onChange(event.target.value)}>{children}</select>
      <ChevronDown size={14} aria-hidden="true" />
    </label>
  );
}

export function Toggle({ on, label, disabled, onChange }: { on: boolean; label: string; disabled?: boolean; onChange: () => void }) {
  return (
    <button type="button" className={`toggle ${on ? 'on' : ''}`} role="switch" aria-checked={on} aria-label={label} disabled={disabled} onClick={onChange}>
      <span />
    </button>
  );
}

export function Segmented<T extends string>({ label, value, options, onChange, small }: { label: string; value: T; options: [T, string][]; onChange: (value: T) => void; small?: boolean }) {
  return (
    <div className={`segmented ${small ? 'small' : ''}`} role="group" aria-label={label}>
      {options.map(([id, name]) => (
        <button key={id} type="button" className={value === id ? 'selected' : ''} aria-pressed={value === id} onClick={() => onChange(id)}>{name}</button>
      ))}
    </div>
  );
}

export function PanelHeading({ title, description, badge, children }: { title: ReactNode; description?: ReactNode; badge?: ReactNode; children?: ReactNode }) {
  return (
    <div className="panel-heading">
      <div>
        <h2>{title}{badge !== undefined && <span className="count-badge">{badge}</span>}</h2>
        {description && <p>{description}</p>}
      </div>
      {children}
    </div>
  );
}

export function Logo({ size = 28 }: { size?: number }) {
  return (
    <svg className="logo" width={size} height={size} viewBox="0 0 48 48" aria-hidden="true">
      <defs><linearGradient id="logo-fill" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#7c6cf2" /><stop offset="1" stopColor="#4a38c4" /></linearGradient></defs>
      <rect width="48" height="48" rx="13" fill="url(#logo-fill)" />
      <g stroke="#fff" strokeWidth="2.4" strokeLinecap="round"><path d="M24 24 24 12M24 24 13.6 30M24 24 34.4 30" /></g>
      <circle cx="24" cy="24" r="5" fill="#fff" />
      <g fill="#fff" fillOpacity=".92"><circle cx="24" cy="11" r="3.2" /><circle cx="12.8" cy="30.5" r="3.2" /><circle cx="35.2" cy="30.5" r="3.2" /></g>
    </svg>
  );
}
