# Omero-DataPortal

Omero-DataPortal is a data portal for managing and accessing OMERO images with OIDC authentication. This deployment assumes installation on a single instance.

## Installation

Follow these steps to install and set up the portal.

### Prerequisites

Ensure you have the following installed:
- Docker
- Docker Compose
- A NGROK account (for authentication token)

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

Ensure the script has execution permissions, then run it with sudo:

```sh
chmod +x setup.sh
sudo ./setup.sh
```

## Usage

Once the deployment is complete, the OMERO and OIDC components should be running. You can access OMERO via the provided URL once NGROK establishes a tunnel.

### Configuring OIDC and Authentication

To configure Keycloak to connect to OpenLDAP and Auth0 for OIDC authentication, please refer to the [OIDC Configuration Guide](https://github.com/DBK333/Omero-DataPortal/tree/main/InstallationOIDC).

For accessing the OMERO web interface, follow the steps below:
1. Identify the public NGROK URL after deployment.
2. Navigate to `https://your_ngrok_url/omero-web` in your browser.
3. Log in using your OMERO credentials.

## Authentication Flow

![Authentication Flow](authentication-flow.png)

## Troubleshooting

- If the setup script fails, ensure Docker is running and that you have provided the correct NGROK token.
- Check logs using:
  ```sh
  docker logs <container_id>
  ```
  for more details.

## Reference

For additional reference, see:
- [OMERO Docker Example with LDAP](https://github.com/ome/docker-example-omero-ldap)

## Deployment Status

- **Deployment Code:** Fully functional ✅
- **OIDC Configuration:** Partially functional ⚠️
- **OMERO Server & Web:** Fully functional ✅

### Accessing OMERO Web

To access the OMERO web interface:
- Ensure the server is running by checking OMERO logs:
  ```sh
  docker ps
  docker logs <omero_container_id>
  ```
- Open the NGROK URL in your browser to verify OMERO web is accessible.
- If OMERO web is unreachable, check port configurations and reverse proxy settings.

