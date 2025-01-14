# Enable UFW
sudo ufw enable

# Allow Kubelet API
sudo ufw allow 10250/tcp
echo "Enabled Kubelet API port (TCP 10250)"

# Allow NodePort Services
sudo ufw allow 30000:32767/tcp
echo "Enabled NodePort Services range (TCP 30000-32767)"

# Allow Flannel VXLAN overlay network
sudo ufw allow 8472/udp
echo "Enabled Flannel VXLAN overlay network port (UDP 8472)"

# Reload and check status
sudo ufw reload
sudo ufw status

# Port check
echo "Checking required ports..."
required_ports=(10250 30000 32767 8472)
for port in "${required_ports[@]}"; do
    if ! ss -tuln | grep -q ":$port "; then
        echo "Required port $port is not open"
        exit 1
    else
        echo "Port $port is open"
    fi
done

echo "All required ports are open and properly configured"