function vpn-up -d "start vpn with hostname"
  set -l VPN_HOST $argv[1];
  if [ -z $VPN_HOST ]
    echo "Please set VPN_HOST"
    return
  end

  echo "Starting the vpn ..."

  sudo openconnect --background --user=$USER  $VPN_HOST
end

function vpn-down -d 'kill openconnect vpn'
  set -l id (pgrep openconnect); sudo kill -2 $id
end

function vpnup -d 'start connection openvpn'
  set -l VPN_CONFIG $argv[1]

  if [ -z $VPN_CONFIG ]
    echo "Please set VPN_CONFIG"
    return
  end

  echo "Starting the openvpn ..."
  sudo openvpn --config ~/Documents/pass/$VPN_CONFIG.ovpn --auth-user-pass ~/Documents/pass/$VPN_CONFIG-ovpn-pass.txt
end

function vpndown -d 'kill openvpn'
  set -l id (pgrep openvpn);sudo kill -2 $id
end
#
function myvpn -d 'open my vpn config'
  sudo openvpn --config ~/Dev/Keychain/louis-vpn.ovpn
end
