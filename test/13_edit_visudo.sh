#! /bin/bash
[[ $($MYSUDO cat /etc/sudoers | grep -v grep | grep "$MYUSER ALL=(ALL) NOPASSWD: ALL" | wc -l) = 0 ]] && echo "$MYUSER ALL=(ALL) NOPASSWD: ALL" | $MYSUDO EDITOR=nano tee -a /etc/sudoers
