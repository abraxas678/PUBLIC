#!/bin/bash
cd $HOME
  CHECK=$(cat /etc/resolv.conf)
  if [[ $CHECK != *"8.8.8.8"* ]] ; then
    ONL=0
  else
    ping -c 1 google.com >/dev/null && echo "Online" || echo "Offline"
    ping -c 1 google.com >/dev/null && ONL=1 || ONL=0
  fi
if [[ $ONL = "0" ]]; then
  CHECK=$(cat /etc/resolv.conf)
  if [[ $CHECK != *"8.8.8.8"* ]] ; then
    echo nameserver 8.8.8.8 >~/resolv.conf
    cat /etc/resolv.conf>>~/resolv.conf
    sudo mv ~/resolv.conf /etc/
  fi
echo
ping -c 1 google.com >/dev/null && echo "Online" || echo "Offline"
fi
