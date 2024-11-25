### BWS
wget https://github.com/bitwarden/sdk/releases/download/bws-v1.0.0/bws-x86_64-unknown-linux-gnu-1.0.0.zip
unzip bws-x86_64-unknown-linux-gnu-1.0.0.zip
sudo mv bws /usr/bin/
rm -f bws-x86_64-unknown-linux-gnu-1.0.0.zip
bws config server-base https://vault.bitwarden.eu

chmod 600 ~/.ssh/*
chmod 700 ~/.ssh
