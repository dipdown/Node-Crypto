#!/bin/bash

curl -s https://raw.githubusercontent.com/dipdown/Node-Crypto/refs/heads/main/logo.sh | bash
sleep 5

# Logging Function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Error Handling Function
error_exit() {
    log "🔥 ERROR: $1"
    exit 1
}

# Validate Root Access
if [[ $EUID -ne 0 ]]; then
   error_exit "❌ THIS SCRIPT MUST BE RUN AS ROOT OR WITH SUDO"
fi

# Advanced Firewall Configuration
log "🔒 CONFIGURING FIREWALL"
# Disable and reset UFW first to prevent conflicts
ufw disable   
ufw reset -y  
ufw default deny incoming  
ufw default allow outgoing  
ufw allow ssh  
ufw allow 3389/tcp  # RDP Port  
echo "y" | ufw enable || error_exit "❌ FAILED TO ENABLE FIREWALL"

# Start logging
log "🚀 STARTING DOCKER AND XRDP INSTALLATION SCRIPT"

# Update system packages with error checking
log "📦 UPDATING SYSTEM PACKAGES"
apt update || error_exit "❌ FAILED TO UPDATE PACKAGES"
apt upgrade -y || error_exit "❌ FAILED TO UPGRADE PACKAGES"

# Install required dependencies
log "🔧 INSTALLING REQUIRED DEPENDENCIES"
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    xfce4 \
    xfce4-goodies \
    gdebi \
    wget \
    unzip \
    || error_exit "❌ FAILED TO INSTALL DEPENDENCIES"

# Docker Installation
log "🐳 ADDING DOCKER GPG KEY"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

log "📂 ADDING DOCKER REPOSITORY"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

log "🔄 UPDATING PACKAGE INDEX"
apt update || error_exit "❌ FAILED TO UPDATE PACKAGE INDEX"

log "🐳 INSTALLING DOCKER"
apt install -y docker-ce docker-ce-cli containerd.io || error_exit "❌ DOCKER INSTALLATION FAILED"

# XRDP Configuration
log "🖥️ INSTALLING XRDP"
apt install -y xrdp || error_exit "❌ XRDP INSTALLATION FAILED"

# Configure XRDP for Xfce
echo "xfce4-session" > /root/.xsession

# Enable and start XRDP service
log "✅ ENABLING AND STARTING XRDP SERVICE"
systemctl enable xrdp
systemctl restart xrdp || error_exit "❌ FAILED TO START XRDP SERVICE"

# OpenLedger Node Installation Function
install_openledger_node() {
    # Change to home directory
    cd ~

    # Log download attempt
    log "📥 DOWNLOADING OPENLEDGER NODE PACKAGE"
    wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip || error_exit "❌ FAILED TO DOWNLOAD OPENLEDGER NODE PACKAGE"

    # Log extraction
    log "📂 EXTRACTING OPENLEDGER NODE PACKAGE"
    unzip openledger-node-1.0.0-linux.zip || error_exit "❌ FAILED TO EXTRACT OPENLEDGER NODE PACKAGE"

    # Find the .deb file
    DEB_FILE=$(find . -name "*.deb" | head -n 1)
    
    if [ -z "$DEB_FILE" ]; then
        error_exit "❌ NO .DEB PACKAGE FOUND IN THE EXTRACTED FILES"
    fi

    # Log installation of .deb package
    log "⚙️ INSTALLING OPENLEDGER NODE .DEB PACKAGE"
    dpkg -i "$DEB_FILE" || error_exit "❌ FAILED TO INSTALL OPENLEDGER NODE PACKAGE"

    # Ensure all dependencies are met
    log "🔄 FIXING ANY POTENTIAL DEPENDENCY ISSUES"
    apt-get install -f -y || error_exit "❌ FAILED TO RESOLVE DEPENDENCIES"

    # Log successful installation
    log "✅ OPENLEDGER NODE PACKAGE INSTALLED SUCCESSFULLY"
}

# Get IP Address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Final success log
log "🎉 INSTALLATION COMPLETE!"
echo "===== NEXT STEPS ====="
echo "1. Login RDP:"
echo "   - IP: $IP_ADDRESS"
echo "   - Username: root"
echo "   - Password: Your VPS Root Password"
echo ""
echo "2. Download OpenLedger Node Package: Run in Terminal"
echo "   wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip"
echo ""
echo "3. Extract and Install Package:"
echo "   - Unzip the package"
echo "   - Install .deb package"
echo ""
echo "4. Run OpenLedger Node: Run in Terminal"
echo "   openledger-node --no-sandbox"
echo ""
echo "5. Follow Prompts to Setup Node"
echo ""
echo "6. Firewall Status:"
ufw status
echo ""
echo "7. Recommended: Review and customize firewall rules"
echo "===== END OF INSTRUCTIONS ====="

# Optionally, uncomment the following line to automatically install OpenLedger Node
# install_openledger_node

# Log the end of script execution
log "✅ SCRIPT EXECUTION COMPLETED"
