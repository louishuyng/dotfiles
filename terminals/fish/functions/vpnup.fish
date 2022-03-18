function vpnup -d 'start connection openvpn'
  set -l VPN_CONFIG $argv[1]

  if [ -z $VPN_CONFIG ]
    echo "Please set VPN_CONFIG"
    return
  end

  echo "Starting the openvpn ..."
  sudo openvpn --config ~/Documents/pass/$VPN_CONFIG.ovpn --auth-user-pass ~/Documents/pass/$VPN_CONFIG-ovpn-pass.txt
end
