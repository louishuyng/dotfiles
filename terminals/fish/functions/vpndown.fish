function vpndown -d 'kill openvpn'
  set -l id (pgrep openvpn);sudo kill -2 $id
end
#
function myvpn -d 'open my vpn config'
  sudo openvpn --config ~/Dev/Keychain/louis-vpn.ovpn
end
