#!/usr/bin/env bash
set -euo pipefail

# Version pinning for components
DOCKER_VERSION="24.0.7"
KUBECTL_VERSION="1.28.0"
HELM_VERSION="3.13.3"
UBUNTU_VERSION="$(lsb_release -rs)"

###############################################################################
# INSTALLATION FUNCTIONS
###############################################################################

# Function to validate system requirements
validate_system() {
    echo "Validating system requirements..."
    
    # Check Ubuntu version
    if (( $(echo "$UBUNTU_VERSION < 20.04" | bc -l) )); then
        echo "Error: Ubuntu version must be 20.04 or higher"
        exit 1
    fi

    # Check memory
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    if (( TOTAL_MEM < 4096 )); then
        echo "Warning: System has less than 4GB RAM. This might affect performance."
    fi
}

# Function to install system dependencies
install_dependencies() {
    echo "Installing system dependencies..."
    sudo apt-get update -y
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gpg \
        lsb-release \
        software-properties-common \
        git \
        bc \
        jq \
        wget \
        openssh-server \
        net-tools

    # Install yq
    install_yq
}

# Function to install yq
install_yq() {
    echo "Installing yq..."
    if ! command -v yq &> /dev/null; then
        sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
        sudo chmod +x /usr/bin/yq
    fi
    
    if ! yq --version &> /dev/null; then
        echo "Error: yq installation failed"
        exit 1
    fi
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    if ! command -v docker &> /dev/null; then
        # Remove any old versions
        sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
        
        # Clean up any old Docker files
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
        
        # Add Docker's official GPG key
        sudo apt-get update
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        
        # Add Docker repository
        echo \
            "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt-get update -y
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    # Add current user to docker group if needed
    if ! groups | grep -q docker; then
        echo "Adding user to docker group..."
        sudo groupadd -f docker
        sudo usermod -aG docker $USER
        
        # Start and enable Docker service
        sudo systemctl start docker
        sudo systemctl enable docker

        echo "Docker group changes require a new session."
        echo "Please run: 'exec su -l $USER' and then run this script again."
        exit 0
    fi
}

# Function to backup existing Kubernetes configuration
backup_k8s_config() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Backup and remove old kubernetes.list file
    if [ -f /etc/apt/sources.list.d/kubernetes.list ]; then
        echo "Backing up existing Kubernetes repository configuration..."
        sudo cp /etc/apt/sources.list.d/kubernetes.list "/etc/apt/sources.list.d/kubernetes.list.backup_${timestamp}"
        sudo rm -f /etc/apt/sources.list.d/kubernetes.list
    fi
    
    # Backup and remove old keyring files
    for keyring in "/etc/apt/keyrings/kubernetes-apt-keyring.gpg" "/usr/share/keyrings/kubernetes-archive-keyring.gpg"; do
        if [ -f "$keyring" ]; then
            echo "Backing up existing Kubernetes keyring: $keyring"
            sudo cp "$keyring" "${keyring}.backup_${timestamp}"
            sudo rm -f "$keyring"
        fi
    done
}

# Function to install Kubernetes components
install_kubernetes() {
    echo "Installing Kubernetes components..."

    # Backup and remove old configuration
    backup_k8s_config
    
    # Create keyrings directory if it doesn't exist
    sudo mkdir -p -m 755 /etc/apt/keyrings
    
    # Calculate major.minor version from KUBECTL_VERSION
    K8S_MINOR_VERSION=$(echo "$KUBECTL_VERSION" | cut -d. -f1,2)
    
    # Download and add the GPG key for the new community repository
    echo "Adding Kubernetes signing key from pkgs.k8s.io..."
    curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR_VERSION}/deb/Release.key" \
        | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    
    # Add the new repository
    echo "Adding Kubernetes repository from pkgs.k8s.io..."
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR_VERSION}/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list
    
    # Install Kubernetes components
    sudo apt-get update -y
    
    if [ -z "${KUBECTL_VERSION}" ]; then
        # Install latest stable from the selected minor version
        sudo apt-get install -y kubelet kubeadm kubectl
    else
        # Try to install specific version
        local PACKAGE_VERSION="${KUBECTL_VERSION}-1.1"  # Adjust version string format if needed
        if apt-cache madison kubectl | grep -q "$PACKAGE_VERSION"; then
            sudo apt-get install -y \
                kubelet="${PACKAGE_VERSION}" \
                kubeadm="${PACKAGE_VERSION}" \
                kubectl="${PACKAGE_VERSION}"
        else
            echo "Warning: Specific version ${PACKAGE_VERSION} not found. Installing latest available in v${K8S_MINOR_VERSION}"
            sudo apt-get install -y kubelet kubeadm kubectl
        fi
    fi
    
    sudo apt-mark hold kubelet kubeadm kubectl
    
    # Enable kubelet service
    sudo systemctl enable --now kubelet
    
    echo "Kubernetes components installed from pkgs.k8s.io community repository"
}

# Function to install Helm
install_helm() {
    echo "Installing Helm version ${HELM_VERSION}..."
    if ! command -v helm &> /dev/null; then
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        DESIRED_VERSION="v${HELM_VERSION}" ./get_helm.sh
        rm get_helm.sh
    fi
}

# Function to add required Helm repositories
add_helm_repos() {
    echo "Adding Helm repositories..."
    helm repo add omero https://www.manicstreetpreacher.co.uk/kubernetes-omero/
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
}

###############################################################################
# MAIN INSTALLATION PROCESS
###############################################################################

main() {
    echo "Starting installation process..."
    
    # Validate system requirements
    validate_system
    
    # Install dependencies
    install_dependencies
    
    # Install and configure Docker
    install_docker
    
    # Check if Docker is properly configured
    if ! groups | grep -q docker || ! docker ps >/dev/null 2>&1; then
        echo "Docker is not properly configured. Please run 'exec su -l $USER' and then run this script again."
        exit 1
    fi
    
    # Install components
    install_kubernetes
    install_helm
    
    # Add Helm repositories
    add_helm_repos
    
    echo "Installation complete!"
    echo "Kubernetes components installed:"
    kubectl version --client
    echo "Helm version installed:"
    helm version
    
    echo "You can now proceed with cluster initialization using kubeadm"
}

# Run main function
main