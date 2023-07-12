#!/usr/bin/env fish

if pgrep -x "OrbStack" >/dev/null
   killall OrbStack
else
  open -a 'OrbStack'
end
