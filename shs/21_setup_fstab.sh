#!/bin/bash
sudo apt update
sudo apt install nfs-common -y
mkdir /home/abrax/tmp/ -p
cd /home/abrax/tmp/
cat /etc/fstab >/home/abrax/tmp/fstab
sudo mkdir /mnt/rock
sudo chown abrax: /mnt/rock -R
echo "192.168.0.131:/export /mnt/rock nfs vers=4,proto=tcp,port=2049,user=abrax 0 0" >> /home/abrax/tmp/fstab
sudo mv /home/abrax/tmp/fstab /etc/fstab
echo; sudo mount -a; echo

