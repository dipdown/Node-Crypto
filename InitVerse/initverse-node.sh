#!/bin/bash

curl -s https://raw.githubusercontent.com/dipdown/Node-Crypto/refs/heads/main/logo.sh | bash
sleep 5

INIMINER_URL="https://github.com/Project-InitVerse/ini-miner/releases/download/v1.0.0/iniminer-linux-x64"

INIMINER_FILE="iniminer-linux-x64"

SCREEN_NAME="shareithub_initverse"

check_ram() {
    echo
    echo "========================================"
    echo "🧠 Checking system RAM..."
    echo "========================================"
    
    TOTAL_RAM=$(free -m | grep Mem: | awk '{print $2}')
    
    RAM_GB=$((TOTAL_RAM / 1024))
    
    echo "RAM detected! The system has ${RAM_GB} GB RAM."

    if [ $RAM_GB -ge 4 ]; then
        echo "✅ Sufficient RAM for mining."
    else
        echo "❌ Not enough RAM for optimal mining. It's recommended to have at least 4 GB of RAM."
        exit 1
    fi
    echo
}

update_system_and_install_screen() {
    echo
    echo "========================================"
    echo "🔄 Updating System & Installing Screen..."
    echo "========================================"
    sudo apt update && sudo apt upgrade -y
    sudo apt install screen -y
    if [ $? -eq 0 ]; then
        echo "✅ System updated and screen successfully installed."
    else
        echo "❌ Failed to update the system or install screen."
        exit 1
    fi
    echo
}

download_inichain() {
    echo
    echo "========================================"
    echo "⬇️  Downloading InitVerse Miner file..."
    echo "========================================"
    wget -q $INIMINER_URL -O $INIMINER_FILE
    if [ $? -eq 0 ]; then
        echo "✅ File downloaded successfully."
    else
        echo "❌ Failed to download the file. Check the URL or your internet connection."
        exit 1
    fi
    echo
}

give_permission() {
    echo
    echo "========================================"
    echo "🔑 Granting execute permissions to the file..."
    echo "========================================"
    chmod +x $INIMINER_FILE
    if [ $? -eq 0 ]; then
        echo "✅ Execute permissions granted successfully."
    else
        echo "❌ Failed to grant execute permissions."
        exit 1
    fi
    echo
}


run_inichain_miner() {
    echo
    echo "========================================"
    echo "🖥️ Running InitVerse Miner in screen..."
    echo "========================================"
    read -p "Enter your wallet address: " WALLET_ADDRESS
    read -p "Enter your Worker name (e.g., Worker001): " WORKER_NAME

    # Validate input
    if [[ -z "$WALLET_ADDRESS" || -z "$WORKER_NAME" ]]; then
        echo "❌ Wallet address or Worker name cannot be empty."
        exit 1
    fi

    POOL_URL="stratum+tcp://${WALLET_ADDRESS}.${WORKER_NAME}@pool-core-testnet.inichain.com:32672"

    screen -dmS $SCREEN_NAME ./$INIMINER_FILE --pool $POOL_URL
    if [ $? -eq 0 ]; then
        echo "✅ InitVerse Miner is now running in a screen session named '$SCREEN_NAME'."
        echo "ℹ️  Use the following command to monitor:"
        echo "   screen -r $SCREEN_NAME"
    else
        echo "❌ Failed to run InitVerse Miner."
        exit 1
    fi
    echo
}

check_ram

update_system_and_install_screen
download_inichain
give_permission
run_inichain_miner

echo
echo "========================================"
echo "🎉 Done! InitVerse Miner is set up and running."
echo "========================================"
