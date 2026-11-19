/**
 * Single-line starship-style prompt on the bottom editor border.
 *
 * Top    ─────────────────────────────────────────────── (dim rule, no labels)
 * Bottom  ❯ ~/.dotfiles  ⌥ main ✗23  ·  claude  ·  ctx 12%
 *
 * ❯ → braille spinner while the agent runs.
 * Git refreshes after every turn.
 */
import os from "node:os";
import { CustomEditor, type ExtensionAPI, type ExtensionContext, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth } from "@earendil-works/pi-tui";

const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

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

	pi.on("agent_settled", () => { isWorking = false; stopSpinner(); activeTui?.requestRender(); });
	pi.on("session_shutdown", () => { stopSpinner(); activeTui = undefined; });

	pi.on("session_start", (_event, ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		const home = os.homedir();
		const cwd = ctx.cwd.startsWith(home) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;

		let branch = "";
		let dirty = 0;

		const refreshGit = async () => {
			const b = await pi.exec("git", ["-C", ctx.cwd, "symbolic-ref", "--short", "HEAD"], { timeout: 2000 }).catch(() => null);
			branch = b?.code === 0 ? b.stdout.trim() : "";
			if (branch) {
				const s = await pi.exec("git", ["-C", ctx.cwd, "status", "--porcelain", "--ignore-submodules=all"], { timeout: 2000 }).catch(() => null);
				dirty = s?.stdout.split("\n").filter(Boolean).length ?? 0;
			}
			activeTui?.requestRender();
		};
		void refreshGit();
		pi.on("agent_settled", () => void refreshGit());

		class StarshipEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				super(tui, theme, keybindings, { embedWorkingStatus: true });
				activeTui = tui;
			}

			render(width: number): string[] {
				const lines = super.render(width);
				if (lines.length < 2) return lines;

				const thm = ctx.ui.theme;
				const bc  = (s: string) => this.borderColor(s);
				const acc = (s: string) => thm.fg("accent", s);
				const mut = (s: string) => thm.fg("muted", s);
				const ok  = (s: string) => thm.fg("success", s);
				const wrn = (s: string) => thm.fg("warning", s);
				const d   = (s: string) => thm.fg("dim", s);
				const sep = d(" · ");

				// Top: plain dim rule, no labels
				lines[0] = bc("─".repeat(width));

				// Bottom: single info line  ❯ cwd · branch · model · ctx
				const prompt   = isWorking ? acc(` ${SPINNER[spinnerIdx]} `) : acc(" ❯ ");
				const cwdSeg   = mut(cwd);
				const branchSeg = branch
					? sep + ok("⌥ ") + ok(branch) + (dirty > 0 ? wrn(` ✗${dirty}`) : ok(" ✓"))
					: "";
				const modelId  = ctx.model?.id ?? "";
				const level    = pi.getThinkingLevel();
				const modelSeg = modelId ? sep + mut(modelId) + d(` · ${level}`) : "";
				const usage    = ctx.getContextUsage();
				const ctxSeg   = usage?.percent != null && usage.contextWindow
					? sep + d(`ctx ${Math.round(usage.percent)}%`)
					: "";

				lines[lines.length - 1] = truncateToWidth(
					prompt + cwdSeg + branchSeg + modelSeg + ctxSeg,
					width, "",
				);
				return lines;
			}
		}

		ctx.ui.setEditorComponent((tui, theme, kb) => new StarshipEditor(tui, theme, kb));
	});
}
