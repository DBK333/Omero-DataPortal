#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

# Function to verify Docker and containerd
verify_prerequisites() {
    echo "Verifying prerequisites..."
    
    # Check Docker
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker is not running properly"
        journalctl -xeu docker
        exit 1
    fi
    
    # Check containerd
    if ! systemctl is-active --quiet containerd; then
        echo "Error: containerd is not running"
        journalctl -xeu containerd
        exit 1
    fi
}

# Function to get primary IP
get_primary_ip() {
    local ip
    ip=$(ip route get 1 | awk '{print $7;exit}')
    if [[ -z "${ip}" ]]; then
        echo "Error: Could not determine primary IP address"
        exit 1
    fi
    echo "${ip}"
}

# Function to wait for API server
wait_for_apiserver() {
    local ip=$1
    local timeout=120
    echo "Waiting for API server to be ready..."
    while ! curl -k "https://${ip}:6443/healthz" &>/dev/null; do
        if [ $timeout -le 0 ]; then
            echo "Timeout waiting for API server"
            exit 1
        fi
        timeout=$((timeout-1))
        sleep 1
    done
}

# Function to wait for core components
wait_for_core_components() {
    echo "Waiting for core components to be ready..."
    local timeout=300
    while [ $timeout -gt 0 ]; do
        if kubectl get pods -n kube-system -l component=kube-apiserver --no-headers 2>/dev/null | grep -q "Running"; then
            return 0
        fi
        timeout=$((timeout-5))
        sleep 5
    done
    echo "Timeout waiting for core components"
    exit 1
}

echo "Initializing Kubernetes Master Node..."

# Verify prerequisites
verify_prerequisites

# Get primary IP
PRIMARY_IP=$(get_primary_ip)
POD_NETWORK_CIDR="10.244.0.0/16"

# Reset any existing cluster configuration
kubeadm reset -f || true
rm -rf /etc/cni/net.d/*
rm -rf $HOME/.kube

# Initialize the control plane
echo "Initializing control plane with IP: ${PRIMARY_IP}"
kubeadm init \
    --pod-network-cidr="${POD_NETWORK_CIDR}" \
    --apiserver-advertise-address="${PRIMARY_IP}" \
    --upload-certs \
    --ignore-preflight-errors=all

# Wait for API server
wait_for_apiserver "${PRIMARY_IP}"

# Configure kubectl
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Set up kubeconfig for the regular user if running with sudo
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(eval echo ~${SUDO_USER})
    mkdir -p "${USER_HOME}/.kube"
    cp -i /etc/kubernetes/admin.conf "${USER_HOME}/.kube/config"
    chown -R "${SUDO_USER}:$(id -gn ${SUDO_USER})" "${USER_HOME}/.kube"
fi

# Wait for core components
export KUBECONFIG=/etc/kubernetes/admin.conf
wait_for_core_components

# Install Flannel
echo "Installing Flannel network plugin..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Remove control-plane taints
echo "Removing control-plane taints..."
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
kubectl taint nodes --all node-role.kubernetes.io/master- || true

# Verify cluster status
echo "Verifying cluster status..."
kubectl get nodes
kubectl get pods --all-namespaces

# Generate join command
echo -e "\nCluster initialization complete!"
echo -e "\nTo join worker nodes, run this command on each worker:"
echo -e "\n$(kubeadm token create --print-join-command)\n"

# Print verification commands
echo "To verify cluster status, run:"
echo "  kubectl get nodes"
echo "  kubectl get pods --all-namespaces"

# Print system information
echo -e "\nSystem Information:"
echo "Docker Version: $(docker --version)"
echo "Kubernetes Version: $(kubectl version --short)"
echo "API Server Address: ${PRIMARY_IP}:6443"