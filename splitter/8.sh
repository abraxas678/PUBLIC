#!/bin/bash
#8. Tailscale Setup

# Install Tailscale
which tailscale > /dev/null
if [[ $? != 0 ]]; then
  echo "install tailscale"
  sleep 1
  curl -L https://tailscale.com/install.sh | sh
  sudo tailscale up
fi
sudo tailscale up --ssh --accept-routes
tailscale status
countdown 2

tailscale status
if [[ $? != "0" ]]; then
  sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
  countdown 2
  sudo tailscale up --ssh --accept-routes
fi
echo

# HISHTORY
curl https://hishtory.dev/install.py | python3 -
hishtory init $YOUR_HISHTORY_SECRET


