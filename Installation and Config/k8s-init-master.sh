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

# Replace <MASTER_IP_OR_FQDN> with a resolvable address or hostname
CONTROL_PLANE_ENDPOINT="<MASTER_IP_OR_FQDN>"

# Initialize the control plane
kubeadm init \
  --pod-network-cidr="${POD_NETWORK_CIDR}" \
  --control-plane-endpoint="${CONTROL_PLANE_ENDPOINT}"

# Copy kubeconfig to the calling user's home directory
USER_HOME=$(eval echo ~${SUDO_USER})
mkdir -p "${USER_HOME}/.kube"
cp -i /etc/kubernetes/admin.conf "${USER_HOME}/.kube/config"
chown "$(id -u ${SUDO_USER}):$(id -g ${SUDO_USER})" "${USER_HOME}/.kube/config"

# Use the cluster's admin kubeconfig to apply resources
# (explicit --kubeconfig to avoid localhost:8080 error)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
# Remove control-plane taint to allow pods on master node (optional)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "Master Node Initialization Complete!"
echo "Use the generated 'kubeadm join' command to join workers."
echo "To view cluster status, run either:"
echo "  export KUBECONFIG=/etc/kubernetes/admin.conf && kubectl get nodes"
echo "OR"
echo "  kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes"
