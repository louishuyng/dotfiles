/**
 * Startup header: matrix rain runs continuously.
 * After RAIN_END frames the info panel wipes in on top of the rain.
 * Rain keeps animating behind and beside the info text.
 */
import os from "node:os";
import path from "node:path";
import { VERSION, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const RAIN_END = 30;       // frames of pure rain before info appears
const REVEAL_FRAMES = 22;  // frames for info wipe-in
const FRAME_MS = 50;       // ~20 fps
const TOTAL_ROWS = 10;     // header height in rows

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

// ── ANSI helpers ───────────────────────────────────────────────────────────

const R = "\x1b[0m";
const c = (n: number, s: string, bold = false) => `\x1b[${bold ? "1;" : ""}38;5;${n}m${s}${R}`;
const dimS = (s: string) => `\x1b[2m${s}${R}`;
const italicDim = (s: string) => `\x1b[3;2m${s}${R}`;

// ── LCG pseudo-random ──────────────────────────────────────────────────────

function lcg(n: number): number {
	return (((n * 1664525 + 1013904223) | 0) >>> 0);
}
function rainChar(seed: number): string {
	return RAIN_POOL[lcg(seed) % RAIN_POOL.length]!;
}

// ── Types ──────────────────────────────────────────────────────────────────

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

		const skills = pi
			.getCommands()
			.filter((x) => x.source === "skill")
			.map((x) => x.name.replace(/^skill:/, ""));

		const extNames = [
			...new Set(
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
			),
		];

		let repo: Repo | "loading" = "loading";
		const git = (...args: string[]) => pi.exec("git", ["-C", ctx.cwd, ...args], { timeout: 3000 });
		git("rev-parse", "--show-toplevel")
			.then(async (top) => {
				if (top.code !== 0) { repo = null; requestRender?.(); return; }
				let branch = (await git("symbolic-ref", "--short", "HEAD")).stdout.trim();
				if (!branch) branch = (await git("rev-parse", "--short", "HEAD")).stdout.trim();
				const dirty = (await git("status", "--porcelain", "--ignore-submodules=all"))
					.stdout.split("\n").filter(Boolean).length;
				repo = { name: path.basename(top.stdout.trim()), branch, dirty };
				requestRender?.();
			})
			.catch(() => { repo = null; requestRender?.(); });

		let frame = 0;

		ctx.ui.setHeader((tui) => {
			requestRender = () => tui.requestRender();

			if (timer) clearInterval(timer);
			timer = setInterval(() => {
				frame++;
				tui.requestRender();
			}, FRAME_MS);
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

// ── Frame renderer ─────────────────────────────────────────────────────────

interface Ctx {
	cwd: string;
	quote: string;
	skills: string[];
	extNames: string[];
	repo: Repo | "loading";
}

// Pre-compute which ANSI-coloured rain char appears at (col, row) for a given frame.
// Returns null when no raindrop occupies that cell.
function getRainAt(col: number, row: number, frame: number, rows: number): string | null {
	const seed = lcg(col * 73);
	const speed = 1.0 + (seed % 3) * 0.5;
	const offset = seed % (rows + 8);
	const head = Math.floor(frame * speed + offset) % (rows + 8) - 3;
	const dist = head - row;
	if (dist < 0 || dist > 8) return null;
	const ch = rainChar(col * 1000 + row * 31 + frame);
	if (dist === 0) return c(255, ch);
	if (dist === 1) return c(48, ch);
	if (dist <= 3) return c(35, ch);
	if (dist <= 5) return c(28, ch);
	return c(238, ch);
}

// Build a full rain row (width cells) with no overlay.
function rainRow(colPositions: number[], row: number, frame: number, width: number): string {
	const cells = Array<string>(width).fill(" ");
	for (let ci = 0; ci < colPositions.length; ci++) {
		const ch = getRainAt(ci, row, frame, TOTAL_ROWS);
		if (!ch) continue;
		const x = colPositions[ci]!;
		// Slight jitter (±1) using seeded value so it's stable per cell.
		const jitter = (lcg(ci * 500 + row) % 3) - 1;
		const px = Math.max(0, Math.min(width - 1, x + jitter));
		cells[px] = ch;
	}
	return cells.join("");
}

// Build a row that has rain on the wings and an info string spliced in the middle.
// revealFrac (0–1) controls how much of the info string is visible (left-to-right wipe).
function infoRow(
	colPositions: number[],
	row: number,
	frame: number,
	width: number,
	text: string,
	revealFrac: number,
	indent = 2,
): string {
	const fullText = text;
	const fullVis = visibleWidth(fullText);

	// How many visible characters of the text to show.
	const showChars = Math.min(fullVis, Math.floor(fullVis * revealFrac));

	// Truncate styled string to showChars visible characters.
	const shownText = revealFrac >= 1 ? fullText : truncateToWidth(fullText, showChars, "");

	const textVis = visibleWidth(shownText);
	const clearFrom = indent;
	const clearTo = Math.min(width, indent + fullVis + 2); // +2 for trailing space buffer

	// Build rain cells for the full row first.
	const cells = Array<string>(width).fill(" ");
	for (let ci = 0; ci < colPositions.length; ci++) {
		const ch = getRainAt(ci, row, frame, TOTAL_ROWS);
		if (!ch) continue;
		const x = colPositions[ci]!;
		const jitter = (lcg(ci * 500 + row) % 3) - 1;
		const px = Math.max(0, Math.min(width - 1, x + jitter));
		cells[px] = ch;
	}

	// Clear the info region (replace with spaces so the text is readable).
	for (let x = clearFrom; x < clearTo && x < width; x++) {
		cells[x] = " ";
	}

	// Build final row: rain-left + info text + rain-right
	// We can't splice ANSI strings into a cell array, so we build it as:
	//   leftRain (plain cells 0..indent-1) + shownText + rightRain (cells clearTo..end)
	const leftPart = cells.slice(0, indent).join("");
	const rightPart = cells.slice(clearFrom + textVis + 1).join("");
	const pad = " "; // one space between rain edge and text
	return truncateToWidth(leftPart + pad + shownText + pad + rightPart, width, "");
}

function renderFrame(frame: number, width: number, ctx: Ctx): string[] {
	const { cwd, quote, skills, extNames, repo } = ctx;

	// Distribute rain columns evenly across width.
	const colCount = Math.min(20, Math.floor(width / 6));
	const colPositions: number[] = Array.from({ length: colCount }, (_, i) =>
		Math.floor((width * (i + 0.5)) / colCount),
	);

	// Reveal progress (0 = pure rain, 1 = fully shown info).
	const revealRaw = frame < RAIN_END ? 0 : (frame - RAIN_END) / REVEAL_FRAMES;
	const reveal = Math.min(1, revealRaw * revealRaw); // ease-in

	// Mid-rain banner (only during pure rain phase).
	const showBanner = frame >= Math.floor(RAIN_END * 0.4) && reveal === 0;

	// ── Info strings ───────────────────────────────────────────────────────

	const repoStr =
		repo === "loading" ? dimS("loading…")
		: repo === null    ? dimS("—")
		: `${c(41, repo.name, true)}  ${dimS(repo.branch)}  ${repo.dirty > 0 ? c(214, `${repo.dirty} dirty`) : c(35, "clean")}`;

	const skillStr =
		skills.length === 0 ? dimS("none")
		: `${c(41, String(skills.length))}  ${skills.slice(0, 5).join("  ")}${skills.length > 5 ? dimS(`  +${skills.length - 5}`) : ""}`;

	const extStr =
		extNames.length === 0 ? dimS("none")
		: `${c(41, String(extNames.length))}  ${extNames.slice(0, 4).join("  ")}${extNames.length > 4 ? dimS(`  +${extNames.length - 4}`) : ""}`;

	// Info rows and which grid row they occupy.
	// Rows: 0=empty, 1=empty, 2=pi, 3=repo, 4=skills, 5=exts, 6=empty, 7=quote, 8=empty, 9=empty
	const overlays: { row: number; text: string }[] = [
		{ row: 2, text: `${c(35, "pi", true)}      v${VERSION}   ${dimS(cwd)}` },
		{ row: 3, text: `${c(35, "repo", true)}    ${repoStr}` },
		{ row: 4, text: `${c(35, "skills", true)}  ${skillStr}` },
		{ row: 5, text: `${c(35, "exts", true)}    ${extStr}` },
		{ row: 7, text: italicDim(`# ${quote}`) },
	];

	// ── Render rows ────────────────────────────────────────────────────────

	const lines: string[] = [""];

	for (let row = 0; row < TOTAL_ROWS; row++) {
		if (showBanner && row === Math.floor(TOTAL_ROWS / 2)) {
			const msg = "[ BOOT SEQUENCE INITIATED ]";
			const mx = Math.max(0, Math.floor((width - msg.length) / 2));
			// Build rain row then overwrite the banner region.
			const base = rainRow(colPositions, row, frame, width).split("");
			const banner = c(48, msg, true);
			// Splice: left rain + spaces + banner + spaces + right rain
			const clear = " ".repeat(msg.length);
			const left = base.slice(0, mx).join("");
			const right = base.slice(mx + msg.length).join("");
			lines.push(truncateToWidth(left + clear.slice(0, 1) + banner + clear.slice(0, 1) + right, width, ""));
			continue;
		}

		const overlay = overlays.find((o) => o.row === row);
		if (overlay && reveal > 0) {
			lines.push(infoRow(colPositions, row, frame, width, overlay.text, reveal));
		} else {
			lines.push(rainRow(colPositions, row, frame, width));
		}
	}

	lines.push("");
	return lines;
}
