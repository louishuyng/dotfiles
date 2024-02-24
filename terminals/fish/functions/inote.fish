function inote -d "Today I note" 
  set name (date +%d-%m-%Y)-inote
  set folder dailies/$(date +%Y)/$(date +%m)/$name

  if test -f ~/notes/$folder.md
    NVIM_NOTE=true notes open $folder
  else
    NVIM_NOTE=true notes new -t today-note $folder
  end
end
