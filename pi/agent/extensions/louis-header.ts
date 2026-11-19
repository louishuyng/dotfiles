/**
 * Startup header — boot sequence:
 *
 *   RAIN phase  (frames 0–49)   matrix rain; banner appears at frame 18 in a
 *                                 fixed cleared row with a pulse color cycle
 *   REVEAL phase (frames 50–85)  PI logo assembles line-by-line; info wipes in
 *   IDLE phase   (frames 86+)    logo + info fixed; rain keeps running around them
 */
import os from "node:os";
import path from "node:path";
import { VERSION, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// ── Timing ─────────────────────────────────────────────────────────────────

const FRAME_MS = 75;       // ≈13 fps — deliberately slow rain
const TOTAL_ROWS = 11;
const BANNER_START = 18;   // frame at which the banner appears
const RAIN_END = 50;       // last frame of pure-rain phase
const REVEAL_FRAMES = 36;  // frames to assemble logo + type info

// ── Logo ───────────────────────────────────────────────────────────────────

const LOGO = [
	"██████╗ ██╗",
	"██╔══██╗██║",
	"██████╔╝██║",
	"██╔═══╝ ██║",
	"██║     ██║",
	"╚═╝     ╚═╝",
];
const LOGO_W = 11;
// Phosphor-green gradient (bright mint → deep forest) matching louis_greet
const LOGO_GRAD = [48, 41, 35, 34, 28, 22];
const LOGO_ROW = 2;    // first header row the logo occupies
const LOGO_INDENT = 2;
const INFO_GAP = 3;
const INFO_INDENT = LOGO_INDENT + LOGO_W + INFO_GAP; // 16

// ── Rain pool & helpers ────────────────────────────────────────────────────

const RAIN_POOL = "ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ░▒▓01";

const QUOTES = [
	"The sky above the port was the color of television, tuned to a dead channel.  — Gibson",
	"Net is vast and infinite.  — Ghost in the Shell",
	"I never asked for this.  — Adam Jensen",
	"Wake up, Samurai. We have a city to burn.  — Cyberpunk 2077",
	"Information wants to be free.  — Brand",
	"The future is already here — it's just not very evenly distributed.  — Gibson",
	"All those moments will be lost in time, like tears in rain.  — Blade Runner",
];

const R = "\x1b[0m";
const c = (n: number, s: string, bold = false) => `\x1b[${bold ? "1;" : ""}38;5;${n}m${s}${R}`;
const dimS = (s: string) => `\x1b[2m${s}${R}`;
const italicDim = (s: string) => `\x1b[3;2m${s}${R}`;

function lcg(n: number): number { return (((n * 1664525 + 1013904223) | 0) >>> 0); }
function rainChar(seed: number): string { return RAIN_POOL[lcg(seed) % RAIN_POOL.length]!; }

type Repo = { name: string; branch: string; dirty: number } | null;

// ── Extension entry ────────────────────────────────────────────────────────

export default function louisHeader(pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | undefined;
	let requestRender: (() => void) | undefined;

	pi.on("session_start", (_event, ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		const home = os.homedir();
		const cwd = ctx.cwd.startsWith(home) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;
		const quote = QUOTES[Math.floor(Date.now() / 86_400_000) % QUOTES.length]!;

		const skills = pi.getCommands().filter((x) => x.source === "skill")
			.map((x) => x.name.replace(/^skill:/, ""));

		const extNames = [...new Set(
			[
				...pi.getCommands().filter((x) => x.source === "extension").map((x) => x.sourceInfo),
				...pi.getAllTools().map((x) => x.sourceInfo),
			]
				.filter((s) => s.source !== "builtin" && s.source !== "sdk")
				.map((s) =>
					s.origin === "package"
						? s.source.replace(/^npm:/, "").replace(/@[\d.]+$/, "")
						: path.basename(s.path).replace(/\.ts$/, ""),
				),
		)];

		let repo: Repo | "loading" = "loading";
		const git = (...args: string[]) => pi.exec("git", ["-C", ctx.cwd, ...args], { timeout: 3000 });
		git("rev-parse", "--show-toplevel").then(async (top) => {
			if (top.code !== 0) { repo = null; requestRender?.(); return; }
			let branch = (await git("symbolic-ref", "--short", "HEAD")).stdout.trim();
			if (!branch) branch = (await git("rev-parse", "--short", "HEAD")).stdout.trim();
			const dirty = (await git("status", "--porcelain", "--ignore-submodules=all"))
				.stdout.split("\n").filter(Boolean).length;
			repo = { name: path.basename(top.stdout.trim()), branch, dirty };
			requestRender?.();
		}).catch(() => { repo = null; requestRender?.(); });

		let frame = 0;

		ctx.ui.setHeader((tui) => {
			requestRender = () => tui.requestRender();
			if (timer) clearInterval(timer);
			timer = setInterval(() => { frame++; tui.requestRender(); }, FRAME_MS);
			timer.unref?.();

			return {
				render(width: number): string[] {
					return renderFrame(frame, width, { cwd, quote, skills, extNames, repo });
				},
				invalidate() {},
			};
		});
	});

	pi.on("session_shutdown", () => {
		if (timer) clearInterval(timer);
		timer = undefined;
		requestRender = undefined;
	});
}

// ── Rain cell builder ──────────────────────────────────────────────────────
// Returns an array[width] of single styled chars (or " ").

function buildRainCells(colPositions: number[], row: number, frame: number, width: number): string[] {
	const cells = Array<string>(width).fill(" ");
	for (let ci = 0; ci < colPositions.length; ci++) {
		const seed = lcg(ci * 73);
		const speed = 0.55 + (seed % 3) * 0.25;   // 0.55–1.05 — slow columns
		const offset = seed % (TOTAL_ROWS + 8);
		const head = Math.floor(frame * speed + offset) % (TOTAL_ROWS + 8) - 3;
		const dist = head - row;
		if (dist < 0 || dist > 8) continue;
		const ch = rainChar(ci * 1000 + row * 31 + frame);
		const jitter = (lcg(ci * 500 + row) % 3) - 1;
		const px = Math.max(0, Math.min(width - 1, colPositions[ci]! + jitter));
		if (dist === 0) cells[px] = c(255, ch);
		else if (dist === 1) cells[px] = c(48, ch);
		else if (dist <= 3) cells[px] = c(35, ch);
		else if (dist <= 5) cells[px] = c(28, ch);
		else cells[px] = c(238, ch);
	}
	return cells;
}

// Pure rain row — no overlay.
function rainRow(colPositions: number[], row: number, frame: number, width: number): string {
	return buildRainCells(colPositions, row, frame, width).join("");
}

// ── Banner pulse ───────────────────────────────────────────────────────────
// Cycles: white flash → bright green → medium green → dim green → repeat.

function bannerColor(frame: number): number {
	const t = (frame - BANNER_START) % 14;
	if (t < 2) return 255;
	if (t < 6) return 48;
	if (t < 10) return 41;
	return 35;
}

// ── Main renderer ──────────────────────────────────────────────────────────

interface Ctx {
	cwd: string;
	quote: string;
	skills: string[];
	extNames: string[];
	repo: Repo | "loading";
}

function renderFrame(frame: number, width: number, ctx: Ctx): string[] {
	const colCount = Math.min(20, Math.floor(width / 6));
	const colPositions = Array.from({ length: colCount }, (_, i) =>
		Math.floor((width * (i + 0.5)) / colCount),
	);

	return frame < RAIN_END
		? renderRainPhase(frame, width, colPositions)
		: renderRevealIdle(frame, width, colPositions, ctx);
}

// ── RAIN phase ─────────────────────────────────────────────────────────────

function renderRainPhase(frame: number, width: number, colPositions: number[]): string[] {
	const BANNER_MSG = "[ BOOT SEQUENCE INITIATED ]";
	const bannerX = Math.max(0, Math.floor((width - BANNER_MSG.length) / 2));
	const lines: string[] = [""];

	for (let row = 0; row < TOTAL_ROWS; row++) {
		if (frame >= BANNER_START && row === Math.floor(TOTAL_ROWS / 2)) {
			// Entire banner row is cleared — no rain — so text never jumps.
			const col = bannerColor(frame);
			const text = c(col, BANNER_MSG, true);
			const left = " ".repeat(bannerX);
			const right = " ".repeat(Math.max(0, width - bannerX - BANNER_MSG.length));
			lines.push(truncateToWidth(left + text + right, width, ""));
		} else {
			lines.push(rainRow(colPositions, row, frame, width));
		}
	}

	lines.push("");
	return lines;
}

// ── REVEAL + IDLE phase ────────────────────────────────────────────────────

function renderRevealIdle(frame: number, width: number, colPositions: number[], ctx: Ctx): string[] {
	const { cwd, quote, skills, extNames, repo } = ctx;
	const rf = frame - RAIN_END; // frames since rain ended

	// Logo: one line per 6 frames (all 6 lines in REVEAL_FRAMES/6 each).
	const framesPerLine = Math.floor(REVEAL_FRAMES / LOGO.length);
	const logoRevealed = Math.min(LOGO.length, Math.floor(rf / framesPerLine));

	// Info types in after 2 logo lines appear.
	const infoReveal = Math.min(1, Math.max(0, (rf - framesPerLine * 2) / (REVEAL_FRAMES - framesPerLine * 2)));

	// ── Info strings (fixed width, truncated to fit) ───────────────────────

	const repoStr =
		repo === "loading" ? dimS("loading…")
		: repo === null    ? dimS("—")
		: `${c(41, repo.name, true)}  ${dimS(repo.branch)}  ${repo.dirty > 0 ? c(214, `${repo.dirty} dirty`) : c(35, "clean")}`;

	const skillStr = skills.length === 0 ? dimS("none")
		: `${c(41, String(skills.length))}  ${skills.slice(0, 5).join("  ")}${skills.length > 5 ? dimS(`  +${skills.length - 5}`) : ""}`;

	const extStr = extNames.length === 0 ? dimS("none")
		: `${c(41, String(extNames.length))}  ${extNames.slice(0, 4).join("  ")}${extNames.length > 4 ? dimS(`  +${extNames.length - 4}`) : ""}`;

	// One info string per logo row (empty string = no overlay for that row).
	const INFO: string[] = [
		`${c(35, "pi", true)}      v${VERSION}   ${dimS(cwd)}`,
		`${c(35, "repo", true)}    ${repoStr}`,
		`${c(35, "skills", true)}  ${skillStr}`,
		`${c(35, "exts", true)}    ${extStr}`,
		"",
		"",
	];

	const lines: string[] = [""];

	for (let row = 0; row < TOTAL_ROWS; row++) {
		const logoIdx = row - LOGO_ROW; // which logo line (-1 if not a logo row)

		if (logoIdx >= 0 && logoIdx < LOGO.length) {
			lines.push(buildLogoRow(row, logoIdx, frame, rf, width, colPositions, logoRevealed, INFO[logoIdx] ?? "", infoReveal));
		} else if (row === LOGO_ROW + LOGO.length + 1) {
			// Quote row — use cell array so ANSI sequences stay intact.
			const quoteText = italicDim(`# ${quote}`);
			const qVis = Math.floor(visibleWidth(quoteText) * infoReveal);
			const shownQuote = infoReveal >= 1 ? quoteText : truncateToWidth(quoteText, qVis, "");
			const rainCells = buildRainCells(colPositions, row, frame, width);
			const leftRain = rainCells.slice(0, INFO_INDENT).join("");
			const rightRain = rainCells.slice(INFO_INDENT + visibleWidth(shownQuote) + 1).join("");
			lines.push(truncateToWidth(leftRain + shownQuote + " " + rightRain, width, ""));
		} else {
			lines.push(rainRow(colPositions, row, frame, width));
		}
	}

	lines.push("");
	return lines.map((l) => truncateToWidth(l, width, ""));
}

// Build one row that contains: left-margin rain | logo char | gap rain | info text | right rain
function buildLogoRow(
	row: number,
	logoIdx: number,
	frame: number,
	rf: number,         // frames since rain phase ended
	width: number,
	colPositions: number[],
	logoRevealed: number,
	infoText: string,
	infoReveal: number,
): string {
	const rainCells = buildRainCells(colPositions, row, frame, width);

	// Left margin rain (positions 0..LOGO_INDENT-1)
	const leftRain = rainCells.slice(0, LOGO_INDENT).join("");

	// Logo portion
	const logoEnd = LOGO_INDENT + LOGO_W;
	let logoPart: string;
	if (logoIdx < logoRevealed) {
		const col = LOGO_GRAD[logoIdx]!;
		const logoStr = LOGO[logoIdx]!;
		// Flash the newly revealed line white for the first 3 render frames.
		const framesPerLine = Math.floor(REVEAL_FRAMES / LOGO.length);
		const lineAge = rf - logoIdx * framesPerLine;
		const isFlash = lineAge < 3;
		logoPart = isFlash
			? c(255, logoStr)
			: c(col, logoStr.replace(/(█+)/g, `\x1b[39m$1\x1b[38;5;${col}m`));
	} else if (logoIdx === logoRevealed) {
		// Next-to-appear line: show dim static noise
		logoPart = Array.from({ length: LOGO_W }, (_, i) =>
			c(238, rainChar(frame * 7 + logoIdx * 11 + i)),
		).join("");
	} else {
		logoPart = " ".repeat(LOGO_W);
	}

	// Gap rain (positions logoEnd..INFO_INDENT-1)
	const midRain = rainCells.slice(logoEnd, INFO_INDENT).join("");

	// Info text (typed in)
	const infoMaxW = width - INFO_INDENT - 2;
	let shownInfo = "";
	if (infoText && infoReveal > 0) {
		const totalVis = visibleWidth(infoText);
		const show = infoReveal >= 1 ? totalVis : Math.floor(totalVis * infoReveal);
		shownInfo = truncateToWidth(infoText, Math.min(show, infoMaxW), "");
	}
	const infoVis = visibleWidth(shownInfo);

	// Right rain starts right after the shown info text, not at the max-width boundary.
	const rightStart = Math.min(width, INFO_INDENT + infoVis + 1);
	const rightRain = rainCells.slice(rightStart).join("");

	const pad = " "; // space between info text and right rain
	return truncateToWidth(leftRain + logoPart + midRain + shownInfo + pad + rightRain, width, "");
}
