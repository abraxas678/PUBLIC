#!/bin/bash
sudo apt update
sudo apt install -y python3-pip ffmpeg
mkdir $HOME/github
cd $HOME/github
git clone https://github.com/Unmanic/unmanic.git
cd unmanic
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
python3 -m pip install unmanic
sudo mkdir -p /opt/unmanic
sudo chown $(id -u) /opt/unmanic
mkdir -p ~/.config/systemd/user

cat << EOF > sudo tee /etc/systemd/system/unmanic.service
[Unit]
Description=Unmanic - Library Optimiser
After=network-online.target
StartLimitInterval=200
StartLimitBurst=3

[Service]
Type=simple
Environment="HOME_DIR=/opt/unmanic"
WorkingDirectory=/opt/unmanic
ExecStart=%h/.local/bin/unmanic
Restart=always
RestartSec=30

[Install]
WantedBy=default.target
EOF

sudo systemctl enable unmanic.service
sudo systemctl start unmanic.service
echo
sudo systemctl status unmanic.service
echo
#You can view the logs
#journalctl --user -u unmanic.service

sleep 3
open http://localhost:8888

