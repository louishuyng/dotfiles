export LOCAL_CUSTOM_TLD="luixdev"

# register .hack TLD locally
echo "address=/.${LOCAL_CUSTOM_TLD}/127.0.0.1" >> $(brew --prefix)/etc/dnsmasq.conf

# configure the local resolver
sudo mkdir -p /etc/resolver/

cat <<EOF | sudo tee /etc/resolver/${LOCAL_CUSTOM_TLD}
nameserver 127.0.0.1
EOF

# restart local dnsmasq service
sudo brew services restart dnsmasq

# restart mDNSResponder
sudo killall -HUP mDNSResponder

# verify the new resolver was picked up
scutil --dns
