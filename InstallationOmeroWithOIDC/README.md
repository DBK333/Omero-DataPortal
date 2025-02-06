# Omero-DataPortal

Omero-DataPortal is a data portal for managing and accessing OMERO images with OIDC authentication.

## Installation

Follow these steps to install and set up the portal.

### Prerequisites

Ensure you have the following installed:
- Docker
- Docker Compose
- NGROK account (for authentication token)

### Clone the Repository

```sh
git clone https://github.com/DBK333/Omero-DataPortal.git
cd Omero-DataPortal/InstallationOmeroWithOIDC
```

### Set Up Environment Variables

Replace `your_token_here` with your actual NGROK authentication token:

```sh
echo "NGROK_AUTH_TOKEN=your_token_here" > .env
```

### Run the Setup Script

Ensure the script has execution permissions and then run it with sudo:

```sh
chmod +x setup.sh
sudo ./setup.sh
```

## Usage

Once the setup is complete, the OMERO Data Portal should be running. You can access it via the provided URL after NGROK establishes a tunnel.

## Troubleshooting

- If the setup script fails, ensure Docker is running and that you have the correct NGROK token.
- Check logs using `docker logs <container_id>` for more details.

## Reference

https://github.com/ome/docker-example-omero-ldap


