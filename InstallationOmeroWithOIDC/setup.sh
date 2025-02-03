#!/usr/bin/env bash
set -euo pipefail

################################################################################
# 1. Install and enable UFW; open relevant firewall ports
################################################################################
if ! command -v ufw &>/dev/null; then
  echo "Installing UFW..."
  sudo apt-get update -y
  sudo apt-get install -y ufw
fi

echo "Enabling UFW..."
sudo ufw --force enable

echo "Allowing OpenLDAP ports (389, 636, 8080, 8443, 4040)..."
sudo ufw allow 389/tcp
sudo ufw allow 636/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 4040/tcp

echo "Allowing OMERO.server ports (4063, 4064), and OMERO.web port (4080)..."
sudo ufw allow 4063/tcp
sudo ufw allow 4064/tcp
sudo ufw allow 4080/tcp

################################################################################
# 2. Update system packages, install 'make' (if needed)
################################################################################
echo "Updating system packages..."
sudo apt-get update -y

echo "Installing make (if not already installed)..."
sudo apt-get install -y make

################################################################################
# 3. Install Docker Engine if not present
################################################################################
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

################################################################################
# 4. Install Docker Compose if not present
################################################################################
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

##########
