//! Ports of the python3 snippets in the sketchybar plugins (ts, pilo, clock, agent, wifi, display).
//! Each command keeps the stdout contract of the snippet it replaces, including printing
//! nothing where python died on bad input, so the bash around it is unchanged.
use crate::sb::in_table;
use crate::sb_tables::EAW_WIDE;
use serde_json::{json, Map, Value};
use std::collections::HashMap;
use std::io::{Read, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

pub fn main(args: &[&str]) -> Option<i32> {
    let out = match args {
        ["ts-state"] => ts_state(&stdin_json().unwrap_or(json!({}))),
        ["ts-rows"] => ts_rows(&stdin_json()?)?,
        ["ts-dev"] => ts_dev(&stdin_json().unwrap_or(json!({}))),
        ["ts-vnc"] => ts_vnc(&stdin_json()?)?,
        ["pilo-agents"] => pilo_agents(&mut hc, &rex_agents(), now()),
        ["pilo-align", pw] => pilo_align(&stdin_json()?, &serde_json::from_str(&std::env::var("DISP").ok()?).ok()?, pw.parse().ok()?)?,
        ["clock-holidays", base] => clock_holidays(&stdin_text(), base)?,
        ["clock-hdays", base] => clock_hdays(&stdin_text(), base),
        ["agent-usage"] => {
            let home = PathBuf::from(std::env::var("HOME").ok()?);
            let t = now();
            agent_line(&collect_usage(&home, t, &fetch_claude_usage), t)
        }
        ["wifi-nets", saved, ssid, scan] => wifi_nets(saved, ssid, &std::fs::read_to_string(scan).ok()?)?,
        ["display", which] => display(&stdin_json()?, which)?,
        _ => return None,
    };
    let _ = std::io::stdout().write_all(out.as_bytes());
    Some(0)
}

fn stdin_text() -> String {
    let mut s = String::new();
    let _ = std::io::stdin().read_to_string(&mut s);
    s
}

fn stdin_json() -> Option<Value> {
    serde_json::from_str(&stdin_text()).ok()
}

fn now() -> f64 {
    SystemTime::now().duration_since(UNIX_EPOCH).map(|d| d.as_secs_f64()).unwrap_or(0.0)
}

/// python `str(v)` for the JSON scalars these scripts print.
fn py_str(v: &Value) -> String {
    match v {
        Value::String(s) => s.clone(),
        Value::Null => "None".into(),
        Value::Bool(b) => if *b { "True" } else { "False" }.into(),
        other => other.to_string(),
    }
}

/// python truthiness, for `x or default`.
fn truthy(v: Option<&Value>) -> Option<&Value> {
    v.filter(|v| match v {
        Value::Null => false,
        Value::Bool(b) => *b,
        Value::Number(n) => n.as_f64() != Some(0.0),
        Value::String(s) => !s.is_empty(),
        Value::Array(a) => !a.is_empty(),
        Value::Object(o) => !o.is_empty(),
    })
}

fn get_str<'a>(v: &'a Value, k: &str) -> &'a str {
    truthy(v.get(k)).and_then(Value::as_str).unwrap_or("")
}

fn is_num(v: Option<&Value>) -> bool {
    v.is_some_and(|v| v.is_number())
}

fn chars_take(s: &str, n: usize) -> String {
    s.chars().take(n).collect()
}

// ---------- tailscale (ts.sh) ----------

fn ts_state(d: &Value) -> String {
    let state = d.get("BackendState").map(py_str).unwrap_or_default();
    let net = truthy(d.get("CurrentTailnet")).map(|t| get_str(t, "Name")).unwrap_or("");
    format!("{state}\t{net}\n")
}

fn ts_full(p: &Value) -> String {
    let dns = get_str(p, "DNSName").split('.').next().unwrap_or("");
    if !dns.is_empty() {
        return dns.to_string();
    }
    p.get("HostName").map(py_str).unwrap_or_else(|| "?".into())
}

fn ts_ip(p: &Value) -> String {
    truthy(p.get("TailscaleIPs")).and_then(|a| a.get(0)).map(py_str).unwrap_or_default()
}

fn ts_online(p: &Value) -> bool {
    truthy(p.get("Online")).is_some()
}

fn ts_peers(d: &Value) -> Vec<&Value> {
    truthy(d.get("Peer")).and_then(Value::as_object).map(|o| o.values().collect()).unwrap_or_default()
}

fn ts_self(d: &Value) -> Value {
    truthy(d.get("Self")).cloned().unwrap_or(json!({}))
}

/// Common name prefix up to its last '-' (e.g. "myname-"), dropped so rows read macbookpro · iphone.
fn ts_prefix(d: &Value) -> String {
    let me = ts_self(d);
    let mut all = vec![&me];
    all.extend(ts_peers(d));
    let names: Vec<Vec<char>> = all.iter().map(|p| ts_full(p).chars().collect()).collect();
    let mut pre: Vec<char> = names.first().cloned().unwrap_or_default();
    for n in &names[1..] {
        let k = pre.iter().zip(n).take_while(|(a, b)| a == b).count();
        pre.truncate(k);
    }
    let pre: String = pre.into_iter().collect();
    match pre.rfind('-') {
        Some(i) if all.len() > 1 => pre[..=i].to_string(),
        _ => String::new(),
    }
}

fn ts_name(p: &Value, pre: &str) -> String {
    let full = ts_full(p);
    let rest: String = full.chars().skip(pre.chars().count()).collect();
    if rest.is_empty() { full } else { rest }
}

fn ts_sorted<'a>(d: &'a Value, key: impl Fn(&Value) -> String) -> Vec<&'a Value> {
    let mut peers = ts_peers(d);
    peers.sort_by_key(|p| (!ts_online(p), key(p)));
    peers
}

fn ts_rows(d: &Value) -> Option<String> {
    let pre = ts_prefix(d);
    let me = ts_self(d);
    let mut rows = vec![(ts_name(&me, &pre), ts_ip(&me), true, true, String::new())];
    for p in ts_sorted(d, |p| ts_name(p, &pre)) {
        let vnc = if p.get("OS").and_then(Value::as_str) == Some("macOS") {
            get_str(p, "DNSName").trim_end_matches('.').to_string()
        } else {
            String::new()
        };
        rows.push((ts_name(p, &pre), ts_ip(p), ts_online(p), false, vnc));
    }
    let mut out = String::new();
    for (n, ip, on, me, vnc) in rows.into_iter().take(8) {
        // keep clear of the IP on the right: name cell about 16 chars
        let n = if n.chars().count() > 16 { chars_take(&n, 15) + "…" } else { n };
        out += &format!("{n}\t{ip}\t{}\t{}\t{vnc}\n", if me { "me" } else { "peer" }, on as u8);
    }
    Some(out)
}

fn ts_dev(d: &Value) -> String {
    if d.get("BackendState").and_then(Value::as_str) != Some("Running") {
        return String::new();
    }
    let mut out = format!("{}\t1\n", ts_ip(&ts_self(d)));
    for p in ts_sorted(d, ts_full).into_iter().take(7) {
        let on = ts_online(p);
        out += &format!("{}\t{}\n", if on { ts_ip(p) } else { "offline".into() }, on as u8);
    }
    out
}

fn ts_vnc(d: &Value) -> Option<String> {
    let pre = ts_prefix(d);
    let mut out = String::new();
    for (i, p) in ts_sorted(d, |p| ts_name(p, &pre)).into_iter().take(7).enumerate() {
        if ts_online(p) && p.get("OS").and_then(Value::as_str) == Some("macOS") {
            out += &format!("{} {}\n", i + 2, chars_take(&ts_name(p, &pre), 16));
        }
    }
    Some(out)
}

// ---------- herdr agents (pilo.sh) ----------

/// `hc <args> --json`, `{}` on any failure or after 3s.
fn hc(args: &[&str]) -> Value {
    run_timeout("hc", &[args, &["--json"]].concat(), None, Duration::from_secs(3))
        .and_then(|o| serde_json::from_str(&o).ok())
        .unwrap_or(json!({}))
}

/// Agents in Rex terminals, from terminals/rex/scripts/agents.lua; `[]` when Rex is not running.
fn rex_agents() -> Value {
    const REX: &str = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex";
    let script = format!("{}/.dotfiles/terminals/rex/scripts/agents.lua", std::env::var("HOME").unwrap_or_default());
    run_timeout(REX, &["--autostart=false", "do", &script], None, Duration::from_secs(3))
        .and_then(|o| serde_json::from_str(&o).ok())
        .unwrap_or(json!([]))
}

const RANK: [&str; 4] = ["blocked", "stalled", "running", "idle"];

fn one_line(x: &str, n: usize) -> String {
    let mut o = String::new();
    let mut w = 0;
    for ch in x.split_whitespace().collect::<Vec<_>>().join(" ").chars() {
        w += if in_table(EAW_WIDE, ch) { 2 } else { 1 };
        if w > n {
            return o + "…";
        }
        o.push(ch);
    }
    o
}

fn ago(s: f64) -> String {
    let s = s.trunc() as i64;
    if s < 60 {
        format!("{s}s")
    } else if s < 3600 {
        format!("{}m", s / 60)
    } else {
        format!("{}h", s / 3600)
    }
}

fn pilo_agents(hc: &mut dyn FnMut(&[&str]) -> Value, rex: &Value, now: f64) -> String {
    let ls = hc(&["ls"]);
    let mut agents = Vec::new();
    for t in ls.get("terminals").and_then(Value::as_array).cloned().unwrap_or_default() {
        if truthy(t.get("status")).is_none() {
            continue; // shells have no status; agents do
        }
        let Some(addr) = t.get("address").map(py_str) else { return String::new() };
        let g = hc(&["get", &addr]);
        let status = truthy(g.get("status")).cloned().unwrap_or(json!({}));
        let st = match status.get("state") {
            Some(v) => v.as_str().map(String::from),
            None => t.get("status").and_then(Value::as_str).map(String::from),
        };
        let app = truthy(status.get("app")).or(truthy(t.get("agent"))).map(py_str).unwrap_or_else(|| "agent".into());
        let ms = g.get("status_ms").and_then(Value::as_f64).unwrap_or(now * 1000.0);
        let age = now - ms / 1000.0;
        let Some(mut st) = st else { continue };
        if st == "working" && age > 600.0 {
            st = "stalled".into();
        }
        let st = if st == "working" { "running".to_string() } else { st };
        let app = if app == "claude-code" { "claude".to_string() } else { app };
        let Some(rank) = RANK.iter().position(|r| *r == st) else { continue };
        let cwd = t.get("cwd").and_then(Value::as_str).unwrap_or("").to_string();
        agents.push((app, rank, cwd, age, addr));
    }
    // Rex states: idle · working · done · blocked · error. done and error mean the turn ended.
    for r in rex.as_array().into_iter().flatten() {
        let st = match r.get("state").and_then(Value::as_str) {
            Some("working") => "working",
            Some("blocked") => "blocked",
            Some(_) => "idle",
            None => continue,
        };
        let age = now - r.get("updated_at").and_then(Value::as_str).and_then(parse_iso).unwrap_or(now);
        let st = if st == "working" && age > 600.0 { "stalled" } else if st == "working" { "running" } else { st };
        let app = r.get("app").and_then(Value::as_str).unwrap_or("agent");
        let app = if app == "claude-code" { "claude" } else { app }.to_string();
        let Some(rank) = RANK.iter().position(|x| *x == st) else { continue };
        let cwd = r.get("cwd").and_then(Value::as_str).unwrap_or("").to_string();
        let id = |k: &str| r.get(k).and_then(Value::as_str).unwrap_or("").to_string();
        agents.push((app, rank, cwd, age, format!("rex:{}:{}", id("session_id"), id("block_id"))));
    }
    if agents.is_empty() {
        return "unbound\t0\t0\nnone\tno agent running in herdr or rex\tunbound\t\n".into();
    }
    let top = agents.iter().map(|a| a.1).min().unwrap_or(3);
    let count = |r: usize| agents.iter().filter(|a| a.1 == r).count();
    let mut out = format!("{}\t{}\t{}\n", RANK[top], count(2), count(0));
    agents.sort_by(|a, b| a.1.cmp(&b.1).then(a.3.partial_cmp(&b.3).unwrap_or(std::cmp::Ordering::Equal)));
    let word = ["needs approval", "no signal", "working", "idle"];
    for (app, rank, cwd, age, addr) in agents {
        let base = cwd.trim_end_matches('/').rsplit('/').next().unwrap_or("");
        let text = format!("{} · {} {}", if base.is_empty() { "~" } else { base }, word[rank], ago(age));
        out += &format!("{app}\t{}\t{}\t{addr}\n", one_line(&text, 40), RANK[rank]);
    }
    out
}

/// "right" when a PW-wide popup from the item's left edge would run off its display.
fn pilo_align(q: &Value, displays: &Value, pw: i64) -> Option<String> {
    let (k, r) = q.get("bounding_rects")?.as_object()?.iter().next()?;
    let x = r.get("origin")?.get(0)?.as_f64()?;
    let id: i64 = k.split('-').nth(1)?.parse().ok()?;
    let frame = displays.as_array()?.iter().find(|d| d.get("arrangement-id").and_then(Value::as_i64) == Some(id))?.get("frame")?;
    let w = frame.get("w")?.as_f64()?;
    Some(if x + pw as f64 > w - 5.0 { "right\n" } else { "left\n" }.into())
}

// ---------- calendar holidays (clock.sh) ----------

fn days_from_civil(y: i64, m: i64, d: i64) -> i64 {
    let y = if m <= 2 { y - 1 } else { y };
    let era = y.div_euclid(400);
    let yoe = y - era * 400;
    let doy = (153 * ((m + 9) % 12) + 2) / 5 + d - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    era * 146097 + doe - 719468
}

fn civil_from_days(z: i64) -> (i64, i64, i64) {
    let z = z + 719468;
    let era = z.div_euclid(146097);
    let doe = z - era * 146097;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    (yoe + era * 400 + (m <= 2) as i64, m, d)
}

fn py_int(s: &str) -> Option<i64> {
    s.trim().parse().ok()
}

/// python `date(y, m, d)` as a day number; None where python raises.
fn date(y: i64, m: i64, d: i64) -> Option<i64> {
    let days = days_from_civil(y, m, d);
    ((1..=12).contains(&m) && d >= 1 && civil_from_days(days) == (y, m, d)).then_some(days)
}

/// "MM.DD" in year y (python `date(y, int(s[:2]), int(s[3:]))`).
fn mmdd(y: i64, s: &str) -> Option<i64> {
    date(y, py_int(s.get(..2)?)?, py_int(s.get(3..)?)?)
}

/// python `a, _, b = k.partition("-"); b = b or a`
fn split_range(k: &str) -> (&str, &str) {
    let (a, b) = k.split_once('-').unwrap_or((k, ""));
    (a, if b.is_empty() { a } else { b })
}

fn year_of(base: &str) -> Option<i64> {
    py_int(base.get(..4)?)
}

/// Merges consecutive days of the same holiday into one "MM.DD-MM.DD\tname" row.
fn clock_holidays(input: &str, base: &str) -> Option<String> {
    let y = year_of(base)?;
    let mut rows: Vec<[String; 4]> = Vec::new();
    for l in input.split_inclusive('\n') {
        if !l.contains('\t') {
            continue;
        }
        let (k, n) = l.trim_end_matches('\n').split_once('\t')?;
        let (a, b) = split_range(k);
        rows.push([a.into(), b.into(), n.into(), n.replace(" 연휴", "").trim().to_string()]);
    }
    let next_day = |s: &str| -> Option<String> {
        let (_, m, d) = civil_from_days(mmdd(y, s)? + 1);
        Some(format!("{m:02}.{d:02}"))
    };
    let mut out: Vec<[String; 4]> = Vec::new();
    for r in &rows {
        if let Some(last) = out.last_mut() {
            if last[3] == r[3] && next_day(&last[1])? == r[0] {
                last[1] = r[1].clone();
                continue;
            }
        }
        out.push(r.clone());
    }
    let mut text = String::new();
    for [a, b, n, base] in &out {
        let range = if a != b { format!("{a}-{b}") } else { a.clone() };
        let shared = rows.iter().any(|x| x[3] == *base && x[2] != *base) && a != b;
        text += &format!("{range}\t{}\n", if shared { base } else { n });
    }
    Some(text)
}

/// Day numbers of the viewed month covered by holiday rows (python printed as it went, so a bad row stops the list there).
fn clock_hdays(input: &str, base: &str) -> String {
    let mut out = String::new();
    let (Some(y), Some(m)) = (year_of(base), base.get(5..7).and_then(py_int)) else { return out };
    for l in input.split_inclusive('\n') {
        if !l.contains('\t') {
            continue;
        }
        let (a, b) = split_range(l.split('\t').next().unwrap_or(""));
        let (Some(mut d), Some(e)) = (mmdd(y, a), mmdd(y, b)) else { return out };
        while d <= e {
            let (_, mm, dd) = civil_from_days(d);
            if mm == m {
                out += &format!("{dd}\n");
            }
            d += 1;
        }
    }
    out
}

// ---------- local time (libc) ----------

#[repr(C)]
struct Tm {
    sec: i32,
    min: i32,
    hour: i32,
    mday: i32,
    mon: i32,
    year: i32,
    wday: i32,
    yday: i32,
    isdst: i32,
    gmtoff: i64,
    zone: *const i8,
}

extern "C" {
    fn localtime_r(t: *const i64, tm: *mut Tm) -> *mut Tm;
    fn mktime(tm: *mut Tm) -> i64;
}

fn blank_tm() -> Tm {
    Tm { sec: 0, min: 0, hour: 0, mday: 0, mon: 0, year: 0, wday: 0, yday: 0, isdst: -1, gmtoff: 0, zone: std::ptr::null() }
}

fn local_tm(ts: f64) -> Tm {
    let t = ts.floor() as i64;
    let mut tm = blank_tm();
    unsafe { localtime_r(&t, &mut tm) };
    tm
}

/// python 3.9 `datetime.fromisoformat(s.replace("Z", "+00:00")).timestamp()`; naive times are local.
fn parse_iso(s: &str) -> Option<f64> {
    let s = s.replace('Z', "+00:00");
    if !s.is_ascii() || s.len() < 10 {
        return None;
    }
    let (ds, rest) = s.split_at(10);
    let b = ds.as_bytes();
    if b[4] != b'-' || b[7] != b'-' || !ds.chars().enumerate().all(|(i, c)| i == 4 || i == 7 || c.is_ascii_digit()) {
        return None;
    }
    let (y, mo, d) = (ds[..4].parse().ok()?, ds[5..7].parse().ok()?, ds[8..].parse().ok()?);
    let days = date(y, mo, d)?;
    let tstr = rest.get(1..).unwrap_or("");
    if rest.is_empty() {
        return local_ts(y, mo, d, [0, 0, 0, 0]);
    }
    let tz_pos = tstr.find('-').or_else(|| tstr.find('+'));
    let (time, tz) = match tz_pos {
        Some(i) => (&tstr[..i], Some((tstr.as_bytes()[i], &tstr[i + 1..]))),
        None => (tstr, None),
    };
    let t = hh_mm_ss_ff(time)?;
    if t[0] > 23 || t[1] > 59 || t[2] > 59 {
        return None;
    }
    match tz {
        None => local_ts(y, mo, d, t),
        Some((sign, z)) => {
            if ![5, 8, 15].contains(&z.len()) {
                return None;
            }
            let o = hh_mm_ss_ff(z)?;
            let off = (o[0] * 3600 + o[1] * 60 + o[2]) as f64 + o[3] as f64 / 1e6;
            let off = if sign == b'-' { -off } else { off };
            if off.abs() >= 86400.0 {
                return None;
            }
            Some((days * 86400 + t[0] * 3600 + t[1] * 60 + t[2]) as f64 + t[3] as f64 / 1e6 - off)
        }
    }
}

/// python 3.9 `_parse_hh_mm_ss_ff`: [hour, minute, second, microsecond].
fn hh_mm_ss_ff(s: &str) -> Option<[i64; 4]> {
    let two = |p: usize| s.get(p..p + 2).filter(|x| x.bytes().all(|c| c.is_ascii_digit())).and_then(|x| x.parse().ok());
    let mut comps = [0i64; 4];
    let mut pos = 0;
    for comp in 0..3 {
        comps[comp] = two(pos)?;
        pos += 2;
        match s.as_bytes().get(pos) {
            None => break,
            Some(_) if comp >= 2 => break,
            Some(b':') => pos += 1,
            Some(_) => return None,
        }
    }
    if pos < s.len() {
        if s.as_bytes()[pos] != b'.' {
            return None;
        }
        let frac = &s[pos + 1..];
        if !(frac.len() == 3 || frac.len() == 6) || !frac.bytes().all(|c| c.is_ascii_digit()) {
            return None;
        }
        comps[3] = frac.parse::<i64>().ok()? * if frac.len() == 3 { 1000 } else { 1 };
    }
    Some(comps)
}

fn local_ts(y: i64, mo: i64, d: i64, t: [i64; 4]) -> Option<f64> {
    let mut tm = blank_tm();
    (tm.year, tm.mon, tm.mday) = (y as i32 - 1900, mo as i32 - 1, d as i32);
    (tm.hour, tm.min, tm.sec) = (t[0] as i32, t[1] as i32, t[2] as i32);
    let ts = unsafe { mktime(&mut tm) };
    Some(ts as f64 + t[3] as f64 / 1e6)
}

// ---------- agent usage (agent.sh, was usage.py + its formatter) ----------

/// One usage window: percent and, while it is live, the reset time (epoch seconds).
#[derive(Clone, Debug, PartialEq, Default)]
struct Window {
    percent: Option<i64>,
    reset: Option<f64>,
}

#[derive(Debug, Default, PartialEq)]
struct Usage {
    claude_session: Window,
    claude_week: Window,
    codex_five: Window,
    codex_week: Window,
    grok_week: Window,
}

fn py_round(x: f64) -> i64 {
    x.round_ties_even() as i64
}

fn read_json(p: &Path) -> Option<Value> {
    serde_json::from_str(&std::fs::read_to_string(p).ok()?).ok()
}

/// A window whose reset already passed is unused in the new window → 0%, no reset time.
fn window(percent: f64, reset: Option<f64>, now: f64) -> Window {
    match reset.filter(|r| *r > now) {
        Some(r) => Window { percent: Some(py_round(percent)), reset: Some(r) },
        None => Window { percent: Some(0), reset: None },
    }
}

fn collect_usage(home: &Path, now: f64, fetch: &dyn Fn() -> Option<Value>) -> Usage {
    let mut u = Usage::default();
    claude_usage(&mut u, home, now, fetch);
    codex_usage(&mut u, home, now);
    grok_usage(&mut u, home, now);
    u
}

/// Claude: usage API (≤ every 5 min, cached), ~/.claude.json's cache when newer, desktop app samples when newer still.
fn claude_usage(u: &mut Usage, home: &Path, now: f64, fetch: &dyn Fn() -> Option<Value>) -> Option<()> {
    let cache = home.join(".cache/claude-usage.json");
    let mut fresh = read_json(&cache).unwrap_or(json!({}));
    let fetched_ms = |v: &Value| v.get("fetchedAtMs").and_then(Value::as_f64).unwrap_or(0.0);
    if now - fetched_ms(&fresh) / 1000.0 > 300.0 {
        if let Some(util) = fetch() {
            fresh = json!({"fetchedAtMs": (now * 1000.0) as i64, "utilization": util});
            if let Some(dir) = cache.parent() {
                let _ = std::fs::create_dir_all(dir);
            }
            let _ = std::fs::write(&cache, fresh.to_string());
        }
    }
    let mut raw = read_json(&home.join(".claude.json"))?;
    let raw_ms = raw.get("cachedUsageUtilization").map(fetched_ms).unwrap_or(0.0);
    if fetched_ms(&fresh) > raw_ms {
        raw.as_object_mut()?.insert("cachedUsageUtilization".into(), fresh);
    }
    let cuu = raw.get("cachedUsageUtilization").cloned().unwrap_or(json!({}));
    let mut util: Map<String, Value> = match cuu.get("utilization") {
        None => Map::new(),
        Some(v) => v.as_object()?.clone(),
    };
    // Newer Claude Code versions describe the same windows in a limits array.
    for limit in util.get("limits").and_then(Value::as_array).cloned().unwrap_or_default() {
        let kind = limit.get("kind").and_then(Value::as_str).unwrap_or("");
        if (kind == "five_hour" || kind == "seven_day") && is_num(limit.get("percent")) {
            let reset = limit.get("resets_at").cloned().unwrap_or(json!(""));
            util.insert(kind.into(), json!({"utilization": limit["percent"], "resets_at": reset}));
        }
    }
    let mut session = None;
    let mut week = None;
    for (k, slot) in [("five_hour", &mut session), ("seven_day", &mut week)] {
        let r = truthy(util.get(k)).cloned().unwrap_or(json!({}));
        if let Some(p) = r.get("utilization").filter(|v| v.is_number()).and_then(Value::as_f64) {
            let reset = truthy(r.get("resets_at")).and_then(Value::as_str).and_then(parse_iso);
            *slot = Some(window(p, reset, now));
        }
    }
    (u.claude_session, u.claude_week) = (session.unwrap_or_default(), week.unwrap_or_default());

    // Desktop app samples (15 min) carry no reset time, so they only count within their window.
    let fetched = fetched_ms(&cuu) / 1000.0;
    let hist = read_json(&home.join("Library/Application Support/Claude/plan-usage-history.json"))?;
    let last = truthy(hist.get("samples")).and_then(Value::as_array)?.last()?.clone();
    let t = last.get("t")?.as_f64()? / 1000.0;
    if t > fetched {
        let su = last.get("u").cloned().unwrap_or(json!({}));
        let pick = |k: &str, span: f64| {
            (now - t < span).then(|| su.get(k).filter(|v| v.is_number()).and_then(Value::as_f64)).flatten()
                .map(|p| Window { percent: Some(py_round(p)), reset: None })
        };
        let (s, w) = (pick("fh", 5.0 * 3600.0), pick("sd", 7.0 * 86400.0));
        if s.is_some() || w.is_some() {
            (u.claude_session, u.claude_week) = (s.unwrap_or_default(), w.unwrap_or_default());
        }
    }
    Some(())
}

fn walk_rollouts(dir: &Path, out: &mut Vec<PathBuf>) {
    let Ok(rd) = std::fs::read_dir(dir) else { return };
    for e in rd.flatten() {
        let name = e.file_name().to_string_lossy().into_owned();
        if name.starts_with('.') {
            continue; // glob's ** skips hidden entries
        }
        let path = e.path();
        if path.is_dir() {
            walk_rollouts(&path, out);
        } else if name.starts_with("rollout-") && name.ends_with(".jsonl") {
            out.push(path);
        }
    }
}

/// Codex: the newest rate_limits record in the last 200KB of recent rollout-*.jsonl files.
fn codex_usage(u: &mut Usage, home: &Path, now: f64) -> Option<()> {
    let mut files = Vec::new();
    for d in ["sessions", "archived_sessions"] {
        walk_rollouts(&home.join(".codex").join(d), &mut files);
    }
    // 10 newest by name + 10 newest by mtime: a resumed session keeps an old name, and Codex sometimes touches every mtime at once.
    let base = |p: &PathBuf| p.file_name().map(|n| n.to_string_lossy().into_owned()).unwrap_or_default();
    let mtime = |p: &PathBuf| std::fs::metadata(p).and_then(|m| m.modified()).ok();
    let mut by_name = files.clone();
    by_name.sort_by_key(|p| std::cmp::Reverse(base(p)));
    let mut by_mtime = files;
    by_mtime.sort_by_key(|p| std::cmp::Reverse(mtime(p)));
    let mut cand: Vec<PathBuf> = Vec::new();
    for p in by_name.into_iter().take(10).chain(by_mtime.into_iter().take(10)) {
        if !cand.contains(&p) {
            cand.push(p);
        }
    }
    let mut best: Option<(String, Value)> = None;
    for f in cand {
        let Ok(mut fh) = std::fs::File::open(&f) else { continue };
        let size = fh.metadata().map(|m| m.len()).unwrap_or(0);
        use std::io::Seek;
        let _ = fh.seek(std::io::SeekFrom::Start(size.saturating_sub(200_000)));
        let mut bytes = Vec::new();
        let _ = fh.read_to_end(&mut bytes);
        for line in String::from_utf8_lossy(&bytes).split('\n') {
            if !line.contains("\"rate_limits\"") {
                continue;
            }
            let Ok(row) = serde_json::from_str::<Value>(line) else { continue };
            let lim = truthy(row.get("payload")).and_then(|p| truthy(p.get("rate_limits"))).cloned().unwrap_or(json!({}));
            if !is_num(truthy(lim.get("primary")).and_then(|p| p.get("used_percent"))) {
                continue;
            }
            let at = row.get("timestamp").map(py_str).unwrap_or_default();
            if best.as_ref().is_none_or(|(b, _)| at > *b) {
                best = Some((at, lim));
            }
        }
    }
    let (_, lim) = best?;
    let reset = |w: &Value| truthy(w.get("resets_at")).and_then(Value::as_f64);
    let p = truthy(lim.get("primary")).cloned().unwrap_or(json!({}));
    u.codex_five = window(p.get("used_percent")?.as_f64()?, reset(&p), now);
    let s = truthy(lim.get("secondary")).cloned().unwrap_or(json!({}));
    if let Some(pct) = s.get("used_percent").filter(|v| v.is_number()).and_then(Value::as_f64) {
        u.codex_week = window(pct, reset(&s), now);
    }
    Some(())
}

/// Grok: newest sand-client-persistence blob with usage.percentUsed (weekly pool, no 5-hour window).
fn grok_usage(u: &mut Usage, home: &Path, now: f64) -> Option<()> {
    let root = home.join("Library/Application Support/Grok Bot/sand-client-persistence");
    let mut best: Option<(f64, Value)> = None;
    for e in std::fs::read_dir(root).ok()?.flatten() {
        if !e.file_name().to_string_lossy().ends_with(".blob") {
            continue;
        }
        let Some(raw) = read_json(&e.path()) else { continue };
        let reading = raw.get("value").filter(|v| v.is_object()).and_then(|v| truthy(v.get("reading"))).cloned().unwrap_or(json!({}));
        let usage = truthy(reading.get("usage")).cloned().unwrap_or(json!({}));
        if !is_num(usage.get("percentUsed")) {
            continue;
        }
        let at = truthy(reading.get("readAtMs")).and_then(Value::as_f64).unwrap_or(0.0);
        if best.as_ref().is_none_or(|(b, _)| at > *b) {
            best = Some((at, usage));
        }
    }
    let (_, usage) = best?;
    let reset = truthy(usage.get("nextResetMs")).and_then(Value::as_f64).unwrap_or(0.0) / 1000.0;
    u.grok_week = window(usage.get("percentUsed")?.as_f64()?, (reset != 0.0).then_some(reset), now);
    Some(())
}

/// GET api.anthropic.com/api/oauth/usage with Claude Code's keychain OAuth token.
/// The token goes to curl on stdin, never in argv where `ps` would show it.
fn fetch_claude_usage() -> Option<Value> {
    let cred = run_timeout("/usr/bin/security", &["find-generic-password", "-s", "Claude Code-credentials", "-w"], None, Duration::from_secs(5))?;
    let cred: Value = serde_json::from_str(&cred).ok()?;
    let token = cred.get("claudeAiOauth")?.get("accessToken")?.as_str()?;
    if token.contains(['\r', '\n']) {
        return None;
    }
    let headers = format!("Authorization: Bearer {token}\nanthropic-beta: oauth-2025-04-20\n");
    let body = run_timeout(
        "/usr/bin/curl",
        &["-fsS", "--max-time", "5", "-H", "@-", "https://api.anthropic.com/api/oauth/usage"],
        Some(headers.as_bytes()),
        Duration::from_secs(6),
    )?;
    serde_json::from_str(&body).ok()
}

fn fmt_local(ts: Option<f64>, monthday: bool) -> String {
    match ts {
        Some(t) => {
            let tm = local_tm(t);
            if monthday {
                format!("{:02}.{:02} reset", tm.mon + 1, tm.mday)
            } else {
                format!("{:02}:{:02} reset", tm.hour, tm.min)
            }
        }
        None => "—".into(),
    }
}

/// Elapsed share of the window, in %.
fn elapsed(ts: Option<f64>, span: f64, now: f64) -> String {
    match ts {
        Some(t) => (((span - (t - now)) / span * 100.0).clamp(0.0, 100.0) as i64).to_string(),
        None => "—".into(),
    }
}

/// The 15 tab-separated fields agent.sh reads.
fn agent_line(u: &Usage, now: f64) -> String {
    let v = |w: &Window| w.percent.map_or("—".into(), |p| p.to_string());
    let (h5, wk) = (5.0 * 3600.0, 7.0 * 86400.0);
    let f = [
        v(&u.claude_session),
        fmt_local(u.claude_session.reset, false),
        v(&u.claude_week),
        fmt_local(u.claude_week.reset, true),
        v(&u.codex_five),
        fmt_local(u.codex_five.reset, false),
        v(&u.codex_week),
        fmt_local(u.codex_week.reset, true),
        elapsed(u.claude_session.reset, h5, now),
        elapsed(u.claude_week.reset, wk, now),
        elapsed(u.codex_five.reset, h5, now),
        elapsed(u.codex_week.reset, wk, now),
        v(&u.grok_week),
        fmt_local(u.grok_week.reset, true),
        elapsed(u.grok_week.reset, wk, now),
    ];
    f.join("\t") + "\n"
}

// ---------- wifi (wifi.sh) and display (display.sh) ----------

/// Saved networks in range now, current first then strongest, at most 4: "name\trssi".
fn wifi_nets(saved: &str, cur: &str, scan_file: &str) -> Option<String> {
    let mut scan: HashMap<&str, i64> = HashMap::new();
    for l in scan_file.split('\n').skip(1) {
        if let Some((n, r)) = l.rsplit_once('\t') {
            scan.insert(n, py_int(r)?);
        }
    }
    let mut vis: Vec<&str> = saved.split('\n').filter(|l| !l.is_empty() && scan.contains_key(l)).collect();
    vis.sort_by_key(|n| (*n != cur, -scan[n]));
    Some(vis.iter().take(4).map(|n| format!("{n}\t{}\n", scan[n])).collect())
}

/// "<DirectDisplayID> <x> <w> <Main|UUID>" for the bar display (BAR_DISPLAY: main or an arrangement id).
fn display(ds: &Value, which: &str) -> Option<String> {
    let ds = ds.as_array()?;
    let fnum = |d: &Value, k: &str| d.get("frame").and_then(|f| f.get(k)).and_then(Value::as_f64);
    let is_main = |d: &Value| fnum(d, "x") == Some(0.0) && fnum(d, "y") == Some(0.0);
    let d = ds
        .iter()
        .find(|d| (which == "main" && is_main(d)) || d.get("arrangement-id").map(py_str).as_deref() == Some(which))
        .or(ds.first())?;
    let tag = if is_main(d) { "Main".to_string() } else { py_str(d.get("UUID")?) };
    Some(format!(
        "{} {} {} {tag}\n",
        py_str(d.get("DirectDisplayID")?),
        fnum(d, "x")?.trunc() as i64,
        fnum(d, "w")?.trunc() as i64
    ))
}

/// Run a command, return stdout; None on failure or timeout (the child is killed).
fn run_timeout(cmd: &str, args: &[&str], stdin: Option<&[u8]>, limit: Duration) -> Option<String> {
    let mut child = Command::new(cmd)
        .args(args)
        .stdin(if stdin.is_some() { Stdio::piped() } else { Stdio::null() })
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .ok()?;
    if let (Some(data), Some(mut pipe)) = (stdin, child.stdin.take()) {
        let _ = pipe.write_all(data);
    }
    let mut stdout = child.stdout.take()?;
    let reader = std::thread::spawn(move || {
        let mut s = Vec::new();
        let _ = stdout.read_to_end(&mut s);
        s
    });
    let start = Instant::now();
    loop {
        match child.try_wait().ok()? {
            Some(status) => {
                let out = reader.join().ok()?;
                return status.success().then(|| String::from_utf8_lossy(&out).into_owned());
            }
            None if start.elapsed() > limit => {
                let _ = child.kill();
                let _ = child.wait();
                return None;
            }
            None => std::thread::sleep(Duration::from_millis(10)),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tmp_home(files: &[(&str, Value)]) -> PathBuf {
        let dir = std::env::temp_dir().join(format!("dotbin-test-{}-{}", std::process::id(), files.len() as u64 * 7919 + rand_suffix()));
        for (name, v) in files {
            let p = dir.join(name);
            std::fs::create_dir_all(p.parent().unwrap()).unwrap();
            std::fs::write(p, v.to_string()).unwrap();
        }
        std::fs::create_dir_all(&dir).unwrap();
        dir
    }

    fn rand_suffix() -> u64 {
        SystemTime::now().duration_since(UNIX_EPOCH).unwrap().subsec_nanos() as u64
    }

    const NOW: f64 = 1_800_000_000.0;
    const RESET: &str = "2027-01-16T12:00:00Z";

    fn usage(files: &[(&str, Value)]) -> Usage {
        collect_usage(&tmp_home(files), NOW, &|| None)
    }

    // ported from tests/sketchybar/test_usage.py
    #[test]
    fn missing_usage_stays_unknown() {
        let u = usage(&[(".claude.json", json!({}))]);
        assert_eq!(u.claude_session, Window::default());
    }

    #[test]
    fn legacy_usage_cache() {
        let u = usage(&[(".claude.json", json!({"cachedUsageUtilization": {
            "fetchedAtMs": NOW * 1000.0, "utilization": {"five_hour": {"utilization": 42, "resets_at": RESET}}}}))]);
        assert_eq!(u.claude_session.percent, Some(42));
        assert_eq!(u.claude_session.reset, parse_iso(RESET));
    }

    #[test]
    fn new_limits_array() {
        let u = usage(&[(".claude.json", json!({"cachedUsageUtilization": {
            "fetchedAtMs": NOW * 1000.0, "utilization": {"limits": [{"kind": "five_hour", "percent": 37, "resets_at": RESET}]}}}))]);
        assert_eq!(u.claude_session.percent, Some(37));
    }

    #[test]
    fn grok_weekly_pool() {
        let reset_ms = parse_iso(RESET).unwrap() * 1000.0;
        let blob = "Library/Application Support/Grok Bot/sand-client-persistence";
        let u = usage(&[
            (&format!("{blob}/usage.blob"), json!({"value": {"reading": {"readAtMs": NOW * 1000.0, "usage": {"percentUsed": 17, "nextResetMs": reset_ms}}}})),
            (&format!("{blob}/other.blob"), json!({"value": "not-json-object"})),
        ]);
        assert_eq!(u.grok_week, Window { percent: Some(17), reset: Some(reset_ms / 1000.0) });
    }

    #[test]
    fn expired_window_reads_zero_and_line_shape() {
        let u = usage(&[(".claude.json", json!({"cachedUsageUtilization": {
            "fetchedAtMs": NOW * 1000.0, "utilization": {"five_hour": {"utilization": 42, "resets_at": "2020-01-01T00:00:00Z"}}}}))]);
        assert_eq!(u.claude_session, Window { percent: Some(0), reset: None });
        let line = agent_line(&u, NOW);
        assert_eq!(line.trim_end().split('\t').collect::<Vec<_>>(), ["0", "—", "—", "—", "—", "—", "—", "—", "—", "—", "—", "—", "—", "—", "—"]);
    }

    #[test]
    fn iso_like_python_39() {
        assert_eq!(parse_iso("2026-11-04T15:00:00+00:00"), Some(1793804400.0));
        assert_eq!(parse_iso("2026-11-04T15:00:00.583817+00:00"), Some(1793804400.583817));
        assert_eq!(parse_iso("2026-11-04T15:00:00.58+00:00"), None);
        assert_eq!(parse_iso("2026-11-04T15:00:00.123+05:30"), Some(1793784600.123));
        assert_eq!(parse_iso("2026-11-04T25:00"), None);
        assert_eq!(parse_iso(""), None);
    }

    #[test]
    fn holidays_merge() {
        let input = "09.24\t추석 연휴\n09.25\t추석\n09.26\t추석 연휴\n10.03\t개천절\n";
        assert_eq!(clock_holidays(input, "2026-09-01").unwrap(), "09.24-09.26\t추석\n10.03\t개천절\n");
        assert_eq!(clock_hdays("09.29-10.02\tx\n", "2026-10-01"), "1\n2\n");
        assert_eq!(clock_holidays("13.40\ta\n13.41\ta\n", "2026-01-01"), None);
    }

    #[test]
    fn tailscale_rows() {
        let d = json!({"BackendState": "Running", "CurrentTailnet": {"Name": "net"},
            "Self": {"DNSName": "me-macbookpro.ts.net.", "TailscaleIPs": ["100.1.1.1"]},
            "Peer": {"a": {"DNSName": "me-iphone.ts.net.", "TailscaleIPs": ["100.1.1.2"], "Online": true, "OS": "iOS"},
                     "b": {"DNSName": "me-mini.ts.net.", "TailscaleIPs": ["100.1.1.3"], "Online": true, "OS": "macOS"},
                     "c": {"HostName": "old", "TailscaleIPs": ["100.1.1.4"], "Online": false}}});
        assert_eq!(ts_state(&d), "Running\tnet\n");
        // "old" shares no prefix, so nothing is stripped
        assert_eq!(ts_rows(&d).unwrap(), "me-macbookpro\t100.1.1.1\tme\t1\t\nme-iphone\t100.1.1.2\tpeer\t1\t\nme-mini\t100.1.1.3\tpeer\t1\tme-mini.ts.net\nold\t100.1.1.4\tpeer\t0\t\n");
        assert_eq!(ts_dev(&d), "100.1.1.1\t1\n100.1.1.2\t1\n100.1.1.3\t1\noffline\t0\n");
        assert_eq!(ts_vnc(&d).unwrap(), "3 me-mini\n");
    }

    #[test]
    fn pilo_rows() {
        let mut fake = |a: &[&str]| match a {
            ["ls"] => json!({"terminals": [{"address": "t1", "status": "working", "cwd": "/x/proj/", "agent": "claude-code"},
                                           {"address": "t2", "status": "idle", "cwd": "/"}, {"address": "sh"}]}),
            ["get", "t1"] => json!({"status": {"state": "working", "app": "claude-code"}, "status_ms": (NOW - 700.0) * 1000.0}),
            _ => json!({}),
        };
        assert_eq!(pilo_agents(&mut fake, &json!([]), NOW), "stalled\t0\t0\nclaude\tproj · no signal 11m\tstalled\tt1\nagent\t~ · idle 0s\tidle\tt2\n");
        assert_eq!(pilo_agents(&mut |_: &[&str]| json!({}), &json!([]), NOW), "unbound\t0\t0\nnone\tno agent running in herdr or rex\tunbound\t\n");
        let rex = json!([{"app": "codex", "state": "blocked", "cwd": "/x/api", "session_id": "s1", "block_id": "b1", "updated_at": "2027-01-15T08:00:00+00:00"},
                         {"app": "claude-code", "state": "done", "cwd": "/x/web", "session_id": "s2", "block_id": "b2"}]);
        assert_eq!(pilo_agents(&mut |_: &[&str]| json!({}), &rex, NOW), "blocked\t0\t1\ncodex\tapi · needs approval 0s\tblocked\trex:s1:b1\nclaude\tweb · idle 0s\tidle\trex:s2:b2\n");
        assert_eq!(one_line("a  b\tc", 40), "a b c");
        assert_eq!(one_line("한국어", 4), "한국…");
    }

    #[test]
    fn wifi_and_display() {
        assert_eq!(wifi_nets("home\nwork\ncafe\n", "work", "ok\nhome\t-60\nwork\t-70\nx\t-10\n").unwrap(), "work\t-70\nhome\t-60\n");
        assert_eq!(wifi_nets("a", "", "ok\na\tbad\n"), None);
        let ds = json!([{"DirectDisplayID": 1, "arrangement-id": 1, "UUID": "U1", "frame": {"x": 0.0, "y": 0.0, "w": 1512.0}},
                        {"DirectDisplayID": 5, "arrangement-id": 2, "UUID": "U2", "frame": {"x": 1512.0, "y": -200.0, "w": 2560.0}}]);
        assert_eq!(display(&ds, "main").unwrap(), "1 0 1512 Main\n");
        assert_eq!(display(&ds, "2").unwrap(), "5 1512 2560 U2\n");
        let q = json!({"bounding_rects": {"display-2": {"origin": [2300.0, 0.0]}}});
        assert_eq!(pilo_align(&q, &ds, 500).unwrap(), "right\n");
    }
}
