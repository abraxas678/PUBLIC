#! /bin/bash
tput civis
        echo -e "\e[1;34m╭─ Execute step: $1?\e[0m"
        echo -ne "\e[1;34m╰─ [y/N]:\e[0m"
        read -n 1 confirm
        echo
        [[ "$confirm" = "y" ]] && echo 0 || echo 1
tput cnorm
