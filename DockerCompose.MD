# Docker Compose Installation

To set up the project using Docker Compose, follow these steps:

---

## Step 1: Clone the Repositories and Run Setup Commands

1. Clone the **Omero-DataPortal** repository:
    ```bash
    git clone https://github.com/DBK333/Omero-DataPortal/tree/main
    cd Omero-DataPortal
    ```

2. Make the setup script executable and run it:
    ```bash
    chmod +x OmeroWithComposerSetup.sh
    sudo ./OmeroWithComposerSetup.sh
    ```

3. Navigate back to the parent directory:
    ```bash
    cd ..
    ```

4. Clone the **docker-example-omero** repository:
    ```bash
    git clone https://github.com/ome/docker-example-omero.git
    cd docker-example-omero
    ```

---

## Step 2: Modify the `docker-compose.yml` File

1. Open the `docker-compose.yml` file for editing.

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
    sudo docker compose pull
    ```

2. Start the services in detached mode:
    ```bash
    sudo docker compose up -d
    ```

3. Display a confirmation message:
    ```bash
    echo "Setup complete!"
    echo "Services are running in the background."
    echo "You can check logs with 'docker-compose logs -f [service_name]'."
    echo "Visit http://<YOUR_SERVER_IP>:4080 to access OMERO.web."
    ```

4. Optionally, monitor the service logs:
    ```bash
    sleep 30
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