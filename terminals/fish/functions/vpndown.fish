function vpndown -d 'kill openvpn'
  set -l id (pgrep openvpn);sudo kill -2 $id
end
