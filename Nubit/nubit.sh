#!/bin/bash

echo "Wait for Node..."

# Define the spinner function
function spinner() {
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
msg="${2-InProgress}"
task="${3-$1}"
$1 & spinner "$task" "$msg"

# Display the logo
echo -e "\e[1;32m

⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⠿⠛⠉⠉⠉⠛⠿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠉⠉⠛⠿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠁⠀⢀⣴⣶⣦⣄⡀⠀⠙⠻⠟⠋⠀⢀⣠⣴⣶⣦⡀⠀⠈⣿⣿⣿⣿
⣿⣿⣿⡇⠀⠀⣿⣿⣿⣿⣿⣿⠶⠀⠀⠀⠀⠶⣿⣿⣿⣿⣿⣿⠀⠀⢸⣿⣿⣿
⣿⣿⣿⣿⡀⠀⠈⠻⠿⠟⠋⠁⠀⣠⣴⣦⣄⠀⠈⠙⠻⠿⠟⠁⠀⢀⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣶⣤⣀⣀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣶⣤⣀⣀⣀⣤⣶⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿

";
echo -e "                 \033[48;2;9;10;12m Node Nubit \e[0m";
echo -e "\e[0;37m Telegram : \e[4;35mhttps://t.me/eevrxx/";
echo -e "\e[0m"
echo -e ""
echo -e ""

sleep 2

cd $HOME

sudo apt update
sudo apt --fix-broken install -y
sudo apt upgrade -y
sudo apt install -y tmux
sudo echo "deb http://security.ubuntu.com/ubuntu jammy-security main" >> /etc/apt/sources.list
sudo apt -qy update && sudo apt -qy install libc6

# rm -rf nubit-node $HOME/.nubit-light-nubit-alphatestnet-1
rm -rf nubit-node

tmux new -s nubit "curl -sL1 https://nubit.sh | bash"

echo "Script Execution Completed Successfully."
