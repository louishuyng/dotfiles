# Louis Cyberpunk Start Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A fish-only cyberpunk start page that renders a gradient ANSI-shadow LOUIS logo plus kernel/session/repo info and a random cyberpunk quote on top-level interactive shells.

**Architecture:** Three small fish files under `terminals/fish/`: `functions/louis_greet.fish` (renderer), `functions/louis.fish` (manual command), `conf.d/louis_start.fish` (auto-run guard). All work done in fish with raw ANSI escapes — no external scripts.

**Tech Stack:** fish shell (≥3.7), POSIX `uname`/`sysctl`/`git`, xterm-256 ANSI escapes.

**No commits:** Per user instruction, do NOT run `git commit` during this implementation. Leave changes staged/unstaged.

---

## File Structure

| File | Purpose |
|------|---------|
| `terminals/fish/functions/louis_greet.fish` | Main render function: ASCII art + gradient + info panel + quote. Uses three private helpers (`_louis_uptime`, `_louis_git_info`, `_louis_quote`) defined in the same file. |
| `terminals/fish/functions/louis.fish` | One-liner that delegates to `louis_greet`. Provides the `louis` command. |
| `terminals/fish/conf.d/louis_start.fish` | Auto-run guard with SHLVL / TERM_PROGRAM / LOUIS_GREET_SHOWN checks. Fires `louis_greet` when conditions pass. |

Spec reference: `docs/superpowers/specs/2026-05-30-louis-start-page-design.md`.

---

### Task 1: Skeleton renderer with art + gradient

**Files:**
- Create: `terminals/fish/functions/louis_greet.fish`

- [ ] **Step 1: Write the function with art and per-row gradient**

```fish
function louis_greet --description 'Cyberpunk LOUIS start page'
    set -l art \
        '██╗      ██████╗ ██╗   ██╗██╗███████╗' \
        '██║     ██╔═══██╗██║   ██║██║██╔════╝' \
        '██║     ██║   ██║██║   ██║██║███████╗' \
        '██║     ██║   ██║██║   ██║██║╚════██║' \
        '███████╗╚██████╔╝╚██████╔╝██║███████║' \
        '╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚══════╝'

    set -l grad 51 45 99 135 165 201

    echo
    for i in (seq (count $art))
        printf '  \e[38;5;%sm%s\e[0m\n' $grad[$i] $art[$i]
    end
end
```

- [ ] **Step 2: Verify visually**

Run: `fish -c 'source terminals/fish/functions/louis_greet.fish; louis_greet'`
Expected: six rows of LOUIS in cyan→magenta gradient, two-space left padding, blank line above.

---

### Task 2: Boot separator and tag line

**Files:**
- Modify: `terminals/fish/functions/louis_greet.fish`

- [ ] **Step 1: Append separator + tag block after the art loop, before the final `end`**

```fish
    printf '  \e[38;5;60m─────────────────────────────────────────────\e[0m\n'
    printf '  \e[38;5;51m>> phosphor.cyber // online \e[5m_\e[0m\n'
    echo
```

The `\e[5m` toggles SGR blink for the trailing underscore; terminals that ignore blink show a static `_`.

- [ ] **Step 2: Verify visually**

Run: `fish -c 'source terminals/fish/functions/louis_greet.fish; louis_greet'`
Expected: art followed by muted gray rule, then `>> phosphor.cyber // online _` in cyan with blinking underscore, then a blank line.

---

### Task 3: Kernel info row

**Files:**
- Modify: `terminals/fish/functions/louis_greet.fish`

- [ ] **Step 1: Add a private helper `_louis_row` and the kernel row**

Add this helper before `function louis_greet`:

```fish
function _louis_row
    # $argv[1] = key (cyan), $argv[2..] = value tokens
    set -l key $argv[1]
    set -e argv[1]
    set -l value (string join \e'[38;5;240m · \e[38;5;255m' -- $argv)
    printf '   \e[38;5;201m▸\e[0m \e[38;5;45m%-9s\e[0m \e[38;5;255m%s\e[0m\n' $key $value
end
```

Inside `louis_greet`, replace the trailing blank `echo` from Task 2 with:

```fish
    set -l u (uname -srm | string split ' ')
    _louis_row kernel "$u[1] $u[2]" $u[3]
```

(Keep the final `echo` for spacing at the very end of the function.)

- [ ] **Step 2: Verify**

Run: `fish -c 'source terminals/fish/functions/louis_greet.fish; louis_greet'`
Expected: a line like `   ▸ kernel    Darwin 25.5.0 · arm64` with magenta arrow, cyan key, white value, dim middle dot.

---

### Task 4: Session info row (host · fish · uptime)

**Files:**
- Modify: `terminals/fish/functions/louis_greet.fish`

- [ ] **Step 1: Add the `_louis_uptime` helper**

Add before `function louis_greet`:

```fish
function _louis_uptime
    set -l boot (sysctl -n kern.boottime | string match -rg 'sec = (\d+)')
    if test -z "$boot"
        echo '?'
        return
    end
    set -l secs (math (date +%s) - $boot)
    set -l d (math --scale=0 $secs / 86400)
    set -l h (math --scale=0 "($secs % 86400) / 3600")
    set -l m (math --scale=0 "($secs % 3600) / 60")
    if test $d -gt 0
        echo "$d"d" "$h"h"
    else if test $h -gt 0
        echo "$h"h" "$m"m"
    else
        echo "$m"m"
    end
end
```

- [ ] **Step 2: Append the session row inside `louis_greet`, after the kernel row**

```fish
    _louis_row session (prompt_hostname) "fish $FISH_VERSION" "up "(_louis_uptime)
```

- [ ] **Step 3: Verify**

Run: `fish -c 'source terminals/fish/functions/louis_greet.fish; louis_greet'`
Expected: `   ▸ session   <hostname> · fish 3.7.x · up 2d 4h` (numbers match your actual uptime).

---

### Task 5: Conditional repo row

**Files:**
- Modify: `terminals/fish/functions/louis_greet.fish`

- [ ] **Step 1: Add the `_louis_git_info` helper**

Add before `function louis_greet`:

```fish
function _louis_git_info
    git -C $PWD rev-parse --is-inside-work-tree >/dev/null 2>&1; or return 1
    set -l root (git -C $PWD rev-parse --show-toplevel)
    set -l name (basename $root)
    set -l branch (git -C $PWD symbolic-ref --short HEAD 2>/dev/null)
    test -z "$branch"; and set branch (git -C $PWD rev-parse --short HEAD)
    set -l dirty (git -C $PWD status --porcelain | count)
    if test $dirty -gt 0
        echo $name $branch "$dirty dirty"
    else
        echo $name $branch
    end
end
```

- [ ] **Step 2: Add the repo row inside `louis_greet` after the session row**

```fish
    set -l repo_info (_louis_git_info)
    if test -n "$repo_info"
        _louis_row repo $repo_info
    end
```

- [ ] **Step 3: Verify in a repo**

Run: `cd ~/.dotfiles && fish -c 'source terminals/fish/functions/louis_greet.fish; louis_greet'`
Expected: row like `   ▸ repo       .dotfiles · main · N dirty`.

- [ ] **Step 4: Verify outside a repo**

Run: `cd /tmp && fish -c 'source ~/.dotfiles/terminals/fish/functions/louis_greet.fish; louis_greet'`
Expected: no `repo` row appears.

---

### Task 6: Cyberpunk quote with wrapping

**Files:**
- Modify: `terminals/fish/functions/louis_greet.fish`

- [ ] **Step 1: Add the `_louis_quote` helper**

Add before `function louis_greet`:

```fish
function _louis_quote
    set -l quotes \
        "The sky above the port was the color of television, tuned to a dead channel. — Gibson" \
        "Hello, friend. Hello, friend? That's lame. — Mr. Robot" \
        "Net is vast and infinite. — Ghost in the Shell" \
        "I never asked for this. — Adam Jensen" \
        "The street finds its own uses for things. — Gibson" \
        "Reality is a thing of the past. — Snow Crash" \
        "All those moments will be lost in time, like tears in rain. — Blade Runner" \
        "Cyberspace. A consensual hallucination experienced daily by billions. — Neuromancer" \
        "Wake up, Samurai. We have a city to burn. — Cyberpunk 2077" \
        "What if everything you see is more than what you see? — Ghost in the Shell" \
        "Information wants to be free. — Stewart Brand" \
        "The future is already here — it's just not very evenly distributed. — Gibson"

    set -l n (count $quotes)
    set -l idx (math (random) % $n + 1)
    set -l text $quotes[$idx]

    set -l cols 80
    if command -q tput
        set cols (tput cols 2>/dev/null); or set cols 80
    end
    set -l max (math $cols - 8)

    # Soft-wrap on word boundaries
    set -l words (string split ' ' -- $text)
    set -l line ''
    set -l out
    for w in $words
        if test (string length -- "$line $w") -gt $max
            set out $out $line
            set line $w
        else if test -z "$line"
            set line $w
        else
            set line "$line $w"
        end
    end
    test -n "$line"; and set out $out $line

    for l in $out
        printf '   \e[38;5;240m░\e[0m \e[3;38;5;247m%s\e[0m \e[38;5;240m░\e[0m\n' $l
    end
end
```

- [ ] **Step 2: Append a blank line then call the quote helper inside `louis_greet`**

After the repo row block, add:

```fish
    echo
    _louis_quote
    echo
```

(Remove any earlier trailing `echo` you added in Task 2/3 so spacing isn't doubled — only one blank line between panel and quote, and one trailing blank line at the very end.)

- [ ] **Step 3: Verify**

Run: `fish -c 'source terminals/fish/functions/louis_greet.fish; louis_greet'`
Expected: one or two lines (depending on quote length and terminal width) framed by `░ … ░`, italic dim gray text. Different quote each invocation (run twice to confirm).

---

### Task 7: `louis` command wrapper

**Files:**
- Create: `terminals/fish/functions/louis.fish`

- [ ] **Step 1: Write the wrapper**

```fish
function louis --description 'Print the LOUIS cyberpunk start page'
    louis_greet
end
```

- [ ] **Step 2: Verify**

Run: `fish -c 'source terminals/fish/functions/louis_greet.fish; source terminals/fish/functions/louis.fish; louis'`
Expected: identical output to `louis_greet`.

---

### Task 8: conf.d auto-run guard

**Files:**
- Create: `terminals/fish/conf.d/louis_start.fish`

- [ ] **Step 1: Write the guard**

```fish
status is-interactive; or exit 0
test "$SHLVL" = 1; or exit 0
test "$TERM_PROGRAM" = vscode; and exit 0
test "$TERM_PROGRAM" = cursor; and exit 0
set -q LOUIS_GREET_SHOWN; and exit 0

set -gx LOUIS_GREET_SHOWN 1
louis_greet
```

- [ ] **Step 2: Verify auto-run fires in a top-level shell**

Run: `env -i HOME=$HOME PATH=$PATH SHELL=(which fish) SHLVL=0 fish -i -c 'true' 2>&1 | head -20`
Expected: LOUIS art appears in the captured output. (We set `SHLVL=0` so fish increments to 1 on launch.)

- [ ] **Step 3: Verify guard skips nested shells**

Run: `fish -i -c 'fish -i -c "true"' 2>&1 | grep -c phosphor.cyber`
Expected: `1` (printed once by the outer shell only — the inner SHLVL=2 shell is skipped).

- [ ] **Step 4: Verify guard skips in VSCode-flagged terminals**

Run: `env TERM_PROGRAM=vscode SHLVL=0 fish -i -c 'true' 2>&1 | grep -c phosphor.cyber`
Expected: `0`.

---

### Task 9: Performance check

**Files:** (none modified)

- [ ] **Step 1: Time a cold invocation**

Run: `time fish -i -c 'true' >/dev/null` (run 3 times, take the best)
Expected: real time under ~150ms cold. The start page itself adds <50ms; the rest is fish startup.

- [ ] **Step 2: Time `louis_greet` in isolation**

Run: `fish -c 'source terminals/fish/functions/louis_greet.fish; for i in (seq 5); time louis_greet >/dev/null; end' 2>&1 | grep real`
Expected: each invocation under 30ms after the first.

If either target is missed, profile with `fish --profile-startup`/`fish --profile` and revisit. Most likely offender is `tput` — if so, cache `$COLUMNS` from fish's built-in instead.

---

### Task 10: Final integration check

**Files:** (none modified)

- [ ] **Step 1: Open a brand-new terminal window**

Manually open a fresh Ghostty/WezTerm/Alacritty window. Confirm the start page renders correctly with:
- All six art rows in gradient
- Separator line + boot tag
- Three info rows (kernel, session, repo since cwd is `~/.dotfiles`)
- Random cyberpunk quote at the bottom

- [ ] **Step 2: Open a second tab / pane in the same terminal**

Confirm the page does NOT print again (because the second pane is still SHLVL=1, but if you launch a nested fish from inside, it should skip). For tmux specifically, each new pane is a fresh top-level shell so it WILL print — that's expected per the spec.

- [ ] **Step 3: Run `louis` manually**

In any directory, run `louis`. Confirm output matches expectations and that running it from outside `~/.dotfiles` hides the `repo` row.

---

## Self-Review Notes

- **Spec coverage:** Trigger (Task 8), layout (Tasks 1–6), gradient (Task 1), info panel rows (Tasks 3–5), quote pool (Task 6), performance (Task 9), file structure (Tasks 1, 7, 8) — all covered.
- **No placeholders:** every code block is complete and self-contained.
- **Type consistency:** helper names (`_louis_row`, `_louis_uptime`, `_louis_git_info`, `_louis_quote`) are consistent across tasks. Public function is `louis_greet` everywhere; user-facing command is `louis`.
- **No commit steps:** intentionally omitted per user instruction.
