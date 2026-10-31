# Restore the upstream screenshot header on Pi 1.x

Status: accepted by user approval. Amends the appearance chosen in [ADR 0009](0009-pi-droid-styling.md).

## Context

The [README screenshot](https://github.com/sting8k/pi-droid-styling/blob/4f97848ce9369fe2d0bddbf2407eed1d28ae689f/screenshots/image.png) shows Pi 0.84.2 with Droid 2.9.1's large gradient logo. Droid stopped overriding the header on Pi 0.99+ and [removed its legacy header implementation](https://github.com/sting8k/pi-droid-styling/commit/8f128814ece3e059ca81ec2f57e8ba8eedb4e273) when requiring Pi 1.x. Theme changes alone cannot restore that graphic.

## Decision

Keep Pi 1.4 and the pinned Droid 3.0.0 package. Adapt the original nine-line logo, gradient, and responsive header layout into `pi/agent/extensions/droid_header.ts`, with attribution and the upstream MIT license. Use the supported `ctx.ui.setHeader()` API rather than patching installed package files or downgrading Pi. Only terminal mode mounts the header; shutdown clears it. Colors follow the active theme, including after reload.

Use the bundled `qoder-cli` green palette, `presentationStyle: reasonix`, and `userZoneStyle: gemini`. Use `inputBox.style: halfblock` for balanced half-line padding above and below the draft; upstream's `solid` frame adds padding only below it. Keep the legacy companion disabled.

## Consequences

The large graphic and unboxed conversations return without losing Pi 1.x compatibility. We maintain a small local header and its tests. The author's complete personal configuration is not published with the screenshot, and newer Droid releases have changed details such as completed-tool markers; this is a source-based adaptation, not an exact recreation of the older runtime. No model, authentication, terminal font, or terminal background settings change.
