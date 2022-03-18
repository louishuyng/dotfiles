function sys_log -d 'tail system log' 
  tail -f ~/sys_log/$argv[1].log
end
