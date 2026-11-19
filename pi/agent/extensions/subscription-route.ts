/**
 * jev/auto: Claude outside Omniyat, Grok inside it.
 * Jev picks Opus vs Sonnet on the Claude side. Omniyat stays on Grok.
 *
 * Custom footer shows the physical model beside "Auto (Jev)" on the same row.
 */
import { mkdirSync, writeFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

import type { Message } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, ModelRoute, ModelRouteRequest } from "@earendil-works/pi-coding-agent";

const SB_CACHE = join(homedir(), ".cache", "sketchybar");
const JEV_ROUTE_FILE = join(SB_CACHE, "jev_route");

function writeRoute(modelId: string): void {
	try {
		mkdirSync(SB_CACHE, { recursive: true });
		writeFileSync(JEV_ROUTE_FILE, modelId);
	} catch {}
}

const OMNIYAT = "/Users/louishuyng/LX14/repository/github.com/omniyat";
const OPUS = "claude-opus-5-5";
const SONNET = "claude-sonnet-4-6";
const GROK = "grok-4.7";

function underOmniyat(cwd: string): boolean {
	return cwd === OMNIYAT || cwd.startsWith(`${OMNIYAT}/`);
}

function lastUserText(messages: readonly Message[]): string {
	const content = messages.filter((m) => m.role === "user").at(-1)?.content ?? "";
	if (typeof content === "string") return content;
	return content.flatMap((b) => (b.type === "text" ? [b.text] : [])).join("\n");
}

function routeTo(request: ModelRouteRequest, ctx: ExtensionContext, provider: string, id: string): ModelRoute {
	const model = ctx.modelRegistry.find(provider, id);
	if (!model) throw new Error(`Model ${provider}/${id} is not in the catalog`);
	return { model, thinkingLevel: request.thinkingLevel };
}

async function claudeId(request: ModelRouteRequest, ctx: ExtensionContext): Promise<string> {
	const jev = ctx.modelRegistry.findOfType("classifier", "typesafe", "jev-latest");
	if (!jev) return OPUS;
	const result = await ctx.modelRegistry.classify(
		jev,
		{
			state: { prompt: lastUserText(request.messages).slice(0, 16_000) },
			questions: {
				complexity: {
					type: "choice",
					instructions: "How demanding is the software engineering work requested in `prompt`?",
					criteria: {
						standard: "Ordinary features, fixes, reviews, or questions",
						complex: "Subtle design, cross-cutting changes, or hard debugging",
					},
				},
			},
		},
		{ signal: request.signal },
	);
	const answer = result.stopReason === "stop" ? result.answers.complexity : undefined;
	return answer?.type === "choice" && (answer.probabilities.complex ?? 0) >= 0.5 ? OPUS : SONNET;
}

// Shared between route() and the footer render closure.
let routedModelId: string | undefined;
let footerRerender: (() => void) | undefined;

export default function (pi: ExtensionAPI) {
	pi.registerVirtualModel({
		provider: "jev",
		id: "auto",
		name: "Auto (Jev)",
		thinkingLevels: ["low", "medium", "high", "xhigh"],
		async route(request, ctx) {
			let result: ModelRoute;
			if (underOmniyat(ctx.cwd)) {
				result = routeTo(request, ctx, "xai", GROK);
			} else if (request.reason !== "user") {
				const sticky = request.failed ?? request.previous;
				if (sticky?.model.provider === "anthropic") {
					result = { model: sticky.model, thinkingLevel: sticky.thinkingLevel ?? request.thinkingLevel };
				} else {
					result = routeTo(request, ctx, "anthropic", await claudeId(request, ctx));
				}
			} else {
				result = routeTo(request, ctx, "anthropic", await claudeId(request, ctx));
			}
			if (request.reason === "user") {
				routedModelId = result.model.id;
				writeRoute(result.model.id);
				footerRerender?.();
			}
			return result;
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		routedModelId = undefined;

		if (ctx.mode === "tui") {
			ctx.ui.setFooter((tui, theme, footerData) => {
				footerRerender = () => tui.requestRender();
				const unsub = footerData.onBranchChange(() => tui.requestRender());

				return {
					dispose() {
						unsub();
						footerRerender = undefined;
					},
					invalidate() {},
					render(width: number): string[] {
						try {
							const vname = ctx.model?.name ?? ctx.model?.id ?? "jev/auto";
							const phys = routedModelId ? `  ${routedModelId}` : "";
							return [`${vname}${phys}`];
						} catch (err) {
							return [`footer-err: ${String(err)}`];
						}
					},
				};
			});
		}

		if (ctx.model?.provider === "jev" && ctx.model.id === "auto") return;
		const model = ctx.modelRegistry.find("jev", "auto");
		if (model) await pi.setModel(model);
	});
}
