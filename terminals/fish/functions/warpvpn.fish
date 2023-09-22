function warpvpn -d 'toggle warpvpn'
  set warp_status (curl -s https://1.1.1.1/cdn-cgi/trace | grep warp=)

  if string match -q -- "*warp=on*" $warp_status
    warp-cli disconnect
  else
    warp-cli connect
  end
end
