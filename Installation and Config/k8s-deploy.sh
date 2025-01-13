#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root"
   exit 1
fi

echo "Starting Kubernetes Node Configuration..."

# Clean up any previous CNI configurations
rm -rf /etc/cni/net.d/*

# Verify required packages
for pkg in docker kubelet kubeadm kubectl; do
    if ! command -v $pkg &> /dev/null; then
        echo "Error: Required package $pkg is not installed"
        exit 1
    fi
done

# Stop and disable firewalld if it exists
if systemctl is-active --quiet firewalld; then
    systemctl stop firewalld
    systemctl disable firewalld
fi

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null
# Update containerd config to use SystemdCgroup
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Configure Docker daemon for Kubernetes
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# Restart Docker to apply configurations
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

if ! systemctl is-active --quiet docker; then
    echo "Error: Docker service failed to restart"
    exit 1
fi

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Verify swap is disabled
if swapon --show; then
    echo "Error: Failed to disable swap"
    exit 1
fi

# Load required Kubernetes modules
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Verify modules are loaded
if ! lsmod | grep -q "^overlay" || ! lsmod | grep -q "^br_netfilter"; then
    echo "Error: Failed to load required kernel modules"
    exit 1
fi

# Configure sysctl parameters for Kubernetes
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

# Hold Kubernetes packages to prevent unintended upgrades
apt-mark hold kubelet kubeadm kubectl

# Reset any existing kubeadm configuration
kubeadm reset -f || true

# Enable and start kubelet service
systemctl enable kubelet
systemctl start kubelet

if ! systemctl is-active --quiet kubelet; then
    echo "Error: Kubelet service failed to start"
    exit 1
fi

echo "Kubernetes Node Configuration Complete!"
echo "You can now run 'k8s-init-master.sh' on the master node or join worker nodes to the cluster."