#!/bin/sh
# Makes the mise-managed Rust toolchain reachable from GUI-launched Gram.
#
# Gram inherits the bare launchd PATH (/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin)
# — no /opt/homebrew/bin, no mise, no RUSTUP_HOME — so building a Wasm extension
# fails with "failed to run rustc: No such file or directory". Symlinked into
# /usr/local/bin as rustc/cargo/rustup, this dispatches on the name it was called
# by and hands off to mise's toolchain with the env its rustup proxies need.
#
# RUSTUP_HOME/CARGO_HOME are required, not cosmetic: mise's rustc is a rustup
# proxy, and without them it falls back to ~/.rustup and exits with "could not
# choose a version of rustc to run".
#
# `mise where rust` is resolved on each call so a mise version bump doesn't
# leave these shims pointing at a toolchain that no longer exists.

set -eu

root=$(/opt/homebrew/bin/mise where rust 2>/dev/null) || {
  echo "rust-shim: 'mise where rust' failed — is rust installed via mise?" >&2
  exit 127
}

export RUSTUP_HOME="$root" CARGO_HOME="$root"
exec "$root/bin/${0##*/}" "$@"
