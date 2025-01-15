#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

# Function to check if a port is open
check_port() {
    local port=$1
    if ! ss -tuln | grep -q ":$port "; then
        echo "✗ Port $port is not listening"
        return 1
    else
        echo "✓ Port $port is listening"
        return 0
    fi
}

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

    # Configure Calico ports
    sudo ufw allow 179/tcp         # BGP communication between nodes
    sudo ufw allow 4789/udp        # VXLAN encapsulation (if using VXLAN)
    sudo ufw allow 5473/tcp        # Typha component (if using Typha for scalability)
    sudo ufw allow 51820/udp       # WireGuard encryption (if using WireGuard)

    # Reload and show status
    sudo ufw reload
    sudo ufw status
}

# Function to initialize Kubernetes master
init_kubernetes_master() {
    echo "Initializing Kubernetes Master Node..."
    
    # Set the pod network CIDR
    local POD_NETWORK_CIDR="10.244.0.0/16"
    
    # Get the master IP or FQDN
    echo "Please enter the Master IP or FQDN for the control plane endpoint:"
    read -r CONTROL_PLANE_ENDPOINT
    
    # Initialize the control plane
    kubeadm init \
        --pod-network-cidr="${POD_NETWORK_CIDR}" \
        --control-plane-endpoint="${CONTROL_PLANE_ENDPOINT}"
        
    # Setup kubeconfig
    local USER_HOME=$(eval echo ~${SUDO_USER})
    mkdir -p "${USER_HOME}/.kube"
    cp -i /etc/kubernetes/admin.conf "${USER_HOME}/.kube/config"
    chown "$(id -u ${SUDO_USER}):$(id -g ${SUDO_USER})" "${USER_HOME}/.kube/config"
    
   # Apply Calico CNI
   kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml

   # Remove control-plane taint to allow scheduling pods on the master node
   kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
}

# Main execution
echo "Starting Kubernetes master node initialization..."

# Setup firewall first
setup_firewall

# Check required ports
echo "Checking required ports..."
required_ports=(6443 2379 2380 10250 10259 10257)
ports_ok=true

for port in "${required_ports[@]}"; do
    if ! check_port "$port"; then
        ports_ok=false
    fi
done

# Initialize Kubernetes master
init_kubernetes_master

echo "Master Node Initialization Complete!"
echo "-------------------------------------"
echo "To view cluster status, run either:"
echo "  export KUBECONFIG=/etc/kubernetes/admin.conf && kubectl get nodes"
echo "OR"
echo "  kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes"