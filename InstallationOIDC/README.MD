# Installation Guide: OIDC with OMERO

This guide explains how to implement OIDC authentication for OMERO using Keycloak, OpenLDAP, and Auth0, and test the setup. Follow the steps below to configure and run the system.

## Architecture Overview
We will integrate the following components:
- **Keycloak** for identity and access management.
- **OpenLDAP** for directory services.
- **Auth0** for additional authentication support.

## Installation Steps

### Step 1: Clone the Omero-DataPortal Repository
Clone the repository containing the necessary files for OIDC setup:

```bash
git clone https://github.com/DBK333/Omero-DataPortal
cd Omero-DataPortal/InstallationOIDC/
```

### Step 2: Find NGROK_AUTH_TOKEN from the ngrok Dashboard
1. Log in to the ngrok dashboard.
2. Navigate to **Getting Started > Your Auth Token**.
3. Save the authentication token in terminal:

```bash
echo "NGROK_AUTH_TOKEN=your_token_here" > .env
```

### Step 3: Grant Execute Permissions and Run the Setup Script
Make the setup script executable and run it:

```bash
chmod +x OIDCSetup.sh
sudo ./OIDCSetup.sh
```

Once completed, go to the Keycloak UI by accessing the **Endpoints** section in the ngrok dashboard.

### Step 4: Set Up Auth0
Follow the Auth0 documentation to configure authentication settings for OMERO.

### Step 5: Set Up OpenLDAP
Configure OpenLDAP for directory services and ensure it integrates properly with Keycloak.

## References
For more detailed information and troubleshooting, refer to the following resources:

- [OMERO LDAP Update Discussion](https://forum.image.sc/t/update-ldap-from-omero/64070/29)
- [Redmane Auth Repository](https://github.com/varshithmee/redmane-auth/)
- [OMERO Deployments on GitLab](https://gitlab.in2p3.fr/fbi-data/websites/OmeroDeployments)

