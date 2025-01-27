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

# Allow needed ports via ufw
sudo ufw allow 389/tcp
sudo ufw allow 636/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 4040/tcp

########################################
# 2. Adjust directories
########################################
# Move up two directories
cd ..
cd ..

########################################
# 3. Paths to compose files
########################################
YAML_FILE="$HOME/redmane-suth/docker-compose.yml"    # main docker-compose file
YAML_FILE2="$HOME/Omero-DataPortal/OIDCSetup.sh"      # second file (treated as compose YAML)

# Check if the main docker-compose.yml exists
if [[ ! -f "$YAML_FILE" ]]; then
  echo "Error: $YAML_FILE not found!"
  exit 1
fi

########################################
# 4. Append the 'networks' block for OIDC
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
echo "Running 'make up' ..."
make up

########################################
# 7. Start Bitnami OpenLDAP
########################################
# Move up two directories again, then into $HOME/Omero-DataPortal
cd ..
cd ..
cd "$HOME/Omero-DataPortal"

echo "Creating OIDC network (if it doesn't exist) and starting Bitnami OpenLDAP..."

# Create the OIDC network
docker network create OIDC || true

# Spin up the service in detached mode using your second file
docker compose -f "$YAML_FILE2" up -d

echo "OpenLDAP is now starting. Run 'docker compose logs -f' or 'docker ps' to verify."
