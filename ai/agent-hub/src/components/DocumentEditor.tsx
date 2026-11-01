import { useEffect, useState } from 'react';
import { Check, GitCompareArrows, History, LoaderCircle } from 'lucide-react';
import { diffLines } from 'diff';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from './ui/dialog';
import { api, type FileData } from '../api';
import { date } from '../lib/format';
import type { Workspace } from '../App';

export function DocumentEditor({ workspace, file, onFile }: { workspace: Workspace; file?: FileData; onFile: (file?: FileData) => void }) {
  const { state, busy, action, notify, refresh } = workspace;
  const [draft, setDraft] = useState('');
  const [preview, setPreview] = useState(false);
  const [error, setError] = useState('');
  const dirty = !!file && draft !== file.content;
  const backups = file ? state.backups.filter(backup => backup.documentId === file.id) : [];

  useEffect(() => { setDraft(file?.content ?? ''); setPreview(false); setError(''); }, [file]);
  useEffect(() => {
    if (!dirty) return;
    const guard = (event: BeforeUnloadEvent) => event.preventDefault();
    window.addEventListener('beforeunload', guard);
    return () => window.removeEventListener('beforeunload', guard);
  }, [dirty]);

  function close() {
    if (busy) return;
    if (dirty && !window.confirm('Discard your unsaved changes?')) return;
    onFile(undefined);
  }

  async function run(work: () => Promise<void>, success: string) {
    setError('');
    await action(async () => {
      try { await work(); notify(success); }
      catch (failure) { setError(failure instanceof Error ? failure.message : 'The action failed.'); }
    });
  }

  async function reload(id: string) {
    const data = await api<FileData>(`document?id=${encodeURIComponent(id)}`);
    onFile(data);
    await refresh();
  }

  async function save() {
    if (!file) return;
    await run(async () => { await api('document/save', { id: file.id, content: draft, revision: file.revision }); await reload(file.id); }, 'Saved. The previous version is kept as a backup.');
  }

  async function restore(backupId: string) {
    if (!file || !window.confirm('Restore this backup? The current file is backed up first and your unsaved draft is replaced.')) return;
    await run(async () => { await api('document/restore', { backupId, revision: file.revision }); await reload(file.id); }, 'Backup restored.');
  }

  return (
    <Dialog open={!!file} onOpenChange={open => { if (!open) close(); }}>
      <DialogContent className="editor-dialog">
        <DialogHeader>
          <DialogTitle>{file?.path.split('/').pop() || 'Document'}</DialogTitle>
          <DialogDescription><code className="path">{file?.path}</code></DialogDescription>
        </DialogHeader>
        {file && (
          <>
            <div className="editor-toolbar">
              <Badge variant="secondary">{!file.editable ? 'Read only' : dirty ? 'Unsaved changes' : 'Saved'}</Badge>
              <Button variant="outline" size="sm" disabled={!dirty} onClick={() => setPreview(!preview)}>
                <GitCompareArrows size={15} aria-hidden="true" />{preview ? 'Back to editor' : 'Preview changes'}
              </Button>
            </div>
            {preview ? (
              <div className="diff-view" aria-label="Changes preview">
                {diffLines(file.content, draft).map((part, index) => <pre key={index} className={part.added ? 'diff-added' : part.removed ? 'diff-removed' : ''}>{part.value}</pre>)}
              </div>
            ) : (
              <label className="editor-label">
                <span className="sr-only">Document content</span>
                <textarea className="code-editor" spellCheck={false} value={draft} readOnly={!file.editable} onChange={event => setDraft(event.target.value)} />
              </label>
            )}
            {!!backups.length && (
              <details className="backup-list">
                <summary><History size={15} aria-hidden="true" /> Backups ({backups.length})</summary>
                {backups.map(backup => (
                  <div key={backup.id}>
                    <span>{date(backup.createdAt)}<small>{backup.name}</small></span>
                    <Button variant="outline" size="sm" disabled={busy || !file.editable} onClick={() => void restore(backup.id)}>Restore</Button>
                  </div>
                ))}
              </details>
            )}
            {error && <p className="dialog-error" role="alert">{error}</p>}
            <div className="dialog-actions">
              <Button variant="outline" onClick={close} disabled={busy}>Close</Button>
              {file.editable && (
                <Button disabled={busy || !dirty} onClick={() => preview ? void save() : setPreview(true)}>
                  {busy ? <LoaderCircle className="spin" size={15} aria-hidden="true" /> : <Check size={15} aria-hidden="true" />}
                  {preview ? 'Save changes' : 'Review & save'}
                </Button>
              )}
            </div>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
}
