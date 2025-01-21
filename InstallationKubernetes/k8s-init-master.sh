#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

# Function to configure firewall
setup_firewall() {
    echo "Configuring firewall rules..."
    
    # Enable UFW
    sudo ufw enable
    
    # Configure Kubernetes ports
    sudo ufw allow 6443/tcp        # Kubernetes API Server
    sudo ufw allow 2379:2380/tcp   # etcd Server Client API
    sudo ufw allow 10250/tcp       # Kubelet API
    sudo ufw allow 10251/tcp       # Kube-Scheduler
    sudo ufw allow 10252/tcp       # Kube-Controller-Manager

    # Configure Flannel ports
    sudo ufw allow 8472/udp        # VXLAN encapsulation (default)
    sudo ufw allow 8285/udp        # UDP encapsulation (if using UDP backend)
    sudo ufw allow 51820/udp       # WireGuard encryption (if using WireGuard)

    # Reload and show status
    sudo ufw reload
    sudo ufw status
}

# Main execution
echo "Starting Kubernetes master node initialization..."
# Setup firewall first
setup_firewall
sudo hostnamectl set-hostname master-node
sudo cp /etc/hosts /etc/hosts.bak
read -r MASTERNODE_IP
sudo sed -i '/^127\./!b;N;/^127\./!a ${MASTERNODE_IP} master-node' /etc/hosts
#Restart the terminal application to apply the hostname change.

echo "Starting Kubernetes master node initialization..."

# Set the hostname to "master-node"
sudo hostnamectl set-hostname master-node

# Backup the existing /etc/hosts file
sudo cp /etc/hosts /etc/hosts.bak

# Prompt for the master node IP address
read -p "Enter the IP address of the master node: " MASTERNODE_IP

# Validate that the MASTERNODE_IP is not empty
if [[ -z "$MASTERNODE_IP" ]]; then
    echo "Error: IP address cannot be empty. Exiting."
    exit 1
fi
# Prompt for the master node IP address
read -p "Enter the IP address of the worker node: " WORKERNODE_IP

# Validate that the MASTERNODE_IP is not empty
if [[ -z "$MASTERNODE_IP" ]]; then
    echo "Error: IP address cannot be empty. Exiting."
    exit 1
fi
# Add the master node entry to /etc/hosts after the last line starting with 127.x.x.x
sudo sed -i "/^127\./!b;N;/^127\./!a ${WORKERNODE_IP} master-node" /etc/hosts
sudo sed -i "/^127\./!b;N;/^127\./!a ${MASTERNODE_IP} master-node" /etc/hosts

echo "Hostname and hosts file updated. Restart your terminal to apply changes."
exec "$SHELL" -l

sudo sh -c 'echo KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs" >> /etc/default/kubelet'

sudo systemctl daemon-reload && sudo systemctl restart kubelet

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart Docker to apply configurations
sudo systemctl daemon-reload && sudo systemctl restart docker

if ! systemctl is-active --quiet docker; then
    echo "Error: Docker service failed to restart"
    exit 1
fi
sudo sh -c 'echo Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'
sudo systemctl daemon-reload && sudo systemctl restart kubelet
sudo kubeadm init --control-plane-endpoint=master-node --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/control-plane-


echo "Master Node Initialization Complete!"
echo "-------------------------------------"
echo "To view cluster status, run either:"
echo "  export KUBECONFIG=/etc/kubernetes/admin.conf && kubectl get nodes"
echo "OR"
echo "  kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes"