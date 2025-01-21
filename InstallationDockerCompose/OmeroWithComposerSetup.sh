#!/usr/bin/env bash
set -euo pipefail

#
# 1. Enable and configure UFW (Ubuntu Firewall)
#
if ! command -v ufw &>/dev/null; then
  echo "Installing UFW..."
  sudo apt-get update
  sudo apt-get install -y ufw
fi

echo "Enabling UFW..."
sudo ufw enable

echo "Allowing OMERO.server ports (4063, 4064), Keycloak port (8080)and OMERO.web port (4080)..."
sudo ufw allow 4063/tcp
sudo ufw allow 4064/tcp
sudo ufw allow 4080/tcp
sudo ufw allow 8080/tcp

#
# 2. Install Docker Engine and Docker Compose if not present
#
echo "Updating system packages..."
sudo apt-get update

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

# Define the network name
NETWORK_NAME="omero"

# Check if the Docker network already exists
if ! docker network ls | grep -q "$NETWORK_NAME"; then
  echo "Creating external network: $NETWORK_NAME"
  docker network create "$NETWORK_NAME"
else
  echo "Network $NETWORK_NAME already exists."
fi


YAML_FILE="$HOME/redmane-suth/docker-compose.yml"

# Check if the file exists
if [[ ! -f "$YAML_FILE" ]]; then
  echo "Error: $YAML_FILE not found!"
  exit 1
fi

# Add the networks section to the YAML file
cat <<EOL >> "$YAML_FILE"

networks:
  omero:
    external: true
EOL