# Docker Compose Installation

To set up the project using Docker Compose, follow these steps:

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

## Step 3: Start the Docker Services

1. Pull the necessary Docker images:
    ```bash
    sudo docker compose -f omero-compose.yaml pull
    ```

2. Start the services in detached mode:
    ```bash
    sudo docker compose -f omero-compose.yaml up -d
    ```

3. Optionally, monitor the service logs:
    ```bash
    sudo docker compose -f omero-compose.yaml logs -f
    ```

## Step 4: Using OMERO CLI for Uploads

1. Copy your data files to the upload directory:
    ```bash
    # From your local machine
    scp /path/to/your/images/* ubuntu@<YOUR_SERVER_IP>:~/Omero-DataPortal/InstallationDockerCompose/data/
    ```

2. Use the OMERO CLI container for imports:
    ```bash
    # Login to OMERO
    docker exec omerocli omero login -s omeroserver -p 4064 -u root -w omero

    # Import files from the data directory
    docker exec omerocli omero import /data/*.tif

    # Create a dataset and import into it
    docker exec omerocli omero obj new Dataset name=MyDataset
    docker exec omerocli omero import -d MyDataset /data/*.tif
    ```

3. Common CLI commands:
    ```bash
    # List users
    docker exec omerocli omero user list

    # Check import status
    docker exec omerocli omero fs list

    # Create a new project
    docker exec omerocli omero obj new Project name=MyProject

    # Create a dataset in a project
    docker exec omerocli omero obj new Dataset name=MyDataset project=MyProject
    ```

## Step 5: Access the OMERO.web Interface

- **Local Access**: Open your browser and visit:
  ```
  http://localhost:4080
  ```

- **Remote Server Access**: Replace `<YOUR_SERVER_IP>` with your server's actual IP address and visit:
  ```
  http://<YOUR_SERVER_IP>:4080
  ```

## Notes:

- **Username and Password**: If there is no change in password, use **Username:** root and **Password:** omero
- **Upload Directory**: The `./data` directory is shared between the host system and the OMERO containers
- **Logs**: Use the following commands to troubleshoot any issues:
  ```bash
  # All services
  docker compose -f omero-compose.yaml logs -f

  # Specific service
  docker compose -f omero-compose.yaml logs -f omeroserver
  docker compose -f omero-compose.yaml logs -f omerocli
  ```
- **Documentation**: For more details, refer to the official project repositories:
  - [docker-example-omero Repository](https://github.com/ome/docker-example-omero)
  - [Redmane Authentication Repository](https://github.com/varshithmee/redmane-auth/)