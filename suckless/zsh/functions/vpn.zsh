function vpn-up() {
  VPN_HOST=$1;
  if [[ -z $VPN_HOST ]]
  then
    echo "Please set VPN_HOST"
    return
  fi
  echo "Starting the vpn ..."
  sudo openconnect --background --user=$USER  $VPN_HOST
}

function vpn-down() {
  sudo kill -2 `pgrep openconnect`
}

function ovpn-up() {
  VPN_CONFIG=$1

  if [[ -z $VPN_CONFIG ]]
  then
    echo "Please set VPN_CONFIG"
    return
  fi
  echo "Starting the openvpn ..."
  sudo openvpn --config ~/Documents/pass/$VPN_CONFIG.ovpn --auth-user-pass ~/Documents/pass/$VPN_CONFIG-ovpn-pass.txt
}

function ovpn-down() {
  sudo kill -2 `pgrep openvpn`
}
