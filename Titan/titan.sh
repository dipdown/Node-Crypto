#!/bin/bash

# Function to display colored text
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo -e "${YELLOW}This script requires root access.${NC}"
    echo -e "${YELLOW}Please enter root mode using 'sudo -i', then rerun this script.${NC}"
    exec sudo -i
    exit 1
fi

# Prompt the user to enter the identity code
echo -e "${GREEN}Running Titan_edge Node"
echo -e "${YELLOW}Enter your identity code:${NC}"
read -p "> " id
# Prompt the user to enter the number of containers to create
read -p "Enter the number of nodes you want to create (a maximum of 5 nodes per IP): " container_count
# Prompt the user to enter the storage size for each node
read -p "Enter the storage size for each node (GB), maximum of 2TB/node (2000GB): " storage_gb
# Prompt the user to specify a storage path (optional)
read -p "Enter the data storage path for the node on the server, e.g., /root/mnt_d/: " custom_storage_path

# Storage and port settings
start_port=1235

# Get the list of public IPs
public_ips=$(curl -s ifconfig.me)

if [ -z "$public_ips" ]; then
    echo -e "${YELLOW}No public IP detected.${NC}"
    exit 1
fi

# Define a function to update sysctl configuration
update_sysctl_config() {
    # Define the configuration values
    local CONFIG_VALUES="
net.core.rmem_max=26214400
net.core.rmem_default=26214400
net.core.wmem_max=26214400
net.core.wmem_default=26214400
"

    # Path to the sysctl configuration file
    local SYSCTL_CONF="/etc/sysctl.conf"

    # Backup the original sysctl.conf file
    echo "Backing up the original sysctl.conf to sysctl.conf.bak..."
    sudo cp "$SYSCTL_CONF" "$SYSCTL_CONF.bak"

    # Append the configuration values to sysctl.conf
    echo "Updating sysctl.conf with new configuration values..."
    echo "$CONFIG_VALUES" | sudo tee -a "$SYSCTL_CONF" > /dev/null

    # Apply the changes
    echo "Applying the new sysctl configuration..."
    sudo sysctl -p

    echo "Configuration updated and applied successfully."

    # Check if SELinux is present and handle accordingly
    if command -v setenforce &> /dev/null; then
        echo "Disabling SELinux enforcement..."
        sudo setenforce 0
    else
        echo "SELinux is not installed or not applicable."
    fi
}

# Function to install Docker based on the distribution
install_docker() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo -e "${GREEN}Installing Docker on $ID...${NC}"
                apt-get update
                apt-get install -y ca-certificates curl gnupg lsb-release
                apt-get install -y docker.io
                ;;
            centos|rhel|almalinux|rocky)
                echo -e "${GREEN}Installing Docker on $ID...${NC}"
                yum install -y yum-utils
                yum install -y docker
                update_sysctl_config
                ;;
            fedora)
                echo -e "${GREEN}Installing Docker on Fedora...${NC}"
                dnf install -y docker
                update_sysctl_config
                ;;
            arch)
                echo -e "${GREEN}Installing Docker on Arch Linux...${NC}"
                pacman -S --noconfirm docker
                ;;
            *)
                echo -e "${YELLOW}Unsupported Linux distribution: $ID. Please install Docker manually.${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${YELLOW}Cannot detect Linux distribution. Please install Docker manually.${NC}"
        exit 1
    fi
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker not detected, installing...${NC}"
    install_docker
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

# Ensure Docker is running
systemctl start docker
systemctl enable docker

# Pull the Docker image
echo -e "${GREEN}Pulling the Docker image nezha123/titan-edge...${NC}"
docker pull nezha123/titan-edge

# Set up nodes for each public IP
current_port=$start_port

for ip in $public_ips; do
    echo -e "${GREEN}Setting up node for IP $ip${NC}"

    for ((i=1; i<=container_count; i++)); do
        storage_path="${custom_storage_path}/titan_storage_${ip}_${i}"

        # Ensure storage path exists
        sudo mkdir -p "$storage_path"
        sudo chmod -R 777 "$storage_path"

        # Run the container with restart always policy
        container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan_${ip}_${i}" --net=host nezha123/titan-edge)

        echo -e "${GREEN}Node titan_${ip}_${i} is running with container ID $container_id${NC}"

        sleep 30

        # Modify the config.toml file to set StorageGB and RPC port
        docker exec $container_id bash -c "\
            sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
            sed -i 's/^[[:space:]]*#ListenAddress = \"0.0.0.0:1234\"/ListenAddress = \"0.0.0.0:$current_port\"/' /root/.titanedge/config.toml && \
            echo 'Storage for node titan_${ip}_${i} set to $storage_gb GB, Port set to $current_port'"

        # Restart the container for the settings to take effect
        docker restart $container_id

        # Bind the node
        docker exec $container_id bash -c "\
            titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
        echo -e "${GREEN}Node titan_${ip}_${i} has been successfully initialized.${NC}"

        current_port=$((current_port + 1))
    done
done

echo -e "${GREEN}============================== All nodes have been set up and are running ===============================${NC}"
