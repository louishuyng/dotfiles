import type React from 'react';
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
  return <img className="logo" src="/logo.svg" alt="" width={size} height={size} />;
}

/** Stable pastel hue per name so rows read as distinct items, like avatar colors. */
export function hue(name: string) {
  let value = 0;
  for (const char of name) value = (value * 31 + char.charCodeAt(0)) % 360;
  return value;
}

export function Avatar({ name, children }: { name: string; children: ReactNode }) {
  return <span className="row-symbol tinted" style={{ '--hue': hue(name) } as React.CSSProperties}>{children}</span>;
}
