#!/bin/bash
###8. Tailscale Setup
# Install Tailscale
which tailscale > /dev/null
if [[ $? != 0 ]]; then
echo "install tailscale"
sleep 1
curl -L https://tailscale.com/install.sh | sh
sudo tailscale up
fi

#### HISHTORY
