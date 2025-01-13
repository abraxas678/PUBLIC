#!/bin/bash
clear
cd $HOME

# Set the sudo prefix based on the current user
[[ $USER = root ]] && MYSUDO="" || MYSUDO="sudo"

# Main Functionality
echo "Updating package list..."
$MYSUDO apt update >/dev/null 2>&1

# Check if xsel is installed and install if necessary
echo "Checking if xsel is installed..."
if ! command -v xsel &> /dev/null; then
    echo "Installing xsel..."
    $MYSUDO apt install xsel -y >/dev/null 2>&1
fi

# Check if pcopy is installed and install if necessary
echo "Checking if pcopy is installed..."
if ! command -v pcopy &> /dev/null; then
    echo "Installing pcopy..."
    wget https://github.com/binwiederhier/pcopy/releases/download/v0.6.1/pcopy_0.6.1_amd64.deb >/dev/null 2>&1
    echo "Installing pcopy package..."
    $MYSUDO apt install -y ./pcopy_0.6.1_amd64.deb >/dev/null 2>&1
    echo "Joining pcopy..."
    pcopy join https://pc.yyps.de
fi

# Download and execute the script
echo "Downloading and executing script..."
curl -L start1.yyps.de | bash <&/dev/tty
