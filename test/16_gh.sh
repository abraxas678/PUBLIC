which gh 
if [[ $? != 0 ]]; then 
    echothis "install gh"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $MYSUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | $MYSUDO tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    $MYSUDO apt update
    $MYSUDO apt install gh
fi
