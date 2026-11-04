//! Rust ports of the tmux status-bar scripts in terminals/tmux/scripts/.
//! tmux forks these every 2s, so the win is skipping bash startup and the
//! extra pmset/awk/date forks the shell versions need.
use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::time::{Duration, SystemTime};

mod sb;
mod sb_plugins;
mod sb_tables;

const ICON_CPU: &str = "\u{F4BC}"; // oct-cpu
const ICON_MEM: &str = "\u{F035B}"; // md-memory
const ICON_DISK: &str = "\u{F02CA}"; // md-harddisk
const ICON_WATT: &str = "\u{F140B}"; // md-flash
const ICON_BUSY: &str = "\u{F051F}"; // timer-sand
const ICON_BLOCKED: &str = "\u{F0026}"; // alert
const ICON_DONE: &str = "\u{F012C}"; // check
const ICON_IDLE: &str = "\u{F09DE}"; // circle-small

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let a: Vec<&str> = args.iter().map(String::as_str).collect();
    match a.as_slice() {
        ["sysstat"] => print!("{}", sysstat()),
        ["watt"] => println!("{}", watt(&run("pmset", &["-g", "batt"]))),
        ["agents"] => print!("{}", agents_status(&scan())),
        ["agents", "--list"] => {
            for (pane, state, label) in scan() {
                println!("{pane}\t{state}\t{label}");
            }
        }
        ["agents", "--pick"] => agents_pick(),
        ["agents", "--preview", pane] => agents_preview(pane),
        ["agents", "--focus", pane] => focus(pane),
        ["focus-history", "record", attached, target] => history_record(attached, target),
        ["focus-history", "back", client, current] => history_back(client, current),
        ["sb", rest @ ..] => std::process::exit(sb::main(rest)),
        _ => {
            eprintln!("usage: dotbin sysstat | watt | agents [--list|--pick|--preview P|--focus P] | focus-history record|back A B | sb ...");
            std::process::exit(2);
        }
    }
}

/// stdout of a command, empty on any failure: a status bar shows nothing rather than an error.
fn run(cmd: &str, args: &[&str]) -> String {
    Command::new(cmd)
        .args(args)
        .stderr(Stdio::null())
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).into_owned())
        .unwrap_or_default()
}

fn tmux(args: &[&str]) {
    let _ = Command::new("tmux").args(args).stdout(Stdio::null()).stderr(Stdio::null()).status();
}

// ---------- sysstat: cpu · mem · disk from sketchybar's meters.sh cache ----------

fn sysstat() -> String {
    let cache = PathBuf::from(env::var("HOME").unwrap_or_default()).join(".cache/sketchybar");
    let fresh = fs::metadata(cache.join("cat"))
        .and_then(|m| m.modified())
        .map(|t| SystemTime::now().duration_since(t).unwrap_or_default() < Duration::from_secs(30))
        .unwrap_or(false);
    if !fresh {
        return String::new();
    }
    let cat = fs::read_to_string(cache.join("cat")).unwrap_or_default();
    let disk = fs::read_to_string(cache.join("disk")).unwrap_or_default();
    format_sysstat(&cat, &disk)
}

fn format_sysstat(cat: &str, disk: &str) -> String {
    let mut it = cat.split_whitespace();
    let cpu = it.next().unwrap_or("");
    let mem = it.next().unwrap_or("");
    let color = |v: &str, ok: &'static str| if v.parse::<i64>().unwrap_or(0) >= 80 { "#e78284" } else { ok };
    // "324 / 494 GB · 170 GB free" → 170 (awk's $(NF-2) on the first line)
    let fields: Vec<&str> = disk.lines().next().unwrap_or("").split_whitespace().collect();
    let free = if fields.len() >= 3 { fields[fields.len() - 3] } else { "" };

    const SEP: &str = " #[fg=#51576d]│ ";
    let mut out = format!(
        "#[fg={}]{ICON_CPU} {cpu}%{SEP}#[fg={}]{ICON_MEM} {mem}%",
        color(cpu, "#a6d189"),
        color(mem, "#8caaee")
    );
    if !free.is_empty() {
        out += &format!("{SEP}#[fg=#838ba7]{ICON_DISK} {free}G");
    }
    out + SEP + "#[default]"
}

// ---------- watt: power source / rough draw from `pmset -g batt` ----------

fn watt(batt: &str) -> String {
    if batt.lines().next().unwrap_or("").contains("AC Power") {
        return format!("{ICON_WATT} AC");
    }
    let pct = first_match(batt, |w| w.ends_with('%') && w[..w.len() - 1].chars().all(|c| c.is_ascii_digit()))
        .map(|w| w.trim_end_matches('%').to_string());
    let Some(pct) = pct else { return format!("{ICON_WATT} ") };
    let minutes = first_match(batt, |w| {
        let w = w.trim_end_matches(';');
        matches!(w.split_once(':'), Some((h, m)) if !h.is_empty() && !m.is_empty()
            && h.chars().all(|c| c.is_ascii_digit()) && m.chars().all(|c| c.is_ascii_digit()))
    })
    .and_then(|w| {
        let (h, m) = w.trim_end_matches(';').split_once(':')?;
        Some(h.parse::<u64>().ok()? * 60 + m.parse::<u64>().ok()?)
    });
    match minutes {
        // Assume a 70Wh battery, as the shell version did; exact draw needs sudo powermetrics.
        Some(total) if total > 0 => {
            let wh = 70 * pct.parse::<u64>().unwrap_or(0) / 100;
            format!("{ICON_WATT} {}W", wh * 60 / total)
        }
        _ => format!("{ICON_WATT} {pct}%"),
    }
}

fn first_match(text: &str, pred: impl Fn(&str) -> bool) -> Option<&str> {
    text.split(|c: char| c.is_whitespace() || c == ';')
        .map(|w| w.trim_end_matches(';'))
        .find(|w| pred(w))
}

// ---------- agents: which agent pane is busy, blocked on you, or done ----------

#[derive(Clone, Copy, PartialEq, Debug)]
enum State {
    Busy,
    Blocked,
    Done,
    Idle,
}

impl State {
    fn parse(s: &str) -> Option<State> {
        Some(match s {
            "busy" => State::Busy,
            "blocked" => State::Blocked,
            "done" => State::Done,
            "idle" => State::Idle,
            _ => return None,
        })
    }
}

impl std::fmt::Display for State {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        f.write_str(match self {
            State::Busy => "busy",
            State::Blocked => "blocked",
            State::Done => "done",
            State::Idle => "idle",
        })
    }
}

const AGENTS: &[&str] = &["claude", "codex", "opencode", "aider", "crush"];
const TERM_APPS: &[&str] = &["Ghostty", "WezTerm", "Alacritty", "kitty", "Terminal", "iTerm2", "Neovide"];

/// Working: fullscreen TUI shows an elapsed timer ("… (1m 14s · ↓ 4.1k tokens)");
/// the inline TUI shows "esc to interrupt".
fn is_busy(screen: &str) -> bool {
    if screen.contains("esc to interrupt") {
        return true;
    }
    screen.match_indices("s · ").any(|(i, _)| screen[..i].ends_with(|c: char| c.is_ascii_digit()))
}

fn is_blocked(screen: &str) -> bool {
    screen.contains("Do you want") || screen.contains("Allow this tool")
}

/// Next state for one pane. `done` is an edge (busy → not busy), the only thing
/// carried across ticks. A pane really in front of you is never done/blocked.
fn next_state(screen: &str, prev: Option<State>, watched: bool) -> State {
    let s = if is_busy(screen) {
        State::Busy
    } else if is_blocked(screen) {
        State::Blocked
    } else if prev == Some(State::Busy) {
        State::Done
    } else {
        prev.unwrap_or(State::Idle)
    };
    if watched && s != State::Busy {
        State::Idle
    } else {
        s
    }
}

fn state_path() -> PathBuf {
    let tmp = env::var("TMPDIR").unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(tmp).join("tmux-agent-state")
}

/// The pane on screen is only "watched" when a terminal is also the frontmost app.
/// lsappinfo, not osascript: AppleScript needs Automation consent and blocks on its dialog.
fn terminal_frontmost() -> bool {
    let front = run("lsappinfo", &["front"]);
    let name = run("lsappinfo", &["info", "-only", "name", front.trim()]);
    TERM_APPS.iter().any(|app| name.contains(app))
}

fn scan() -> Vec<(String, State, String)> {
    let path = state_path();
    let prev: HashMap<String, State> = fs::read_to_string(&path)
        .unwrap_or_default()
        .lines()
        .filter_map(|l| {
            let (id, st) = l.split_once(' ')?;
            Some((id.to_string(), State::parse(st.trim())?))
        })
        .collect();

    let panes = run(
        "tmux",
        &[
            "list-panes",
            "-a",
            "-F",
            "#{pane_id}|#{pane_current_command}|#{window_name}|#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}",
        ],
    );
    let mut rows = Vec::new();
    let mut seen_ok: Option<bool> = None; // lazy: skip two lsappinfo forks when no agent runs
    for line in panes.lines() {
        // like bash `read a b c d`: the last field keeps any extra '|'
        let mut f = line.splitn(4, '|');
        let (Some(pane), Some(cmd), Some(label)) = (f.next(), f.next(), f.next()) else { continue };
        let onscreen = f.next().unwrap_or("");
        if !AGENTS.contains(&cmd) {
            continue;
        }
        let screen = run("tmux", &["capture-pane", "-p", "-t", pane]);
        let watched = onscreen == "1" && *seen_ok.get_or_insert_with(terminal_frontmost);
        let was = prev.get(pane).copied();
        let state = next_state(&screen, was, watched);

        let was = was.unwrap_or(State::Idle);
        if state != was {
            match state {
                State::Blocked | State::Done => notify(pane, label, state),
                _ if matches!(was, State::Blocked | State::Done) => unnotify(pane),
                _ => {}
            }
        }
        rows.push((pane.to_string(), state, label.to_string()));
    }

    let tmp = path.with_extension(std::process::id().to_string());
    let body: String = rows.iter().map(|(p, s, _)| format!("{p} {s}\n")).collect();
    if fs::write(&tmp, body).is_ok() {
        let _ = fs::rename(&tmp, &path);
    }
    rows
}

/// Fire and forget: terminal-notifier can hang, and the status bar must never wait.
fn spawn_detached(args: &[&str]) {
    let _ = Command::new("timeout")
        .arg("10")
        .arg("terminal-notifier")
        .args(args)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn();
}

fn notify(pane: &str, label: &str, state: State) {
    // Two tones: "come approve this" vs "it's done" without looking.
    let (icon, msg, sound) = match state {
        State::Blocked => (ICON_BLOCKED, "waiting for your approval", "Ping"),
        State::Done => (ICON_DONE, "finished", "Glass"),
        _ => return,
    };
    let exe = env::current_exe().map(|p| p.display().to_string()).unwrap_or_else(|_| "dotbin".into());
    spawn_detached(&[
        "-group",
        &format!("agent-{pane}"),
        "-title",
        &format!("{icon} {label}"),
        "-message",
        msg,
        "-sound",
        sound,
        "-execute",
        &format!("{exe} agents --focus {pane}"),
    ]);
}

fn unnotify(pane: &str) {
    spawn_detached(&["-remove", &format!("agent-{pane}")]);
}

fn agents_status(rows: &[(String, State, String)]) -> String {
    let mut busy = 0;
    let mut out = String::new();
    for (_, state, label) in rows {
        match state {
            State::Busy => busy += 1,
            State::Blocked => out += &format!("#[fg=yellow]{ICON_BLOCKED} {label} "),
            State::Done => out += &format!("#[fg=green]{ICON_DONE} {label} "),
            State::Idle => {}
        }
    }
    if busy > 0 {
        out = format!("#[fg=blue]{ICON_BUSY} {busy} {out}");
    }
    if out.is_empty() {
        out
    } else {
        out + "#[fg=brightblack]│#[default]"
    }
}

fn pick_line(pane: &str, state: State, label: &str) -> String {
    let (rank, color, icon, text) = match state {
        State::Blocked => (0, "33", ICON_BLOCKED, "\x1b[33mwaiting on you\x1b[0m"),
        State::Done => (1, "32", ICON_DONE, "\x1b[32mfinished\x1b[0m"),
        State::Busy => (2, "34", ICON_BUSY, "\x1b[90mworking…\x1b[0m"),
        State::Idle => (3, "90", ICON_IDLE, "\x1b[90midle\x1b[0m"),
    };
    format!("{rank}\t{pane}\t\x1b[{color}m{icon}\x1b[0m  {label:<26}{text}")
}

fn agents_pick() {
    let mut lines: Vec<String> = scan().iter().map(|(p, s, l)| pick_line(p, *s, l)).collect();
    if lines.is_empty() {
        println!("\n  {ICON_IDLE}  no agent panes");
        // shortcut: waits the full 2s instead of returning on a keypress; add termios raw read if it annoys.
        std::thread::sleep(Duration::from_secs(2));
        return;
    }
    lines.sort();
    let exe = env::current_exe().map(|p| p.display().to_string()).unwrap_or_else(|_| "dotbin".into());
    let child = Command::new("fzf")
        .env("FZF_DEFAULT_OPTS", "")
        .args([
            "--ansi", "--no-sort", "--cycle", "--highlight-line",
            "--border=none", "--margin=0", "--padding=0", "--info=inline-right",
            "--prompt=❯ ", "--pointer=▌",
            "--header=enter  jump    ctrl-f  freeze scroll    esc  cancel", "--header-first",
            "--color=fg:-1,bg:-1,gutter:-1,fg+:green:bold,bg+:-1,hl:green,hl+:green:bold,pointer:green,prompt:green,info:8,header:8,border:8",
            "--delimiter=\t", "--with-nth=3", "--nth=3",
            "--bind", "tab:down,btab:up",
            "--preview", &format!("{exe} agents --preview {{2}}"),
            "--preview-window", "right:62%:follow:noinfo:border-left",
            "--bind", "ctrl-f:change-preview-window(right:62%:noinfo:border-left|right:62%:follow:noinfo:border-left)",
        ])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn();
    let Ok(mut child) = child else { return };
    if let Some(mut stdin) = child.stdin.take() {
        let _ = stdin.write_all((lines.join("\n") + "\n").as_bytes());
    }
    let Ok(out) = child.wait_with_output() else { return };
    if !out.status.success() {
        return;
    }
    let sel = String::from_utf8_lossy(&out.stdout);
    if let Some(pane) = sel.split('\t').nth(1).filter(|p| !p.is_empty()) {
        focus(pane);
    }
}

/// Live view of a pane for the fzf preview, redrawn every second. \x1b[2J clears
/// fzf's preview buffer so each cycle replaces the last instead of appending.
fn agents_preview(pane: &str) {
    let mut stdout = std::io::stdout();
    loop {
        let screen = run("tmux", &["capture-pane", "-pe", "-S", "-400", "-t", pane]);
        let body = trim_trailing_blank(&screen);
        if write!(stdout, "\x1b[2J\x1b[H{body}").and_then(|_| stdout.flush()).is_err() {
            return; // fzf closed the preview pipe
        }
        std::thread::sleep(Duration::from_secs(1));
    }
}

fn trim_trailing_blank(s: &str) -> String {
    let lines: Vec<&str> = s.lines().collect();
    let last = lines.iter().rposition(|l| !l.trim().is_empty()).map_or(0, |i| i + 1);
    lines[..last].iter().map(|l| format!("{l}\n")).collect()
}

fn focus(pane: &str) {
    let session = run("tmux", &["display", "-pt", pane, "#{session_name}"]);
    tmux(&["switch-client", "-t", session.trim()]);
    tmux(&["select-window", "-t", pane]);
    tmux(&["select-pane", "-t", pane]);
    let _ = Command::new("open").args(["-a", "Ghostty"]).stderr(Stdio::null()).status();
}

// ---------- focus-history: MRU "session_id:window_id" list in @focus_history ----------

const MAX_HISTORY: usize = 30;

fn history_push(history: &str, target: &str) -> String {
    std::iter::once(target)
        .chain(history.split_whitespace().filter(|e| *e != target))
        .take(MAX_HISTORY)
        .collect::<Vec<_>>()
        .join(" ")
}

/// Drops closed targets; returns (kept history, first live target that isn't current).
fn history_prune<'a>(history: &'a str, live: &str, current: &str) -> (String, Option<&'a str>) {
    let live: Vec<&str> = live.lines().collect();
    let kept: Vec<&str> = history.split_whitespace().filter(|e| live.contains(e)).collect();
    let dest = kept.iter().copied().find(|e| *e != current);
    (kept.join(" "), dest)
}

fn history_record(attached: &str, target: &str) {
    // session-window-changed also fires for sessions nobody is looking at.
    if attached == "0" {
        return;
    }
    let history = run("tmux", &["show", "-gqv", "@focus_history"]);
    tmux(&["set", "-g", "@focus_history", &history_push(&history, target)]);
}

fn history_back(client: &str, current: &str) {
    let history = run("tmux", &["show", "-gqv", "@focus_history"]);
    let live = run("tmux", &["list-windows", "-a", "-F", "#{session_id}:#{window_id}"]);
    let (kept, dest) = history_prune(&history, &live, current);
    tmux(&["set", "-g", "@focus_history", &kept]);
    match dest {
        Some(d) => tmux(&["switch-client", "-c", client, "-t", d]),
        None => tmux(&["display", "-c", client, "No previous session or window"]),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sysstat_matches_shell_output() {
        let out = format_sysstat("8 49\n", "337 / 494 GB · 158 GB free\n");
        assert_eq!(
            out,
            format!("#[fg=#a6d189]{ICON_CPU} 8% #[fg=#51576d]│ #[fg=#8caaee]{ICON_MEM} 49% #[fg=#51576d]│ #[fg=#838ba7]{ICON_DISK} 158G #[fg=#51576d]│ #[default]")
        );
        assert!(format_sysstat("85 90", "").starts_with("#[fg=#e78284]"));
        assert!(!format_sysstat("1 2", "").contains(ICON_DISK));
    }

    #[test]
    fn watt_cases() {
        assert_eq!(watt("Now drawing from 'AC Power'\n -InternalBattery-0 (id=1)\t100%; charged; 0:00 remaining"), format!("{ICON_WATT} AC"));
        let bat = "Now drawing from 'Battery Power'\n -InternalBattery-0 (id=22282339)\t68%; discharging; 2:58 remaining present: true\n";
        // 70*68/100 = 47 Wh; 47*60/178 = 15
        assert_eq!(watt(bat), format!("{ICON_WATT} 15W"));
        let no_est = "Now drawing from 'Battery Power'\n -InternalBattery-0 (id=1)\t68%; discharging; (no estimate) present: true\n";
        assert_eq!(watt(no_est), format!("{ICON_WATT} 68%"));
        let zero = "Now drawing from 'Battery Power'\n -InternalBattery-0 (id=1)\t68%; discharging; 0:00 remaining\n";
        assert_eq!(watt(zero), format!("{ICON_WATT} 68%"));
    }

    #[test]
    fn agent_states() {
        assert!(is_busy("✻ Thinking… (1m 14s · ↓ 4.1k tokens)"));
        assert!(is_busy("press esc to interrupt"));
        assert!(!is_busy("costs · nothing"));
        assert_eq!(next_state("Do you want to proceed?", None, false), State::Blocked);
        assert_eq!(next_state("prompt >", Some(State::Busy), false), State::Done);
        assert_eq!(next_state("prompt >", Some(State::Done), false), State::Done);
        assert_eq!(next_state("prompt >", Some(State::Busy), true), State::Idle);
        assert_eq!(next_state("12s · ", Some(State::Idle), true), State::Busy);
        assert_eq!(next_state("prompt >", None, false), State::Idle);
    }

    #[test]
    fn agents_status_line() {
        let rows = vec![
            ("%1".into(), State::Busy, "a".into()),
            ("%2".into(), State::Blocked, "b".into()),
            ("%3".into(), State::Idle, "c".into()),
        ];
        assert_eq!(
            agents_status(&rows),
            format!("#[fg=blue]{ICON_BUSY} 1 #[fg=yellow]{ICON_BLOCKED} b #[fg=brightblack]│#[default]")
        );
        assert_eq!(agents_status(&[]), "");
    }

    #[test]
    fn focus_history() {
        assert_eq!(history_push("$1:@1 $2:@2 $1:@1", "$2:@2"), "$2:@2 $1:@1 $1:@1");
        let long: Vec<String> = (0..40).map(|i| format!("$0:@{i}")).collect();
        assert_eq!(history_push(&long.join(" "), "new").split(' ').count(), MAX_HISTORY);
        assert_eq!(history_push("", "$1:@1"), "$1:@1");

        let (kept, dest) = history_prune("$1:@1 $9:@9 $2:@2", "$1:@1\n$2:@2\n", "$1:@1");
        assert_eq!(kept, "$1:@1 $2:@2");
        assert_eq!(dest, Some("$2:@2"));
        assert_eq!(history_prune("$1:@1", "$1:@1\n", "$1:@1").1, None);
    }

    #[test]
    fn preview_trims_trailing_blank_lines() {
        assert_eq!(trim_trailing_blank("a\n\nb\n  \n\n"), "a\n\nb\n");
        assert_eq!(trim_trailing_blank("\n\n"), "");
    }
}
