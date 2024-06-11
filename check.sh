#!/bin/bash
while true; do
clear
ping 78.46.39.42 -c 1 >/dev/null

if [[ $? = 0 ]]; then
  echo "Hetzner Auction Ping: OK"
  echo "1" >hetzner_auction_ping.stat
else
  [[ $(cat hetzner_auction_ping.stat) = 1 ]] && curl 'HETZNER AUCTION PING FAILED' https://n.yyps.de/alert
  echo "0" >hetzner_auction_ping.stat
fi

sleep 1

done
