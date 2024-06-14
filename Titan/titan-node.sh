#!/bin/bash

# Function to display the logo
display_logo() {
  echo -e "\e[1;32m

          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⠿⠛⠉⠉⠉⠛⠿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠉⠉⠛⠿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⠁⠀⢀⣴⣶⣦⣄⡀⠀⠙⠻⠟⠋⠀⢀⣠⣴⣶⣦⡀⠀⠈⣿⣿⣿⣿
          ⣿⣿⣿⡇⠀⠀⣿⣿⣿⣿⣿⣿⠶⠀⠀⠀⠀⠶⣿⣿⣿⣿⣿⣿⠀⠀⢸⣿⣿⣿
          ⣿⣿⣿⣿⡀⠀⠈⠻⠿⠟⠋⠁⠀⣠⣴⣦⣄⠀⠈⠙⠻⠿⠟⠁⠀⢀⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣶⣤⣀⣀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣶⣤⣀⣀⣀⣤⣶⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          \e[0m"
  echo -e "                   \033[48;2;9;10;12m Node Titan \e[0m"
  echo -e "\e[0;37m           Telegram : \e[4;35mhttps://t.me/eevrxx/"
  echo -e "\e[0m"
  echo -e ""
  echo -e ""
}

# Function to handle the spinner
spinner() {
  task=$1
  msg=$2
  tput civis
  while :; do
    jobs %1 > /dev/null 2>&1
    [ $? = 0 ] || {
      printf "\e[2K✓ ${task} Done\n"
      break
    }
    for (( i=0; i<${#SPINNER}; i++ )); do
      sleep 0.05
      printf "\e[2K${SPINNER:$i:1} ${task} ${msg}\r"
    done
  done
  tput cnorm
}

# Spinner Character
SPINNER="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

# Display the logo
display_logo

echo "Wait for Node..."
sleep 5

# Install screen and Titan node
sudo apt update
sudo apt install -y screen

wget https://github.com/Titannet-dao/titan-node/releases/download/v0.1.16/titan_v0.1.16_linux_amd64.tar.gz
tar xf titan_v0.1.16_linux_amd64.tar.gz
cd titan_v0.1.16_linux_amd64

./titan-edge daemon start --init --url https://test-locator.titannet.io:5000/rpc/v0

echo "Waiting for task completion... Press Ctrl+C when done."

read -p "Masukkan Hash: " hash_value

./titan-edge bind --hash="$hash_value" https://api-test1.container1.titannet.io/api/v2/device/binding

./titan-edge config set --storage-size 100GB

nohup ./titan-edge daemon start --init --url https://test-locator.titannet.io:5000/rpc/v0 > edge.log 2>&1 &

echo "Script Execution Completed Successfully."
