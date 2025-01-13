#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

echo "Initializing Kubernetes Master Node..."

# Get the primary IP address
PRIMARY_IP=$(ip route get 1 | awk '{print $7;exit}')
if [[ -z "${PRIMARY_IP}" ]]; then
    echo "Error: Could not determine primary IP address"
    exit 1
fi

# Set the pod network CIDR for Flannel
POD_NETWORK_CIDR="10.244.0.0/16"

# Reset any existing cluster configuration
kubeadm reset -f

# Clean up CNI configurations
rm -rf /etc/cni/net.d/*

# Initialize the control plane
echo "Initializing control plane with IP: ${PRIMARY_IP}"
kubeadm init \
  --pod-network-cidr="${POD_NETWORK_CIDR}" \
  --apiserver-advertise-address="${PRIMARY_IP}" \
  --upload-certs \
  --ignore-preflight-errors=all

# Wait for API server to be ready
timeout=120
echo "Waiting for API server to be ready..."
while ! curl -k "https://${PRIMARY_IP}:6443/healthz" &>/dev/null; do
    if [ $timeout -le 0 ]; then
        echo "Timeout waiting for API server"
        exit 1
    fi
    timeout=$((timeout-1))
    sleep 1
done

# Set up kubeconfig for the root user
export KUBECONFIG=/etc/kubernetes/admin.conf

# Set up kubeconfig for the regular user
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(eval echo ~${SUDO_USER})
    mkdir -p "${USER_HOME}/.kube"
    cp -i /etc/kubernetes/admin.conf "${USER_HOME}/.kube/config"
    chown -R "${SUDO_USER}:$(id -gn ${SUDO_USER})" "${USER_HOME}/.kube"
fi

# Wait for core components to be ready
echo "Waiting for core components to be ready..."
until kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; do
    sleep 5
done

# Download and apply Flannel manifest
echo "Installing Flannel network plugin..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Remove control-plane taint to allow pods on master node (optional)
echo "Removing control-plane taint..."
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
kubectl taint nodes --all node-role.kubernetes.io/master- || true

# Verify cluster status
echo "Verifying cluster status..."
kubectl get nodes
kubectl get pods --all-namespaces

echo "Master Node Initialization Complete!"
echo "Cluster is ready to accept worker nodes."
echo "To join workers to this cluster, run the following command on each worker node:"
kubeadm token create --print-join-command

echo "To check cluster status, run:"
echo "  kubectl get nodes"
echo "  kubectl get pods --all-namespaces"