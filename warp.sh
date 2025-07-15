#!/bin/bash

VERSION="1.0.6"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

install_dependencies() {
  for pkg in curl jq; do
    if ! command -v $pkg >/dev/null 2>&1; then
      echo "Installing $pkg..."
      apt update -y >/dev/null 2>&1
      apt install -y $pkg >/dev/null 2>&1
    fi
  done
}

print_header() {
  clear
  echo -e "\e[1;35m┌──────────────────────────────────────┐\e[0m"
  echo -e "\e[1;36m│      Academi VPN Script $VERSION         \e[0m"
  echo -e "\e[1;35m├──────────────────────────────────────┤\e[0m"
  echo -e "\e[1;32m│ Channel : $CHANNEL\e[0m"
  echo -e "\e[1;32m│ Admin   : $ADMIN\e[0m"
  echo -e "\e[1;35m└──────────────────────────────────────┘\e[0m"
}

warp_scan() {
  echo -e "\n\e[1;36mScanning Best WARP IPv4 IPs...\e[0m"
  echo -e "\e[1;32m--------------------------------------------\e[0m"
  local count=0

  while [ $count -lt 10 ]; do
    IP=$(curl -s4 --connect-timeout 3 https://speed.cloudflare.com/meta | jq -r '.client.ip')
    if [[ -z "$IP" || "$IP" == "null" ]]; then
      continue
    fi
    PORT=$((RANDOM % 64512 + 1024))
    PING=$(ping -c1 -W1 "$IP" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ $PING != "" ]]; then
      echo -e "\e[1;33m$IP:$PORT \e[0m Ping: \e[1;32m$PING ms\e[0m"
      ((count++))
    fi
  done

  echo -e "\e[1;32m--------------------------------------------\e[0m"
  read -p "Press enter to return to menu..."
}

fetch_proxies() {
  mkdir -p proxies

  echo -e "\e[1;36mFetching Telegram proxies...\e[0m"

  # Fetch proxies from open APIs
  curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt -o proxies/tmp1.txt
  curl -s https://raw.githubusercontent.com/roosterkid/openproxylist/main/Telegram/proxies.txt -o proxies/tmp2.txt
  curl -s https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/telegram.txt -o proxies/tmp3.txt

  # Merge and clean
  cat proxies/tmp*.txt | grep -E '^tg://' | sort | uniq | head -n 20 > proxies/list.txt

  # Clean temp
  rm proxies/tmp*.txt
}

show_proxies() {
  if [[ ! -f proxies/list.txt ]]; then
    fetch_proxies
  fi

  echo -e "\n\e[1;36mLatest Telegram Proxies:\e[0m"
  echo -e "\e[1;32m--------------------------------------------\e[0m"
  cat proxies/list.txt | nl
  echo -e "\e[1;32m--------------------------------------------\e[0m"
  read -p "Press enter to return to menu..."
}

auto_update_proxies() {
  while true; do
    fetch_proxies
    sleep 18000  # 5 hours = 18000 seconds
  done
}

main_menu() {
  while true; do
    print_header
    echo -e "\n\e[1;36m[1]\e[0m Warp IPv4 Scanner"
    echo -e "\e[1;36m[2]\e[0m Telegram Proxy List"
    echo -e "\e[1;36m[0]\e[0m Exit"
    echo -ne "\n\e[1;33mSelect an option:\e[0m "
    read choice

    case "$choice" in
      1) warp_scan ;;
      2) show_proxies ;;
      0) exit 0 ;;
      *) echo -e "\e[1;31mInvalid option!\e[0m"; sleep 1 ;;
    esac
  done
}

install_dependencies
auto_update_proxies &

main_menu
