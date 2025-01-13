#!/bin/bash
set -euo pipefail

# Check if running with sudo/root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

echo "Starting Kubernetes Node Configuration..."

# Remove any old versions of containerd
apt-get remove -y containerd containerd.io

# Install containerd
apt-get update
apt-get install -y containerd

# Create default containerd configuration
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Update containerd configuration to use systemd cgroup driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart and enable containerd
systemctl restart containerd
systemctl enable containerd

# Configure Docker daemon for Kubernetes
mkdir -p /etc/docker
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
systemctl daemon-reload
systemctl restart docker

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Load required Kubernetes modules
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Configure sysctl parameters for Kubernetes
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

# Reset any previous Kubernetes configuration (if any)
kubeadm reset -f

# Hold Kubernetes packages to prevent unintended upgrades
apt-mark hold kubelet kubeadm kubectl

# Enable kubelet service
systemctl enable --now kubelet

echo "Kubernetes Node Configuration Complete!"
echo "You can now run 'k8s-init-master.sh' on the master node or join worker nodes to the cluster."