#!/usr/bin/env python3
# agent cell usage — reads local files only (no network, no tokens):
#   Claude: cachedUsageUtilization in ~/.claude.json (where Claude Code stores the /usage values) — only this block is read
#   Codex : the last rate_limits in the final 200KB of the newest rollout-*.jsonl under ~/.codex/sessions
# Output is only the fields agent.sh uses. A value whose reset time has passed is unused in the new window → 0% (no reset time)
#   (Codex writes a new record on every use, so no record after the reset means 0 is right.)
import json, os, glob, time, datetime as D
from pathlib import Path
H = os.path.expanduser("~"); now = time.time()
def live(iso):
    try: return D.datetime.fromisoformat(iso.replace("Z", "+00:00")).timestamp() > now
    except Exception: return False
out = {}
claude_at = 0
try:
    raw = json.loads(Path(f"{H}/.claude.json").read_text())
    u = raw.get("cachedUsageUtilization", {}).get("utilization", {})
    # Newer Claude Code versions describe the same windows in a limits array.
    for limit in u.get("limits", []):
        kind = limit.get("kind")
        if kind in ("five_hour", "seven_day") and isinstance(limit.get("percent"), (int, float)):
            u[kind] = {"utilization": limit["percent"], "resets_at": limit.get("resets_at", "")}
    w = []
    for k, key in (("five_hour", "session"), ("seven_day", "weekly_all")):
        r = u.get(k) or {}
        if isinstance(r.get("utilization"), (int, float)):
            ok = live(r.get("resets_at") or "")
            w.append({"key": key, "percent": round(r["utilization"]) if ok else 0, "resetsAt": r["resets_at"] if ok else ""})
    out["claude"] = {"windows": w}
    # If the Claude desktop app's history (15-minute samples) is newer than ~/.claude.json, use that — Claude Code refreshes its cache only when /usage is opened, so it can be days stale
    #   Samples carry no reset time, so the 5-hour value only uses samples within 5 hours and the weekly value within 7 days
    fetched = raw.get("cachedUsageUtilization", {}).get("fetchedAtMs", 0) / 1000
    claude_at = fetched if w else 0
    smp = (json.loads(Path(f"{H}/Library/Application Support/Claude/plan-usage-history.json").read_text()).get("samples") or [])[-1:]
    if smp and smp[0]["t"] / 1000 > fetched:
        t, u = smp[0]["t"] / 1000, smp[0].get("u", {})
        nw = []
        if now - t < 5 * 3600 and isinstance(u.get("fh"), (int, float)): nw.append({"key": "session", "percent": round(u["fh"]), "resetsAt": ""})
        if now - t < 7 * 86400 and isinstance(u.get("sd"), (int, float)): nw.append({"key": "weekly_all", "percent": round(u["sd"]), "resetsAt": ""})
        if nw:
            out["claude"] = {"windows": nw}
            claude_at = t
except Exception: pass

# Pilo's local session.measure plugin reports after each Claude turn; it does
# not require the older /usage cache or access to account credentials.
for file in glob.glob(f"{H}/.pilo/usage/*.json"):
    try:
        row = json.loads(Path(file).read_text())
        at = row.get("at", 0) / 1000
        if at <= claude_at or now - at > 2 * 86400:
            continue
        limits = {r.get("kind"): r for r in row.get("rateLimits", [])}
        if not isinstance(limits.get("five_hour", {}).get("percentUsed"), (int, float)):
            continue
        windows = []
        for kind, key in (("five_hour", "session"), ("seven_day", "weekly_all")):
            limit = limits.get(kind, {})
            if not isinstance(limit.get("percentUsed"), (int, float)):
                continue
            reset = limit.get("resetsAt") or ""
            valid = live(reset) if reset else now - at < 1800
            # A past reset means a new window with no record yet → 0% (same as the sources above); dropping it would blank the cell
            windows.append({"key": key, "percent": round(limit["percentUsed"]) if valid else 0, "resetsAt": reset if valid else ""})
        if windows:
            out["claude"] = {"windows": windows}
            claude_at = at
    except (OSError, ValueError, TypeError, AttributeError):
        continue
try:
    fs = [f for d in ("sessions", "archived_sessions") for f in glob.glob(f"{H}/.codex/{d}/**/rollout-*.jsonl", recursive=True)]
    best = None
    # Candidates = 10 newest by name date + 10 newest by mtime (10-06). By name alone, new values appended to a resumed session with an old name are missed;
    #   by mtime alone, an old file gets picked when Codex touches all the times at once. The value is the newest by each line's timestamp
    cand = list(dict.fromkeys(sorted(fs, key=os.path.basename, reverse=True)[:10] + sorted(fs, key=os.path.getmtime, reverse=True)[:10]))
    for f in cand:
        with open(f, "rb") as fh:
            fh.seek(max(0, os.path.getsize(f) - 200000)); tail = fh.read().decode("utf8", "ignore")
        for line in tail.split("\n"):
            if '"rate_limits"' not in line: continue
            try: row = json.loads(line)
            except Exception: continue
            lim = (row.get("payload") or {}).get("rate_limits") or {}
            if not isinstance((lim.get("primary") or {}).get("used_percent"), (int, float)): continue
            at = row.get("timestamp", "")
            if not best or at > best[0]: best = (at, lim)
    if best:
        p, s = best[1].get("primary") or {}, best[1].get("secondary") or {}
        iso = lambda t: D.datetime.fromtimestamp(t, D.timezone.utc).isoformat() if t else ""
        c = {}
        ok = live(iso(p.get("resets_at"))); c.update(five=round(p["used_percent"]) if ok else 0, fiveResetsAt=iso(p.get("resets_at")) if ok else "")
        if isinstance(s.get("used_percent"), (int, float)):
            ok = live(iso(s.get("resets_at"))); c.update(week=round(s["used_percent"]) if ok else 0, weekResetsAt=iso(s.get("resets_at")) if ok else "")
        out["codex"] = c
except Exception: pass
print(json.dumps(out))
