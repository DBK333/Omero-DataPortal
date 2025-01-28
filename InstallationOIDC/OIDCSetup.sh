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
# 2. Adjust directories (clone or cd into your repo)
########################################
# Clone only if it's not already cloned. Otherwise, remove or comment out the clone step:
git clone https://github.com/varshithmee/redmane-auth/ || true

# Adjust this path as needed if you already have the repo
cd redmane-auth

########################################
# 3. Paths to compose files
########################################
YAML_FILE="docker-compose.yaml"  # main docker-compose file
YAML_FILE2="OIDCSetup.sh"    # second file (treated as compose YAML)

# Check if the main docker-compose.yml exists
if [[ ! -f "$YAML_FILE" ]]; then
  echo "Error: $YAML_FILE not found!"
  exit 1
fi

########################################
# 4. Append the 'networks' block for OIDC (only if not already present)
########################################
cat <<EOL >> "$YAML_FILE"

networks:
  OIDC:
    external: true
EOL

########################################
# 5. Create OIDC network
########################################
docker network create OIDC || true

########################################
# 6. Run 'make up'
########################################
# Prompt the user for the NGROK_AUTH_TOKEN
echo "Running 'make up' ..."
read -p "Please enter your NGROK_AUTH_TOKEN: " NGROK_AUTH_TOKEN

# Check if the input is not empty
if [ -z "$NGROK_AUTH_TOKEN" ]; then
  echo "Error: NGROK_AUTH_TOKEN cannot be empty."
  exit 1
fi

# Append the token to the .env file
echo "NGROK_AUTH_TOKEN=$NGROK_AUTH_TOKEN" >> .env
echo "NGROK_AUTH_TOKEN has been saved to .env."

# Run the 'make up' command
make up

########################################
# 7. Start Bitnami OpenLDAP
########################################
# Move up two directories again, then into $HOME/Omero-DataPortal
cd ..
echo "Creating OIDC network (if it doesn't exist) and starting Bitnami OpenLDAP..."

# Spin up the service in detached mode using your second file
docker compose -f "$YAML_FILE2" up -d

echo "OpenLDAP is now starting. Run 'docker compose logs -f' or 'docker ps' to verify."
