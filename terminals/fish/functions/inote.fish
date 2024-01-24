function inote -d "Today I note" 
  set name (date +%d-%m-%Y)-inote

  if test -f ~/notes/$name.md
    NVIM_BLACK=true notes open $name 
  else
    NVIM_BLACK=true notes new -t today-note $name
  end
end
