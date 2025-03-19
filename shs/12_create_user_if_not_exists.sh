[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"
if [[ $(whoami) != "$MYUSER" ]]; then
    echothis "Check if user $MYUSER exists"
    if ! id "$MYUSER" >/dev/null 2>&1; then
        echothis "Creating user $MYUSER..."
        $MYSUDO useradd -m -s /bin/bash $MYUSER
        echo "$MYUSER:$MYUSER" | $MYSUDO chpasswd
        $MYSUDO usermod -aG sudo $MYUSER
        echothis2 "User $MYUSER created"
    else
        echothis "User $MYUSER already exists"
    fi
fi
