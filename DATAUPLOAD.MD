# OMERO File Upload and Import Instructions

This guide explains how to:
1. Upload a file from your local machine to your Nectar VM.
2. Copy the file from your Nectar VM to your OMERO server container.
3. Log into the OMERO container.
4. Import the file into OMERO.

> **Note:** Replace all placeholder values (written in **BOLD**) with your actual details.

---

## 1. Upload File from Local Machine to Nectar VM

### Format:
```bash
scp -i ~/Desktop/**YOUR_KEYFILE.pem** ~/Desktop/**YOUR_FILE.tif** **YOUR_VM_USERNAME**@**YOUR_VM_IP_ADDRESS**:~/Omero-DataPortal/InstallationDockerCompose/
```

- **YOUR_KEYFILE.pem**: Your SSH key file (e.g., `OmeroServer1.pem`).
- **YOUR_FILE.tif**: Your image file.
- **YOUR_VM_USERNAME**: Your Nectar VM username (e.g., `ubuntu`).
- **YOUR_VM_IP_ADDRESS**: Your Nectar VM IP address (e.g., `118.138.239.88`).

### Example:
```bash
scp -i ~/Desktop/OmeroServer1.pem ~/Desktop/summarised_deconvolved_image_1.tif ubuntu@118.138.239.88:~/Omero-DataPortal/InstallationDockerCompose/
```

---

## 2. Copy the File from Nectar VM to OMERO Server Container

### Format:
```bash
sudo docker cp **YOUR_FILE.tif** **YOUR_CONTAINER_NAME**:/tmp/**YOUR_FILE.tif**
sudo docker exec -it **YOUR_CONTAINER_NAME** /bin/bash
```

- **YOUR_FILE.tif**: Your image file.
- **YOUR_CONTAINER_NAME**: The OMERO server container name.

### Example:
```bash
sudo docker cp summarised_deskewed_image_1.tiff installationdockercompose-omeroserver-1:/tmp/summarised_deskewed_image_1.tiff
sudo docker exec -it installationdockercompose-omeroserver-1 /bin/bash
```

---

## 3. Access the OMERO Container and Log In

```bash
cd
cd OMERO.server-5.6.14-ice36/bin
./omero login -s localhost -u root -w omero
```

---

## 4. Import the File into OMERO

### Format:
```bash
./omero import /tmp/**YOUR_FILE.tif**
```

### Example:
```bash
./omero import /tmp/summarised_deskewed_image_1.tiff
```

---

## Summary of Placeholder Replacements

- **YOUR_KEYFILE.pem**: Your SSH key file.
- **YOUR_FILE.tif**: Your image file.
- **YOUR_VM_USERNAME**: Your VM login name.
- **YOUR_VM_IP_ADDRESS**: Your VM's IP address.
- **YOUR_CONTAINER_NAME**: Your OMERO server container name.

---

Now you have both the format and an example for each step. Adjust file names and values as necessary for your configuration.
