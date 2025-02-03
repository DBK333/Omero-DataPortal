#!/usr/bin/env bash
set -e

echo "=============================="
echo "Updating system packages..."
echo "=============================="
sudo apt-get update -y && sudo apt-get upgrade -y

echo "=============================="
echo "Installing required packages..."
echo "=============================="
sudo apt-get install -y make curl gnupg lsb-release ufw

echo "=============================="
echo "Checking Docker installation..."
echo "=============================="
if ! command -v docker &>/dev/null; then
  echo "Docker not found. Installing Docker..."
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  echo "Adding Docker’s official GPG key..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "Setting up Docker repository..."
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  echo "Installing Docker..."
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  echo "Docker version:" $(docker --version)
else
  echo "Docker is already installed."
fi

echo "=============================="
echo "Checking Docker Compose installation..."
echo "=============================="
if ! command -v docker-compose &>/dev/null; then
  echo "Docker Compose not found. Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "Docker Compose version:" $(docker-compose --version)
else
  echo "Docker Compose is already installed."
fi

echo "=============================="
echo "Configuring UFW firewall..."
echo "=============================="
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp      # HTTP (needed for Traefik & Let's Encrypt challenge)
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 389/tcp     # LDAP (non-TLS)
sudo ufw allow 636/tcp     # LDAPS (TLS)
sudo ufw allow 8080/tcp    # Keycloak (if accessing directly for testing)
sudo ufw allow 8443/tcp    # Optionally, Keycloak native TLS port if used
sudo ufw allow 4040/tcp    # (Optional: e.g. for a dashboard)
sudo ufw --force enable

echo "=============================="
echo "Creating necessary directories..."
echo "=============================="
# These directories will hold Traefik's certs and any Keycloak realm import files.
mkdir -p ~/auth-stack/letsencrypt
mkdir -p ~/auth-stack/realm-config

echo "=============================="
echo "Changing to project directory: ~/auth-stack"
echo "=============================="
cd ~/auth-stack

echo "=============================="
echo "Starting Docker Compose stack..."
echo "=============================="
sudo docker-compose -f /home/ubuntu/Omero-DataPortal/InstallationOIDC/docker-compose.yaml up -d

echo "Setup complete!"
echo "Check container status with: docker-compose ps"
echo "View logs with: docker-compose logs -f"
