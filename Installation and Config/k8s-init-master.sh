#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

echo "Initializing Kubernetes Master Node..."

# Set the pod network CIDR
POD_NETWORK_CIDR="10.244.0.0/16"

# Initialize the master node
kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR --control-plane-endpoint=master-node

# Copy kubeconfig to user's home directory
USER_HOME=$(eval echo ~${SUDO_USER})
mkdir -p $USER_HOME/.kube
cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
chown $(id -u ${SUDO_USER}):$(id -g ${SUDO_USER}) $USER_HOME/.kube/config

# Apply Flannel network plugin
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Remove control-plane taint to allow pods to be scheduled on master node
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "Master Node Initialization Complete!"
echo "You can now join worker nodes using the join command provided above."
echo "To view cluster status, run: kubectl get nodes"