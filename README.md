
# Omero DataPortal Installation Guide

This guide provides step-by-step instructions for setting up the Omero DataPortal on your instance.

## Prerequisites

1. Ensure you have SSH access to your instance.
2. Download the required `.pem` file for authentication.
3. Install necessary tools like `git`, `docker`, and `kubectl` (if not already installed).

---

## Installation Steps

### Step 1: SSH into the Instance

Access your instance using the following command:

```bash
ssh -i ~/Desktop/OmeroServer1.pem ubuntu@115.146.85.71
```

### Step 2: Clone the Repository

Download the Omero DataPortal repository from GitHub:

```bash
git clone https://github.com/DBK333/Omero-DataPortal
cd Omero-DataPortal/Installation\ and\ Config/
chmod +x install-script.sh k8s-deploy.sh k8s-init-master.sh
```

### Step 3: Run the Installation Script

Execute the installation script:

```bash
./install-script.sh
```

If the process stops at:

```bash
Executing: /lib/systemd/systemd-sysv-install enable docker
Docker group changes require a new session.
Please run: 'exec su -l ubuntu' and then run this script again.
```

1. Exit the SSH session:
   ```bash
   exit
   ```
2. Re-login to the instance:
   ```bash
   ssh -i ~/Desktop/OmeroServer1.pem ubuntu@115.146.85.71
   ```
3. Navigate back to the installation directory:
   ```bash
   cd Omero-DataPortal/Installation\ and\ Config/
   ```
4. Rerun the installation script:
   ```bash
   ./install-script.sh
   ```

### Step 4: Deploy Kubernetes

Run the Kubernetes deployment script:

```bash
sudo ./k8s-deploy.sh
```

---

## Setting Up the Master Node

1. Modify the `k8s-hostnames.yaml` file to specify the IP addresses of the worker and master nodes.
2. Deploy Kubernetes on the master node:
   ```bash
   sudo ./k8s-init-master.sh
   ```

---

## Pairing Worker Nodes

To connect worker nodes to the master node, follow the pairing instructions provided in the Kubernetes setup documentation.

---

## Notes

- Ensure all nodes have proper network access.
- Verify Kubernetes installation by running:
  ```bash
  kubectl get nodes
  ```
- For troubleshooting, consult the repository documentation or log files generated during installation.

---

## Security Groups: Ports and Protocols

### Master Node Ports (Control Plane)
| Protocol | Port Range   | Purpose                         | Used By                 |
|----------|--------------|---------------------------------|-------------------------|
| TCP      | 6443         | Kubernetes API server           | All                     |
| TCP      | 2379-2380    | etcd server client API          | kube-apiserver, etcd    |
| TCP      | 10250        | Kubelet API                     | Self, Control plane     |
| TCP      | 10251        | kube-scheduler                  | Self                    |
| TCP      | 10252        | kube-controller-manager         | Self                    |
| UDP      | 8472         | Flannel VXLAN overlay network   | All                     |

### Worker Node Ports
| Protocol | Port Range   | Purpose                         | Used By                 |
|----------|--------------|---------------------------------|-------------------------|
| TCP      | 10250        | Kubelet API                     | Self, Control plane     |
| TCP      | 30000-32767  | NodePort Services               | All                     |
| UDP      | 8472         | Flannel VXLAN overlay network   | All                     |
