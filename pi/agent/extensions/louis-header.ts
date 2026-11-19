/**
 * Animated startup header styled after the Fish louis_greet page.
 *
 * Boot sequence:
 *   phase 0 – RAIN    (frames 0–28)   : matrix katakana rain across full width
 *   phase 1 – ASSEMBLE (frames 29–55) : PI logo drops in line by line
 *   phase 2 – TYPE    (frames 56–90)  : info panel types in
 *   phase 3 – IDLE    (frames 91+)    : scanline sweep + glitch flicker
 */
import os from "node:os";
import path from "node:path";
import { VERSION, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

// ── Constants ──────────────────────────────────────────────────────────────

const RAIN_END = 29;
const ASSEMBLE_END = 56;
const TYPE_END = 92;
const FRAME_MS = 55; // ~18 fps
const SCAN_PERIOD = 90; // idle frames between scanline sweeps

// Phosphor greens matching louis_greet (bright mint → deep forest)
const GRAD = [48, 41, 35, 34, 28, 22];

// Halfwidth katakana + block chars for rain
const RAIN_POOL = "ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ░▒▓01";

const LOGO_LINES = [
	"██████╗ ██╗",
	"██╔══██╗██║",
	"██████╔╝██║",
	"██╔═══╝ ██║",
	"██║     ██║",
	"╚═╝     ╚═╝",
];
const LOGO_W = 11;

const QUOTES = [
	"The sky above the port was the color of television, tuned to a dead channel.  — Gibson",
	"Net is vast and infinite.  — Ghost in the Shell",
	"I never asked for this.  — Adam Jensen",
	"Wake up, Samurai. We have a city to burn.  — Cyberpunk 2077",
	"Information wants to be free.  — Brand",
	"The future is already here — it's just not very evenly distributed.  — Gibson",
	"All those moments will be lost in time, like tears in rain.  — Blade Runner",
];

// ── Helpers ────────────────────────────────────────────────────────────────

const R = "\x1b[0m";
const cfgi = (n: number, s: string, bold = false) => `\x1b[${bold ? "1;" : ""}38;5;${n}m${s}${R}`;
const dimS = (s: string) => `\x1b[2m${s}${R}`;
const italicS = (s: string) => `\x1b[3m${s}${R}`;
const invertS = (s: string) => `\x1b[7m${s}\x1b[27m`;

// Seedable LCG for deterministic "random" per-cell chars
function lcg(n: number): number {
	return (((n * 1664525 + 1013904223) | 0) >>> 0);
}
function seededChar(seed: number): string {
	return RAIN_POOL[lcg(seed) % RAIN_POOL.length]!;
}

// Strip ANSI sequences to measure visible length
function visLen(s: string): number {
	return s.replace(/\x1b\[[^m]*m/g, "").length;
}

// ── Types ──────────────────────────────────────────────────────────────────

type Repo = { name: string; branch: string; dirty: number } | null;

// ── Main extension ─────────────────────────────────────────────────────────

export default function louisHeader(pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | undefined;
	let requestRender: (() => void) | undefined;

	pi.on("session_start", (_event, ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;
		installHeader(pi, ctx);
	});

	pi.on("session_shutdown", () => {
		if (timer) clearInterval(timer);
		timer = undefined;
		requestRender = undefined;
	});

	function installHeader(pi: ExtensionAPI, ctx: ExtensionContext) {
		const home = os.homedir();
		const host = os.hostname().split(".")[0] ?? "Mac";
		const cwd = ctx.cwd.startsWith(home) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;
		const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "no model";
		const effort = pi.getThinkingLevel();
		// Pick a quote once per session (day-seeded so it feels fresh on restart)
		const quote = QUOTES[Math.floor(Date.now() / 86_400_000) % QUOTES.length]!;

		const skills = pi
			.getCommands()
			.filter((c) => c.source === "skill")
			.map((c) => c.name.replace(/^skill:/, ""));

		const extNames = [
			...new Set(
				[
					...pi.getCommands().filter((c) => c.source === "extension").map((c) => c.sourceInfo),
					...pi.getAllTools().map((t) => t.sourceInfo),
				]
					.filter((s) => s.source !== "builtin" && s.source !== "sdk")
					.map((s) =>
						s.origin === "package"
							? s.source.replace(/^npm:/, "").replace(/@[\d.]+$/, "")
							: path.basename(s.path).replace(/\.ts$/, ""),
					),
			),
		];

		let repo: Repo | "loading" = "loading";

		// Load git state in the background; re-render when done.
		const git = (...args: string[]) => pi.exec("git", ["-C", ctx.cwd, ...args], { timeout: 3000 });
		git("rev-parse", "--show-toplevel")
			.then(async (top) => {
				if (top.code !== 0) {
					repo = null;
					requestRender?.();
					return;
				}
				let branch = (await git("symbolic-ref", "--short", "HEAD")).stdout.trim();
				if (!branch) branch = (await git("rev-parse", "--short", "HEAD")).stdout.trim();
				const dirty = (await git("status", "--porcelain", "--ignore-submodules=all")).stdout
					.split("\n")
					.filter(Boolean).length;
				repo = { name: path.basename(top.stdout.trim()), branch, dirty };
				requestRender?.();
			})
			.catch(() => {
				repo = null;
				requestRender?.();
			});

		let frame = 0;

		ctx.ui.setHeader((tui) => {
			requestRender = () => tui.requestRender();

			if (timer) clearInterval(timer);
			timer = setInterval(() => {
				// Stop advancing after the animation settles; keep going for idle effects.
				frame = Math.min(frame + 1, TYPE_END + 400);
				tui.requestRender();
			}, FRAME_MS);
			timer.unref?.();

			return {
				render(width: number): string[] {
					// ── RAIN PHASE ─────────────────────────────────────────────
					if (frame < RAIN_END) {
						return renderRain(frame, width);
					}

					// ── ASSEMBLE + TYPE + IDLE ──────────────────────────────────
					return renderMain(frame, width, {
						host,
						cwd,
						model,
						effort,
						quote,
						skills,
						extNames,
						repo,
					});
				},
				invalidate() {},
			};
		});
	}
}

// ── Rain phase renderer ────────────────────────────────────────────────────

function renderRain(frame: number, width: number): string[] {
	const ROWS = 11;
	// Number of rain columns proportional to width, capped at 16.
	const colCount = Math.min(16, Math.floor(width / 8));

	// Build an empty cell grid.
	const grid: string[][] = Array.from({ length: ROWS }, () => Array(width).fill(" "));

	function set(r: number, c: number, s: string) {
		if (r >= 0 && r < ROWS && c >= 0 && c < width) grid[r]![c] = s;
	}

	for (let col = 0; col < colCount; col++) {
		const seed = lcg(col * 73);
		const colX = Math.floor((width * (col + 0.5)) / colCount);
		// Each column has a head that falls at slightly different speeds.
		const speed = 1 + (seed % 3) * 0.4;
		const offset = (seed % (ROWS + 6));
		const head = Math.floor((frame * speed + offset) % (ROWS + 6)) - 3;

		for (let row = 0; row < ROWS; row++) {
			const dist = head - row;
			if (dist < 0 || dist > 8) continue;
			const ch = seededChar(col * 1000 + row * 31 + frame);
			const x = colX + (lcg(col * 500 + row) % 3) - 1;
			if (dist === 0) set(row, x, cfgi(255, ch));
			else if (dist === 1) set(row, x, cfgi(48, ch));
			else if (dist <= 3) set(row, x, cfgi(35, ch));
			else if (dist <= 5) set(row, x, cfgi(28, ch));
			else set(row, x, cfgi(238, ch));
		}
	}

	// Mid-rain banner after ~40% through the phase.
	if (frame > Math.floor(RAIN_END * 0.4)) {
		const msg = "[ BOOT SEQUENCE INITIATED ]";
		const mx = Math.max(0, Math.floor((width - msg.length) / 2));
		const msgRow = Math.floor(ROWS / 2);
		for (let i = 0; i < msg.length && mx + i < width; i++) {
			grid[msgRow]![mx + i] = cfgi(48, msg[i]!, true);
		}
	}

	const lines = [""];
	for (const row of grid) lines.push(row.join(""));
	lines.push("");
	return lines.map((l) => truncateToWidth(l, width, ""));
}

// ── Main phase renderer ────────────────────────────────────────────────────

interface MainCtx {
	host: string;
	cwd: string;
	model: string;
	effort: string;
	quote: string;
	skills: string[];
	extNames: string[];
	repo: Repo | "loading";
}

function renderMain(frame: number, width: number, mc: MainCtx): string[] {
	const { host, cwd, model, effort, quote, skills, extNames, repo } = mc;
	const user = os.userInfo().username;

	// How many logo lines to show (assemble phase: drops in one per 4 frames).
	const logoRevealed =
		frame < ASSEMBLE_END
			? Math.min(LOGO_LINES.length, Math.floor((frame - RAIN_END) / 4))
			: LOGO_LINES.length;

	// Build info lines (right panel).
	const repoStr =
		repo === "loading"
			? dimS("loading…")
			: repo === null
				? dimS("—")
				: `${cfgi(41, repo.name)} ${dimS("·")} ${repo.branch} ${dimS("·")} ${repo.dirty > 0 ? cfgi(214, `${repo.dirty} dirty`) : cfgi(35, "clean")}`;

	const skillStr =
		skills.length > 0
			? `${cfgi(41, String(skills.length))} ${dimS("·")} ${skills.slice(0, 4).join("  ")}${skills.length > 4 ? dimS(` +${skills.length - 4}`) : ""}`
			: dimS("none");

	const extStr =
		extNames.length > 0
			? `${cfgi(41, String(extNames.length))} ${dimS("·")} ${extNames.slice(0, 3).join("  ")}${extNames.length > 3 ? dimS(` +${extNames.length - 3}`) : ""}`
			: dimS("none");

	const RIGHT: string[] = [
		`${cfgi(29, user, true)} ${dimS("/")} ${cfgi(35, `@${host}`, true)}`,
		`${cfgi(41, `v${VERSION}`, true)} ${dimS("·")} ${model} ${dimS("·")} ${effort}`,
		dimS(cwd),
		"",
		`${dimS("repo  ")} ${repoStr}`,
		`${dimS("skills")} ${skillStr}`,
		`${dimS("exts  ")} ${extStr}`,
		"",
		italicS(dimS(`# ${quote}`)),
	];

	// Typing progress: map frame to total chars revealed in the right panel.
	const totalChars = RIGHT.map((l) => visLen(l)).reduce((a, b) => a + b, 0);
	const charsVisible =
		frame < TYPE_END
			? Math.floor(((frame - ASSEMBLE_END) / (TYPE_END - ASSEMBLE_END)) * totalChars * 1.1)
			: 999999;

	// Build typed right panel strings.
	const typedRight: string[] = [];
	let seen = 0;
	const cursorChar = frame % 10 < 5 ? cfgi(48, "▍") : " ";
	let cursorPlaced = false;
	for (const raw of RIGHT) {
		const visible = visLen(raw);
		if (seen >= charsVisible) {
			typedRight.push("");
		} else if (seen + visible <= charsVisible) {
			typedRight.push(raw);
			seen += visible;
		} else {
			// Partial line — strip ANSI and slice to char count.
			const take = charsVisible - seen;
			const stripped = raw.replace(/\x1b\[[^m]*m/g, "");
			const partial = stripped.slice(0, take);
			typedRight.push(frame < TYPE_END && !cursorPlaced ? partial + cursorChar : partial);
			cursorPlaced = true;
			seen = charsVisible;
		}
	}
	while (typedRight.length < RIGHT.length) typedRight.push("");

	// Idle scanline: a bright inverted row that sweeps down every SCAN_PERIOD frames.
	const idleFrame = Math.max(0, frame - TYPE_END);
	const scanPos =
		frame >= TYPE_END
			? Math.floor((idleFrame % SCAN_PERIOD) / SCAN_PERIOD * (LOGO_LINES.length + RIGHT.length + 2))
			: -1;

	// Idle glitch: occasionally replace a char in the last logo line.
	const glitchActive = frame >= TYPE_END && idleFrame % 23 < 2;
	const glitchRow = LOGO_LINES.length - 1;

	// ── Layout ──────────────────────────────────────────────────────────────
	const logoColWidth = LOGO_W + 2; // 2 spaces indent
	const sepWidth = 3; // "  │" separator
	const minRightWidth = 20;
	const twoCols = width >= logoColWidth + sepWidth + minRightWidth;

	const lines: string[] = [""];

	const totalRows = Math.max(LOGO_LINES.length, typedRight.length);

	for (let r = 0; r < totalRows; r++) {
		const isScanned = r === scanPos;

		// Logo column
		let logoPart = "";
		if (r < LOGO_LINES.length) {
			if (r < logoRevealed) {
				const logoStr = LOGO_LINES[r]!;
				const gradColor = GRAD[r] ?? 35;
				// Flash the newly revealed line white during assemble.
				const isNewLine = frame < ASSEMBLE_END && r === logoRevealed - 1;
				const isGlitch = glitchActive && r === glitchRow;
				const colored = isGlitch
					? cfgi(197, logoStr) // red glitch flash
					: isNewLine
						? cfgi(255, logoStr) // white flash on reveal
						: cfgi(gradColor, logoStr.replace(/(█+)/g, `\x1b[39m$1\x1b[38;5;${gradColor}m`));
				logoPart = `  ${colored}`;
			} else {
				// Not yet revealed: show scanline noise during assemble.
				if (frame < ASSEMBLE_END && r === logoRevealed) {
					const noise = Array.from({ length: LOGO_W }, (_, i) => cfgi(238, seededChar(frame * 7 + i))).join("");
					logoPart = `  ${noise}`;
				} else {
					logoPart = "";
				}
			}
		}

		const paddedLogo = logoPart + " ".repeat(Math.max(0, logoColWidth - visLen(logoPart)));

		if (twoCols) {
			const rightPart = typedRight[r] ?? "";
			const sep = dimS("│");
			const lineStr = `${paddedLogo} ${sep} ${rightPart}`;
			lines.push(isScanned ? invertS(truncateToWidth(lineStr, width, "")) : lineStr);
		} else {
			if (logoPart) lines.push(logoPart);
			const rightPart = typedRight[r] ?? "";
			if (rightPart) lines.push(`  ${rightPart}`);
		}
	}

	lines.push("");
	return lines.map((l) => truncateToWidth(l, width, "…"));
}
