# Adopt SketchyBar Island with AeroSpace workspaces

Status: accepted by user approval on 2026-10-31.

## Context

The user requested the setup shared in [SketchyBar discussion comment 18804867](https://github.com/FelixKratz/SketchyBar/discussions/47#discussioncomment-18804867), then approved replacing the current Lua bar. The reference uses shell scripts and compiled Swift helpers; its workspace indicators track native macOS Spaces, while this Mac uses nine AeroSpace workspaces.

## Decision

Vendor [sketchybar-island revision 26b80f6](https://github.com/garamnohhh/sketchybar-island/tree/26b80f66fb7ac1cfc940cc7eebc8e41c06c3797b) with its MIT license. Preserve the Lua entry point as `sketchybarrc.lua-backup` and retain its modules for rollback. Keep the existing configuration symlink.

Replace the static wordmark with the focused AeroSpace workspace name and remove the separate workspace block, as requested during review. Use the existing workspace-change event and a five-second polling fallback; bound CLI calls with the same three-second timeout used by the Lua backend. Preserve the last good state on CLI failure. Coordinate workspace/front-app title resizing and media sizing through one shared animation to prevent overlap. Disable Rectangle auto-maximize, follow the macOS theme, and install `media-control` for the media island. Build Swift helpers locally and exclude binaries from Git.

The user also requested Pilo. Install its published 0.3.4 npm package and run its local server as a macOS user service. Enable its bundled usage plugin for new Fish-launched Claude sessions, and let SketchyBar read those reports alongside the existing caches. Keep desk selection and project-owner registration in Pilo's setup flow; the installer does not create tasks or install approval hooks.

## Consequences

The reference layout and interactions are available without rebuilding them in Lua. We maintain the vendored shell/Swift configuration and its small AeroSpace adaptation. A Lua port would retain the previous runtime but require reimplementing the reference's helpers and popups. Optional macOS permissions remain under the user's control. Setup and rollback are documented in the [SketchyBar README](../../suckless/mac_os/sketchybar/README.md).
