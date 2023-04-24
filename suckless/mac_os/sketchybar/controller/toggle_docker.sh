#!/usr/bin/env fish

if /Applications/Docker.app/Contents/Resources/bin/docker info > /dev/null 2>&1
   killall Docker
else
  open -a 'Docker'
end
