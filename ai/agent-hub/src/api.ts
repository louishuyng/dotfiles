export type Tool = { id: string; name: string; icon: string; color: string; installed: boolean; configured: boolean; kind: string; url: string; capabilities: string[]; note: string; subscription?: string };
export type Skill = { id: string; name: string; description: string; path: string; source: string; enabled: boolean; editable: boolean; compatibility: string; documentId?: string };
export type Plugin = { id: string; tool: string; name: string; enabled: boolean; version?: string; path?: string; manageable: boolean; note?: string };
export type Vendor = { name: string; title?: string; repo: string; ref: string; commit: string; version: string; date: string; skill: string; path: string; latest?: { commit?: string; ref?: string; checkedAt?: string; error?: string }; native: Record<string, { id: string; installed: boolean; version?: string; error?: string }> };
export type VendorPlan = { id: string; name: string; ref: string; commit: string; date: string; version: string; from: { commit: string; version: string }; changes: { path: string; status: 'added' | 'changed' | 'removed' }[] };
export type Document = { id: string; name: string; tool: string; path: string; kind: string; exists: boolean; editable: boolean };
export type Hook = { tool: string; event: string; count: number; documentId: string; description: string };
export type State = { library: { name: string; path: string }; token: string; tools: Tool[]; skills: Skill[]; plugins: Plugin[]; documents: Document[]; hooks: Hook[]; warnings: string[]; service: { installed: boolean; running: boolean; url: string; logPath: string }; refreshedAt: string; sync: { managed: number; targets: string[]; checks?: { target: string; matched: number; expected: number; status: 'synced' | 'drift'; issues: string[]; notes?: string[] }[]; verifiedAt?: string; warnings?: string[] }; backups: { id: string; name: string; createdAt: string; documentId: string }[] };
export type Session = { id: string; agent: string; model: string; project: string; startedAt: string; updatedAt: string; input: number; output: number; cacheRead: number; cacheWrite: number; reasoning: number; turns: number; toolCalls: number; errors: number; compactions: number; cost: number | null; context: number | null; peakContext: number | null; contextLimit: number | null; subagent: boolean };
export type Usage = { summary: { sessions: number; turns: number; tokens: number; input: number; output: number; cacheRead: number; cacheWrite: number; reasoning: number; toolCalls: number; errors: number; compactions: number; cost: number | null; costCoverage: number; activeDays: number }; daily: { date: string; codex: number; claude: number; opencode: number; pi: number; total: number; sessions: number }[]; weekly: { date: string; total: number; sessions: number }[]; sessions: Session[]; models: string[]; projects: string[]; warnings: string[]; timezone: string; refreshedAt: string };
export type FileData = { id: string; content: string; revision: string; path: string; editable: boolean };
let token = '';
export async function api<T>(path: string, body?: unknown): Promise<T> {
  const response = await fetch(`/api/${path}`, { method: body === undefined ? 'GET' : 'POST', headers: body === undefined ? {} : { 'Content-Type': 'application/json', 'X-Agent-Hub-Token': token }, body: body === undefined ? undefined : JSON.stringify(body) });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || 'Request failed. Try refreshing.');
  if (data.token) token = data.token;
  return data;
}
