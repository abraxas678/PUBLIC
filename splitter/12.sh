#!/bin/bash
###12. Tailscale status check   DELETE
# Tailscale status check
TAILSCALE=$(tailscale status | grep dasaqwe | wc -l)
echo "Tailscale connected devices: $TAILSCALE"
