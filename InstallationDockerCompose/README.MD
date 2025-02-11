# Docker Compose Installation

To set up the project using Docker Compose in a server, follow these steps:

---

## Prerequisites

Ensure you have the following ports open:
- OMERO Web and Server
- Refer to [Security and Ports](https://github.com/DBK333/Omero-DataPortal/blob/main/SECURITY.MD) for detailed port configuration numbers.
- **For Nectar VM users:** Create a security group with the necessary ports open. The setup script only configures the firewall, not the security group.

---

## Step 1: Clone the Repositories and Run Setup Commands

1. Clone the **Omero-DataPortal** repository:
    ```bash
    git clone https://github.com/DBK333/Omero-DataPortal
    cd Omero-DataPortal/InstallationDockerCompose/
    ```

2. Make the setup script executable and run it:
    ```bash
    chmod +x OmeroWithComposerSetup.sh
    sudo ./OmeroWithComposerSetup.sh
    ```

---

## Step 2: Modify the `docker-compose.yml` File

1. Open the `omero-compose.yml` file for editing.

2. Locate the `ROOTPASS` environment variable and update it with a secure password:
    ```yaml
    environment:
      CONFIG_omero_db_host: database
      CONFIG_omero_db_user: omero
      CONFIG_omero_db_pass: omero
      CONFIG_omero_db_name: omero
      ROOTPASS: your_secure_password_here
    ```

   Replace `your_secure_password_here` with your desired password.

---

## Step 3: Start the Docker Services

1. Pull the necessary Docker images:
    ```bash
    sudo docker compose -f omero-compose.yml pull
    ```

2. Start the services in detached mode:
    ```bash
    sudo docker compose -f omero-compose.yml up -d
    ```

3. Optionally, monitor the service logs:
    ```bash
    sudo docker compose -f omero-compose.yml logs -f
    ```

---

## Step 4: Access the OMERO.web Interface

- **Local Access**: Open your browser and visit:
  ```
  http://localhost:4080
  ```

- **Remote Server Access**: Replace `<YOUR_SERVER_IP>` with your server's actual IP address and visit:
  ```
  http://<YOUR_SERVER_IP>:4080
  ```

---

## Notes:

- **Username and Password**: If the password remains unchanged, use:
  - **Username:** root  
  - **Password:** omero  
- **Logs**: Use the following command to troubleshoot any issues:
  ```bash
  sudo docker compose logs -f
  ```
- **Documentation**: For more details, refer to the official project repositories:
  - [docker-example-omero Repository](https://github.com/ome/docker-example-omero)
  - [Redmane Authentication Repository](https://github.com/varshithmee/redmane-auth/)

---

## SSH Issues & Nectar VM Console

If you experience SSH issues after logging out, it is recommended to use the **Nectar VM console** of the instance. Please refer to [Nectar VNC Console Setup](https://tutorials.rc.nectar.org.au/connecting/01-overview) for detailed instructions on accessing the console.

---

## Status

This setup is fully functional and correctly configured.
