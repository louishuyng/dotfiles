# Add Pip as a native Pi widget

Status: superseded as the primary frontend by [ADR 0008](0008-pitago-frontend.md); retained for native Pi.

## Context

The dotfiles owner requested a unique Pi interface and selected the animated-companion style from [pi-workstation's Navi showcase](https://github.com/marv1nnnnn/pi-workstation). The existing minimal footer remains useful, but the interface needs a recognizable visual identity.

Navi bundles feed polling, music integration, persistence, and several animation loops. Its source also targets an older Pi import namespace. Installing that bundle would change more than the requested visual surface.

## Decision

Implement the companion in [`pi/agent/extensions/companion.ts`](../../pi/agent/extensions/companion.ts), using Pi's native keyed widget, semantic theme colors, and terminal-width helpers. The original bird was restyled at the user's request into a Navi-inspired moon/particle panel below the editor with the local `wired-theater` theme. Keep the existing editor and Powerline footer. This native visual work is a fallback, not Pitago's sidebar renderer.

Observe agent, tool, and blocking-UI events without modifying them. Only `agent_settled` signals final completion; intermediate agent runs can still retry or continue. Track overlapping tool calls and prompt depth. Use a single scheduled animation callback, with session/disposal cleanup and no resources in non-terminal modes.

Provide pause/hide commands and a static startup flag. Keep motion subtle and text labels readable without relying on color. Do not fetch external feeds, call a model, persist usage-based levels, or add dependencies for decoration.

## Trade-off

A local extension needs small lifecycle/rendering tests but gives a distinctive companion without unrelated features or a Pi fork. Use an upstream companion instead if the owner later wants its feeds, music, progression, or other bundled behavior and approves that expanded scope.

Tern/Herdr/Muxy notification integration is separate from this presentation decision. See [`pi/README.md`](../../pi/README.md) for controls and checks.
