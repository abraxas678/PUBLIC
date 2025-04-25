#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo ">>> Starting Docker installation for Debian/Ubuntu-based systems..."

# 1. Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo ">>> Docker appears to be already installed. Version:"
    docker --version
    echo ">>> Exiting installation script."
    exit 0
fi

# 2. Update package index and install prerequisites
echo ">>> Updating package list and installing prerequisites..."
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# 3. Add Docker's official GPG key
echo ">>> Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
# Check if the key file already exists and remove it to avoid potential issues
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    echo ">>> Removing existing docker.gpg key..."
    rm -f /etc/apt/keyrings/docker.gpg
fi
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up the Docker repository
echo ">>> Setting up Docker repository..."
# Detect architecture and OS version codename
ARCH=$(dpkg --print-architecture)
if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    VERSION_CODENAME=${VERSION_CODENAME:-$(lsb_release -cs)} # Fallback if not in /etc/os-release
else
    VERSION_CODENAME=$(lsb_release -cs)
fi

if [ -z "$VERSION_CODENAME" ]; then
    echo ">>> ERROR: Could not determine OS version codename."
    exit 1
fi

echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  ${VERSION_CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine
echo ">>> Installing Docker Engine..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Verify installation
echo ">>> Verifying installation by running hello-world container..."
if docker run hello-world; then
    echo ">>> Docker installed successfully!"
else
    echo ">>> ERROR: Docker hello-world container failed to run. Installation might be incomplete."
    exit 1
fi

# 7. Optional: Add current user to the docker group
#    This avoids needing sudo for every docker command.
#    Requires logout/login or `newgrp docker` to take effect.
if [ -n "$SUDO_USER" ]; then
    echo ">>> Adding user '$SUDO_USER' to the docker group..."
    usermod -aG docker "$SUDO_USER"
    echo ">>> NOTE: You need to log out and log back in for the group changes to take effect for user '$SUDO_USER'."
elif [ "$(id -u)" -eq 0 ] && [ -n "$USER" ] && [ "$USER" != "root" ]; then
     # Handle case where script is run directly as root, but we might want to add the invoking user
     echo ">>> Adding user '$USER' to the docker group..."
     usermod -aG docker "$USER"
     echo ">>> NOTE: You need to log out and log back in for the group changes to take effect for user '$USER'."
else
    echo ">>> Could not determine non-root user to add to the docker group. Run 'sudo usermod -aG docker \$USER' manually if desired."
fi


echo ">>> Docker installation script finished."
exit 0
