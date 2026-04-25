import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type TuiLike = {
	requestRender(force?: boolean): void;
	terminal?: {
		write?(data: string): void;
	};
};

type TuiRenderState = TuiLike & {
	previousLines?: string[];
	previousWidth?: number;
	previousHeight?: number;
	cursorRow?: number;
	hardwareCursorRow?: number;
	maxLinesRendered?: number;
	previousViewportTop?: number;
};

let currentTui: TuiLike | undefined;

function writeTerminal(data: string): void {
	if (currentTui?.terminal?.write) {
		currentTui.terminal.write(data);
		return;
	}

	process.stdout.write(data);
}

function resetTuiRenderState(tui: TuiLike): void {
	// pi-tui's public `requestRender(true)` clears the scrollback too. For Ctrl-L,
	// keep scrollback and make the next render behave like a fresh first render.
	const state = tui as TuiRenderState;
	state.previousLines = [];
	state.previousWidth = 0;
	state.previousHeight = 0;
	state.cursorRow = 0;
	state.hardwareCursorRow = 0;
	state.maxLinesRendered = 0;
	state.previousViewportTop = 0;
}

function clearTerminal(): void {
	// Clear only the visible viewport and move to the top-left. Do not send ESC[3J,
	// which clears terminal scrollback and makes the TUI feel jarring.
	writeTerminal("\x1b[?2026h\x1b[2J\x1b[H\x1b[?2026l");

	if (!currentTui) {
		return;
	}

	resetTuiRenderState(currentTui);
	currentTui.requestRender();
}

export default function clearScreenShortcut(pi: ExtensionAPI): void {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setWidget("clear-screen-tui-capture", (tui) => {
			currentTui = tui;

			return {
				render: () => [],
				invalidate: () => {},
				dispose: () => {
					if (currentTui === tui) {
						currentTui = undefined;
					}
				},
			};
		});
	});

	pi.registerShortcut("ctrl+l", {
		description: "Clear terminal screen",
		handler: async () => {
			clearTerminal();
		},
	});

	pi.registerCommand("clear-screen", {
		description: "Clear terminal screen",
		handler: async () => {
			clearTerminal();
		},
	});
}
