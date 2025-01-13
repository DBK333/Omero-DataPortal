#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root"
   exit 1
fi

echo "Starting Kubernetes Node Configuration..."

# Function to check disk space
check_disk_space() {
    local free_space
    free_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
    if (( $(echo "$free_space < 10" | bc -l) )); then
        echo "Error: Insufficient disk space. Need at least 10GB free."
        exit 1
    fi
}

# Clean up existing Docker installation
cleanup_docker() {
    echo "Cleaning up existing Docker installation..."
    systemctl stop docker || true
    systemctl stop docker.socket || true
    systemctl stop containerd || true
    
    rm -rf /var/lib/docker
    rm -rf /etc/docker
    rm -rf /etc/containerd
    rm -f /etc/systemd/system/docker.service.d/*
    
    systemctl daemon-reload
}

# Configure kernel modules
setup_kernel_modules() {
    echo "Configuring kernel modules..."
    cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

    modprobe overlay
    modprobe br_netfilter

    if ! lsmod | grep -q "^overlay" || ! lsmod | grep -q "^br_netfilter"; then
        echo "Error: Failed to load required kernel modules"
        exit 1
    fi
}

# Configure system settings
configure_sysctl() {
    echo "Configuring system settings..."
    cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

    sysctl --system
}

# Setup containerd
setup_containerd() {
    echo "Setting up containerd..."
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    
    systemctl restart containerd
    systemctl enable containerd
    
    if ! systemctl is-active --quiet containerd; then
        echo "Error: containerd service failed to start"
        journalctl -xeu containerd
        exit 1
    fi
}

# Setup Docker
setup_docker() {
    echo "Setting up Docker..."
    mkdir -p /etc/docker
    
    # Basic Docker configuration
    cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

    # Start Docker
    systemctl daemon-reload
    systemctl restart docker
    systemctl enable docker
    
    # Verify Docker is running
    local retry_count=0
    while ! docker info >/dev/null 2>&1; do
        if [ $retry_count -ge 5 ]; then
            echo "Error: Docker failed to start. Checking logs..."
            journalctl -xeu docker
            exit 1
        fi
        retry_count=$((retry_count+1))
        sleep 5
    done
}

# Disable swap
disable_swap() {
    echo "Disabling swap..."
    swapoff -a
    sed -i '/swap/d' /etc/fstab
    
    if swapon --show; then
        echo "Error: Failed to disable swap"
        exit 1
    fi
}

# Main execution
echo "Starting node configuration..."

# Check prerequisites
check_disk_space

# Clean up existing installations
cleanup_docker

# Setup components
setup_kernel_modules
configure_sysctl
setup_containerd
setup_docker
disable_swap

# Hold Kubernetes packages
apt-mark hold kubelet kubeadm kubectl

# Verify kubelet
systemctl enable kubelet
systemctl start kubelet

if ! systemctl is-active --quiet kubelet; then
    echo "Error: Kubelet service failed to start"
    journalctl -xeu kubelet
    exit 1
fi

echo "Node configuration completed successfully!"
echo "Docker version: $(docker --version)"
echo "Containerd version: $(containerd --version)"
echo "Kernel version: $(uname -r)"
echo "You can now proceed with cluster initialization or joining."