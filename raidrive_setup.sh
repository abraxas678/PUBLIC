#!/bin/bash
print_step "Checking if RaiDrive CLI is installed..."
if ! command -v raidrivecli &> /dev/null; then
    print_sub_step "RaiDrive CLI not found. Installing..."
    print_sub_step "Downloading RaiDrive CLI package..."
    wget https://app.raidrive.com/deb/pool/main/r/raidrive/raidrive_2024.9.27.6-linux_amd64.deb -q --show-progress
    print_sub_step "Updating package list before installing RaiDrive..."
    sudo apt update
    print_sub_step "Installing RaiDrive CLI..."
    sudo apt install -y ./raidrive_2024.9.27.6-linux_amd64.deb
else
    print_sub_step "RaiDrive CLI is already installed."
fi
