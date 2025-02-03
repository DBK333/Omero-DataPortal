#!/usr/bin/env bash

# Exit on any error
set -e

########################################
# 1. Install make (if needed) & open firewall ports
########################################
echo "Installing make (if not already installed) and opening firewall ports..."

# Update apt cache and install 'make'
sudo apt-get update -y
sudo apt-get install -y make

#install docker
if ! command -v docker &>/dev/null; then
  echo "Installing Docker prerequisites..."
  sudo apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

  echo "Adding Docker’s official GPG key..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "Setting up Docker repository..."
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  echo "Installing Docker Engine..."
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  echo "Verifying Docker installation..."
  docker --version
else
  echo "Docker is already installed. Skipping..."
fi

if ! command -v docker-compose &>/dev/null; then
  echo "Installing Docker Compose..."
  sudo curl -L \
    "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  echo "Verifying Docker Compose installation..."
  docker-compose --version
else
  echo "Docker Compose is already installed. Skipping..."
fi

# Allow needed ports via ufw
sudo ufw allow 389/tcp
sudo ufw allow 636/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 4040/tcp

########################################
# 2. Start docker compose
########################################
# Spin up the service in detached mode using your second file
docker compose -f docker-compose.yaml up -d

echo "OpenLDAP is now starting. Run 'docker compose logs -f' or 'docker ps' to verify."