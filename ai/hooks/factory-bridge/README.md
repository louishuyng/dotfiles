# Factory completion bridge

Claude Code `Stop` / `Notification` → Grok Bot routine webhook (`Rex · Factory completion bridge`).

## Enable (credentials required)

1. Open the routine **Rex · Factory completion bridge** in Grok Bot → Webhook section.
2. Copy **POST to** (URL) and **key**.
3. Write `~/.config/rex-factory-completion-bridge/credentials.json` mode `600`:

```json
{
  "webhook_url": "<POST to>",
  "webhook_key": "<key>"
}
```

Auth header (official): `Authorization: Bearer <key>`.

4. `echo 1 > ~/.config/rex-factory-completion-bridge/enabled`
5. Do not paste the key into chat.

## Semantics

- `Stop` = end of Claude response turn (not a human gate, not approval).
- `Notification` = needs attention (not permission auto-approval).
- Payload is allowlisted metadata only; no transcript / no full last message.
- Scoped to RegAsk factory cwd prefixes in `allowlist.json`.
- Delivery is best-effort, timeout 2.5s, never blocks Claude (exit 0).
