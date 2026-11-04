//! Helpers for the sketchybar plugins in suckless/mac_os/sketchybar/plugins/.
//! They replace per-call python3 (~40-60ms startup) and perl width/fit forks.
use crate::sb_tables::{CJK, EMOJI_PRESENTATION};
use serde_json::Value;
use std::io::{Read, Write};
use std::process::{Command, Stdio};
use std::time::Duration;
use unicode_segmentation::UnicodeSegmentation;

pub fn main(args: &[&str]) -> i32 {
    match args {
        ["width", text] => println!("{}", text_width(text)),
        ["width"] => println!("0"),
        ["fit", rest @ ..] => {
            // like perl `shift || 123`: missing, 0 or non-numeric falls back to 123
            let max = rest.first().and_then(|m| m.parse::<f64>().ok()).filter(|m| *m != 0.0).unwrap_or(123.0);
            let mut input = Vec::new();
            let _ = std::io::stdin().read_to_end(&mut input);
            let _ = std::io::stdout().write_all(fit_lines(&String::from_utf8_lossy(&input), max).as_bytes());
        }
        ["popup-items"] => {
            let mut input = String::new();
            let _ = std::io::stdin().read_to_string(&mut input);
            match serde_json::from_str(&input).ok().as_ref().map(popup_items) {
                Some(items) => println!("{}", items.join("\n")),
                None => return 1,
            }
        }
        ["left-edge", x0] => match left_edge(x0) {
            Some(v) => println!("{v}"),
            None => return 1,
        },
        ["label-props"] => {
            let mut input = String::new();
            let _ = std::io::stdin().read_to_string(&mut input);
            match serde_json::from_str(&input).ok().as_ref().and_then(label_props) {
                Some(v) => println!("{v}"),
                None => return 1,
            }
        }
        _ if crate::sb_plugins::main(args).is_some() => {}
        _ => {
            eprintln!("usage: dotbin sb width TEXT | fit MAX | popup-items <json | left-edge X0 | label-props <json | ts-state|ts-rows|ts-dev|ts-vnc <json | pilo-agents | pilo-align PW <json | clock-holidays|clock-hdays BASE <rows | agent-usage | wifi-nets SAVED SSID FILE | display WHICH <json");
            return 2;
        }
    }
    0
}

pub(crate) fn in_table(table: &[(u32, u32)], c: char) -> bool {
    let c = c as u32;
    table.binary_search_by(|&(lo, hi)| if hi < c { std::cmp::Ordering::Less } else if lo > c { std::cmp::Ordering::Greater } else { std::cmp::Ordering::Equal }).is_ok()
}

/// Width (pt) of one grapheme: 12pt monospace 7.2, Hangul/Han/kana 10.375 (measured), emoji 16.
fn grapheme_width(g: &str) -> f64 {
    if g.chars().any(|c| in_table(EMOJI_PRESENTATION, c)) {
        16.0
    } else if g.chars().any(|c| in_table(CJK, c)) {
        10.375
    } else {
        7.2
    }
}

fn text_width(text: &str) -> i64 {
    let w: f64 = text.graphemes(true).map(grapheme_width).sum();
    (w + 0.999) as i64
}

/// Cuts the second tab field of each line to fit `max` pt and appends "…".
fn fit_lines(input: &str, max: f64) -> String {
    let mut out = String::new();
    let mut lines: Vec<&str> = input.split('\n').collect();
    if lines.last() == Some(&"") {
        lines.pop(); // perl's <STDIN> loop does not see a line after the final newline
    }
    for line in lines {
        let mut fields: Vec<String> = line.split('\t').map(String::from).collect();
        if line.is_empty() {
            fields.clear();
        }
        if fields.len() > 1 {
            let gs: Vec<&str> = fields[1].graphemes(true).collect();
            let total: f64 = gs.iter().map(|g| grapheme_width(g)).sum();
            if total > max {
                let mut kept = String::new();
                let mut x = 7.2; // room for …
                for g in gs {
                    let w = grapheme_width(g);
                    if x + w > max {
                        break;
                    }
                    x += w;
                    kept.push_str(g);
                }
                fields[1] = format!("{}…", kept.trim_end());
            }
        }
        out += &fields.join("\t");
        out.push('\n');
    }
    out
}

/// `sketchybar --query NAME`, retried while the reply is empty (it is when events pile up).
fn query(name: &str, tries: usize) -> Option<Value> {
    for i in 0..tries {
        let out = Command::new("sketchybar").args(["--query", name]).stderr(Stdio::null()).output().ok()?;
        let text = String::from_utf8_lossy(&out.stdout);
        if !text.trim().is_empty() {
            return serde_json::from_str(&text).ok();
        }
        if i + 1 < tries {
            std::thread::sleep(Duration::from_millis(50));
        }
    }
    None
}

fn popup_items(v: &Value) -> Vec<String> {
    v.get("popup")
        .and_then(|p| p.get("items"))
        .and_then(Value::as_array)
        .map(|a| a.iter().map(|i| i.as_str().map(String::from).unwrap_or_else(|| i.to_string())).collect())
        .unwrap_or_default()
}

fn num(v: &Value, path: &[&str]) -> Option<f64> {
    path.iter().try_fold(v, |v, k| match k.parse::<usize>() {
        Ok(i) if v.is_array() => v.get(i),
        _ => v.get(*k),
    })?
    .as_f64()
}

fn first_rect(v: &Value) -> Option<&Value> {
    v.get("bounding_rects")?.as_object()?.values().next()
}

/// Right end of the left island once the front_app label reaches its target width,
/// relative to the bar's left edge `x0` (see media.sh fill()).
fn left_edge(x0: &str) -> Option<i64> {
    let x0: i64 = x0.trim().parse().ok()?;
    let island = query("island.left", 3)?;
    let front = query("front_app", 3)?;
    left_edge_from(&island, &front, x0)
}

fn left_edge_from(island: &Value, front: &Value, x0: i64) -> Option<i64> {
    let r = first_rect(island)?;
    let fr = first_rect(front)?;
    let icon = front.get("icon")?;
    let iw = if icon.get("drawing")?.as_str()? == "on" {
        num(icon, &["width"])? + num(icon, &["padding_left"])? + num(icon, &["padding_right"])?
    } else {
        0.0
    };
    let edge = num(r, &["origin", "0"])? + num(r, &["size", "0"])? + iw + num(front, &["label", "width"])?
        - num(fr, &["size", "0"])?;
    Some(edge.trunc() as i64 - x0)
}

/// "<drawn label width> <label padding>" for left_label.sh.
fn label_props(d: &Value) -> Option<String> {
    let label = d.get("label")?;
    let mut width = num(label, &["width"])?;
    if width <= 0.0 {
        width = num(first_rect(d)?, &["size", "0"])? - num(d, &["geometry", "padding_left"])?
            - num(d, &["geometry", "padding_right"])?;
    }
    let (pl, pr) = (label.get("padding_left")?, label.get("padding_right")?);
    // python prints int + int as an int, anything else as a float
    let padding = match (pl.as_i64(), pr.as_i64()) {
        (Some(a), Some(b)) => (a + b).to_string(),
        _ => format!("{:?}", pl.as_f64()? + pr.as_f64()?),
    };
    Some(format!("{} {padding}", width.round_ties_even() as i64))
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn widths() {
        assert_eq!(text_width(""), 0);
        assert_eq!(text_width("abc"), 22); // 21.6 + .999
        assert_eq!(text_width("한국"), 21);
        assert_eq!(text_width("😀"), 16);
        assert_eq!(text_width("e\u{301}"), 8); // combining accent is one grapheme
    }

    #[test]
    fn fit() {
        assert_eq!(fit_lines("k\tHello world long\n", 50.0), "k\tHello…\n");
        assert_eq!(fit_lines("k\tshort\tc\t\n", 230.0), "k\tshort\tc\t\n");
        assert_eq!(fit_lines("solo\n\nx", 10.0), "solo\n\nx\n");
        assert_eq!(fit_lines("", 10.0), "");
    }

    #[test]
    fn popup_and_geometry() {
        assert_eq!(popup_items(&json!({"popup": {"items": ["a.p.0", "a.p.1"]}})), vec!["a.p.0", "a.p.1"]);
        assert!(popup_items(&json!({})).is_empty());

        let island = json!({"bounding_rects": {"display-1": {"origin": [10.0, 0.0], "size": [200.5, 30.0]}}});
        let front = json!({
            "icon": {"drawing": "on", "width": 16, "padding_left": 0, "padding_right": 6},
            "label": {"width": 50},
            "bounding_rects": {"display-1": {"origin": [0, 0], "size": [40.0, 30.0]}}
        });
        // int(10 + 200.5 + 22 + 50 - 40) - 3 = 239
        assert_eq!(left_edge_from(&island, &front, 3), Some(239));

        let item = json!({"label": {"width": 0, "padding_left": 4, "padding_right": 8},
            "geometry": {"padding_left": 2, "padding_right": 3},
            "bounding_rects": {"d": {"size": [42.5, 1]}}});
        assert_eq!(label_props(&item).as_deref(), Some("38 12")); // round(37.5) ties to even
    }
}
