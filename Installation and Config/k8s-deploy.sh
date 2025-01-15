#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root"
   exit 1
fi

echo "Starting Kubernetes Node Configuration..."

# Verify required packages
if ! command -v docker &> /dev/null || ! command -v kubelet &> /dev/null || ! command -v kubeadm &> /dev/null; then
    echo "Error: Required packages (docker, kubelet, kubeadm) are not installed"
    exit 1
fi

# Configure Docker daemon for Kubernetes
if ! mkdir -p /etc/docker; then
    echo "Error: Failed to create Docker directory"
    exit 1
fi

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

if grep -q "[[:space:]]swap[[:space:]]" /etc/fstab; then
    echo "Error: Failed to remove swap entries from /etc/fstab"
    exit 1
fi

# Load required Kubernetes modules
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

if ! modprobe overlay || ! modprobe br_netfilter; then
    echo "Error: Failed to load required kernel modules"
    exit 1
fi

# Configure sysctl parameters for Kubernetes
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

# Hold Kubernetes packages to prevent unintended upgrades
apt-mark hold kubelet kubeadm kubectl

# Enable kubelet service
systemctl enable --now kubelet

if ! systemctl is-active --quiet kubelet; then
    echo "Error: Kubelet service failed to start"
    exit 1
fi

echo "Kubernetes Node Configuration Complete!"
echo "You can now run 'k8s-init-master.sh' on the master node or join worker nodes to the cluster."
