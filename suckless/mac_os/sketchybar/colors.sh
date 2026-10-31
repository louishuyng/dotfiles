#!/bin/bash
# color tokens — THEME=dark | light | auto (config.sh)
source "$CONFIG_DIR/config.sh"
T="${THEME:-dark}"
if [ "$T" = "auto" ]; then
  defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark && T=dark || T=light
fi

if [ "$T" = "light" ]; then
  export BG=0xfff4f6f4 BG2=0xffe8ebe8 SURFACE=0xffffffff
  export TEXT=0xff101413 TEXT2=0xff59635c TEXT3=0xff6e7a72
  export LINE=0xffd3dad4
  export ERR=0xffb03a30 WARN=0xff8a6410 INFO=0xff2a5f7d   # INFO: calendar Saturday (rev 9) — --info
else
  export BG=0xff08090a BG2=0xff131917 SURFACE=0xff0b0e0d
  export TEXT=0xffe6ebe6 TEXT2=0xff8b968e TEXT3=0xff6b776f
  export LINE=0xff1e2422
  export ERR=0xffe0685f WARN=0xffe0b64a INFO=0xff7fb8d9   # INFO: calendar Saturday (rev 9) — --info
fi
export ACCENT=0xff3ed49c   # shared by both themes. Used only for the wordmark cursor
export FONT="JetBrains Mono"
