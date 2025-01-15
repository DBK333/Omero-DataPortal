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

echo "Allowing OMERO.server ports (4063, 4064) and OMERO.web port (4080)..."
sudo ufw allow 4063/tcp
sudo ufw allow 4064/tcp
sudo ufw allow 4080/tcp

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

#
# 3. Retrieve docker composer
#
git clone https://github.com/ome/docker-example-omero.git
cd docker-example-omero
sudo docker compose pull
sudo docker compose up -d

echo "Setup complete!"
echo "Services are running in the background."
echo "You can check logs with 'docker-compose logs -f [service_name]'"
echo "Visit http://<YOUR_SERVER_IP>:4080 to access OMERO.web."
sleep 30
sudo docker compose logs -f