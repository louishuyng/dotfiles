/**
 * Starship-style editor borders.
 *
 * Top border    ╭─ ❯ ~/.dotfiles ──────────────────── ⌥ main ✗21 ─╮
 * Bottom border ╰─ claude-opus · medium ──────── ctx 12%/200k ─────╯
 *
 * ❯ becomes a braille spinner while the agent is running.
 * Git state refreshes after each agent turn.
 *
 * Does NOT replace the pi-open-tui footer — it stays intact below.
 */
import os from "node:os";
import { CustomEditor, type ExtensionAPI, type ExtensionContext, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

// Identical to the border-status-editor example helper.
function fitBorder(
	left: string,
	right: string,
	width: number,
	border: (s: string) => string,
	fill: (s: string) => string = border,
): string {
	if (width <= 0) return "";
	if (width === 1) return border("─");
	let l = left;
	let r = right;
	const minGap = 3;
	while (2 + visibleWidth(l) + visibleWidth(r) + minGap > width && visibleWidth(r) > 0)
		r = truncateToWidth(r, Math.max(0, visibleWidth(r) - 1), "");
	while (2 + visibleWidth(l) + visibleWidth(r) + minGap > width && visibleWidth(l) > 0)
		l = truncateToWidth(l, Math.max(0, visibleWidth(l) - 1), "");
	const gap = Math.max(0, width - 2 - visibleWidth(l) - visibleWidth(r));
	return `${border("─")}${l}${fill("─".repeat(gap))}${r}${border("─")}`;
}

export default function starshipEditor(pi: ExtensionAPI) {
	let isWorking = false;
	let spinnerIdx = 0;
	let spinnerTimer: ReturnType<typeof setInterval> | undefined;
	let activeTui: TUI | undefined;

	const stopSpinner = () => {
		if (spinnerTimer) { clearInterval(spinnerTimer); spinnerTimer = undefined; }
	};

	pi.on("agent_start", () => {
		isWorking = true;
		stopSpinner();
		spinnerTimer = setInterval(() => {
			spinnerIdx = (spinnerIdx + 1) % SPINNER.length;
			activeTui?.requestRender();
		}, 80);
		activeTui?.requestRender();
	});

	pi.on("agent_settled", () => {
		isWorking = false;
		stopSpinner();
		activeTui?.requestRender();
	});

	pi.on("session_shutdown", () => {
		stopSpinner();
		activeTui = undefined;
	});

	pi.on("session_start", (_event, ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		const home = os.homedir();
		const cwd = ctx.cwd.startsWith(home) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;

		let branch = "";
		let dirty = 0;

		const refreshGit = async () => {
			const b = await pi
				.exec("git", ["-C", ctx.cwd, "symbolic-ref", "--short", "HEAD"], { timeout: 2000 })
				.catch(() => null);
			branch = b?.code === 0 ? b.stdout.trim() : "";
			if (branch) {
				const s = await pi
					.exec("git", ["-C", ctx.cwd, "status", "--porcelain", "--ignore-submodules=all"], { timeout: 2000 })
					.catch(() => null);
				dirty = s?.stdout.split("\n").filter(Boolean).length ?? 0;
			}
			activeTui?.requestRender();
		};
		void refreshGit();

		// Refresh git state after each turn so the dirty count stays current.
		pi.on("agent_settled", () => void refreshGit());

		class StarshipEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				// embedWorkingStatus keeps the spinner row inside the border.
				super(tui, theme, keybindings, { embedWorkingStatus: true });
				activeTui = tui;
			}

			render(width: number): string[] {
				const lines = super.render(width);
				if (lines.length < 2) return lines;

				const thm = ctx.ui.theme;
				const bc = (s: string) => this.borderColor(s);
				const fill = (s: string) => thm.fg("borderMuted", s);
				const accent = (s: string) => thm.fg("accent", s);
				const muted = (s: string) => thm.fg("muted", s);
				const success = (s: string) => thm.fg("success", s);
				const warn = (s: string) => thm.fg("warning", s);
				const dim = (s: string) => thm.fg("dim", s);

				// ── Top: prompt + cwd (left)  |  branch + dirty (right) ──────────
				const prompt = isWorking
					? accent(` ${SPINNER[spinnerIdx]} `)
					: accent(" ❯ ");
				const cwdSeg = muted(cwd);
				const branchSeg = branch
					? `${success(" ⌥ ")}${success(branch)}${dirty > 0 ? warn(` ✗${dirty}`) : success(" ✓")} `
					: "";

				// ── Bottom: model · level (left)  |  ctx usage (right) ──────────
				const modelId = ctx.model?.id ?? "no model";
				const level = pi.getThinkingLevel();
				const usage = ctx.getContextUsage();
				const ctxSeg = usage?.percent != null && usage.contextWindow
					? muted(` ctx ${Math.round(usage.percent)}%/${(usage.contextWindow / 1000).toFixed(0)}k `)
					: "";

				lines[0] = fitBorder(prompt + cwdSeg, branchSeg, width, bc, fill);
				lines[lines.length - 1] = fitBorder(
					muted(` ${modelId} `) + dim(`· ${level} `),
					ctxSeg,
					width, bc, fill,
				);
				return lines;
			}
		}

		ctx.ui.setEditorComponent((tui, theme, kb) => new StarshipEditor(tui, theme, kb));
	});
}
