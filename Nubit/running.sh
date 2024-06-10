#!/bin/bash

# Install dos2unix
sudo apt-get update
sudo apt-get install -y dos2unix

# Download the light-nodes.sh script
wget https://raw.githubusercontent.com/dipdown/Node-Crypto/main/light-nodes.sh -O light-nodes.sh

# Convert the script to Unix line endings
dos2unix light-nodes.sh

# Make the script executable
chmod +x light-nodes.sh

# Run the script
./light-nodes.sh
