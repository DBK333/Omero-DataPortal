sudo hostnamectl set-hostname worker01
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

sudo systemctl stop apparmor && sudo systemctl disable apparmor
sudo systemctl restart containerd.service

