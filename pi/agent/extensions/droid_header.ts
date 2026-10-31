// Adapted from sting8k/pi-droid-styling at 4f97848; see droid_header.LICENSE.
// https://github.com/sting8k/pi-droid-styling/blob/4f97848/startup-ui.ts
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { keyHint, rawKeyHint, VERSION } from "@earendil-works/pi-coding-agent";
import {
  mixColors,
  rgbColor,
  truncateToWidth,
  visibleWidth,
} from "@earendil-works/pi-tui";

const logo = [
  "████████████╗",
  "████████████║",
  "████╔═══████║",
  "████║   ████║",
  "████████╬═══████╗",
  "████████║   ████║",
  "████╔═══╝   ████║",
  "████║       ████║",
  "╚═══╝       ╚═══╝",
];
const logo_width = Math.max(...logo.map(visibleWidth));

function gradient_logo(theme: Theme): string[] {
  const palette = Array.from({ length: 24 }, (_, index) => {
    const wave = -Math.cos((index / 24) * Math.PI * 2);
    const shade = wave < 0 ? rgbColor(0, 0, 0) : rgbColor(255, 255, 255);
    return mixColors(theme.colors.accent, shade, Math.abs(wave) * 0.18, "srgb");
  });
  return logo.map((line, row) =>
    [...line]
      .map((char, column) => {
        if (char === " ") return char;
        const position =
          ((column / Math.max(line.length - 1, 1) + row * 0.12) % 1) *
          palette.length;
        const index = Math.floor(position);
        const color = mixColors(
          palette[index],
          palette[(index + 1) % palette.length],
          position - index,
          "srgb",
        );
        return theme.style(char, { fg: color });
      })
      .join(""),
  );
}

export default function droid_header(pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setHeader(() => {
      let cache_key: string | undefined;
      let styled_logo: string[] = [];
      return {
        invalidate() {
          cache_key = undefined;
        },
        render(width: number): string[] {
          if (width <= 0) return [];
          const theme = ctx.ui.theme;
          const key = `${theme.getColorMode()}:${theme.getFgAnsi("accent")}`;
          if (key !== cache_key) {
            styled_logo = gradient_logo(theme);
            cache_key = key;
          }
          const details = [
            theme.bold(theme.fg("accent", "Pi")) +
              theme.fg("dim", ` v${VERSION}`),
            [
              rawKeyHint("/", "commands"),
              rawKeyHint("!", "bash"),
              keyHint("app.tools.expand", "more"),
            ]
              .map((hint) => theme.bold(hint))
              .join(theme.fg("muted", " · ")),
            theme.fg("success", "●") +
              " " +
              theme.bold(theme.fg("success", "ready")),
          ];
          const padding = " ".repeat(Math.min(3, Math.max(0, width - 1)));
          const available = width - padding.length;
          const detail_width = available - logo_width - 3;
          let lines: string[];
          if (detail_width >= 12) {
            lines = styled_logo.map((line, index) => {
              const detail = details[index - 3];
              return (
                line +
                " ".repeat(logo_width - visibleWidth(logo[index])) +
                (detail
                  ? "   " + truncateToWidth(detail, detail_width, "…")
                  : "")
              );
            });
          } else if (available >= logo_width) {
            lines = [...styled_logo, ...details];
          } else {
            lines = [details[0], details[2]];
          }
          return lines.map(
            (line) => padding + truncateToWidth(line, available, "…"),
          );
        },
      };
    });
  });
  pi.on("session_shutdown", (_event, ctx) => {
    if (ctx.mode === "tui") ctx.ui.setHeader(undefined);
  });
}
