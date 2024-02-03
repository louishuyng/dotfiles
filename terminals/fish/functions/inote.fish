function inote -d "Today I note" 
  set name (date +%d-%m-%Y)-inote

  if test -f ~/notes/$name.md
    NVIM_NOTE=true notes open $name 
  else
    NVIM_NOTE=true notes new -t today-note $name
  end
end
