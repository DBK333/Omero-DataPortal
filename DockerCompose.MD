# Docker Compose Installation

To set up the project using Docker Compose, follow these steps:

---

## Step 1: Clone the Repositories and Run Setup Commands

1. Clone the **Omero-DataPortal** repository:
    ```bash
    git clone https://github.com/DBK333/Omero-DataPortal
    git clone https://github.com/varshithmee/redmane-auth/
    cd Omero-DataPortal/cd InstallationDockerCompose/
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
    sudo docker compose -f omero-compose.yaml pull
    ```

2. Start the services in detached mode:
    ```bash
    sudo docker compose -f omero-compose.yaml up -d
    ```

4. Optionally, monitor the service logs:
    ```bash
    sudo docker compose logs -f
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

- **Username and Password**: If there is no change in password, use   **Username:** root and **Password:** omero.
- **Logs**: Use the following command to troubleshoot any issues:
  ```bash
  docker-compose logs -f
  ```
- **Documentation**: For more details, refer to the official project repositories:
  - [docker-example-omero Repository](https://github.com/ome/docker-example-omero)