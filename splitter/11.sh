!/bin/bash
#11 rclone install

 Install rclone beta
echo "rclone beta"
countdown 1
sudo -v
curl https://rclone.org/install.sh | sudo bash -s beta
