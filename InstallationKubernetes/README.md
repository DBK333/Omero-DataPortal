# Omero DataPortal Installation Guide

This guide provides step-by-step instructions for setting up the Omero DataPortal with Kubernetes on your instance.

## Prerequisites

1. **SSH Access**: Ensure you have SSH access to your instance.
2. **Authentication File**: Download the required `.pem` file for authentication.
3. **Tools Installation**: Install the following tools if they are not already installed:
   - `git`
   - `docker`
   - `kubectl`

---

## Installation Steps

### Step 1: SSH into the Instance

Access your instance using the following command:

```bash
ssh -i ~/path_to_your_key_file.pem ubuntu@<instance-ip-address>
```

Replace `~/path_to_your_key_file.pem` with the path to your `.pem` file and `<instance-ip-address>` with your instance’s IP address.

### Step 2: Clone the Repository

Download the Omero DataPortal repository from GitHub:

```bash
git clone https://github.com/DBK333/Omero-DataPortal
cd Omero-DataPortal/Installation\ and\ Config/
chmod +x install-script.sh k8s-deploy.sh k8s-init-master.sh k8s-worker-node.sh
```

### Step 3: Run the Installation Script

Execute the installation script:

```bash
./install-script.sh
```

If the process stops with the following message:

```bash
Executing: /lib/systemd/systemd-sysv-install enable docker
Docker group changes require a new session.
Please run: 'exec su -l ubuntu' and then run this script again.
```

Follow these steps:

1. Exit the SSH session:
   ```bash
   exit
   ```
2. Re-login to the instance:
   ```bash
   ssh -i ~/path_to_your_key_file.pem ubuntu@<instance-ip-address>
   ```
3. Navigate back to the installation directory and rerun the installation script:
   ```bash
   cd Omero-DataPortal/Installation\ and\ Config/
   ./install-script.sh
   ```

### Step 4: Deploy Kubernetes

Run the Kubernetes deployment script:

```bash
sudo ./k8s-deploy.sh
```

---

## Setting Up the Master Node

1. Modify the `k8s-init-master.sh` file to specify the IP addresses of the master node:
   ```bash
   nano k8s-init-master.sh
   ```
2. Deploy Kubernetes on the master node:
   ```bash
   sudo ./k8s-init-master.sh
   ```

---

## Pairing Worker Nodes

To connect worker nodes to the master node, follow the pairing instructions provided in the Kubernetes setup documentation.

---

## Port Details

For a detailed list of required ports, refer to the [Required Port for Deployments](https://github.com/DBK333/Omero-DataPortal/blob/main/Ports.md).

---

## Notes

- Refer to the repository documentation for additional details.
- For a list of required ports, consult the `ports.md` file included in the repository.

