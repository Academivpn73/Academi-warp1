#!/bin/bash

#====================[ Basic Info ]====================#
VERSION="1.0.0"
CHANNEL="@Academi_vpn"
SUPPORT="@MahdiAGM0"

#===================[ Print Header ]===================#
print_header() {
  clear
  echo -e "\e[92m"
  echo "╔════════════════════════════════════════════════╗"
  echo "║              Academi VPN Tool                 ║"
  echo "║               Version: ${VERSION}                 ║"
  echo "╠════════════════════════════════════════════════╣"
  echo "║ Telegram Channel : ${CHANNEL}                  ║"
  echo "║ Support         : ${SUPPORT}                   ║"
  echo "╚════════════════════════════════════════════════╝"
  echo -e "\e[0m"
}

#=================[ Install Dependencies ]================#
install_dependencies() {
  echo "🔧 Installing required packages..."
  apt update -y >/dev/null 2>&1
  apt install curl wget jq net-tools iproute2 wireguard-tools ping -y >/dev/null 2>&1

  if ! command -v warp-cli >/dev/null 2>&1; then
    echo "📦 Installing Cloudflare WARP..."
    curl -fsSL https://pkg.cloudflareclient.com/install.sh | bash >/dev/null 2>&1
    apt install cloudflare-warp -y >/dev/null 2>&1
  fi
}

#===================[ WARP IP Scanner ]==================#
warp_ip_scanner() {
  print_header
  echo -e "🌐 Scanning best WARP IPv4 IPs...\n"

  mkdir -p warp_tmp
  > warp_tmp/valid_ips.txt

  for i in {1..100}; do
    ip=$(curl -s https://api64.ipify.org)
    [[ -z "$ip" ]] && continue

    port=$((RANDOM % 64512 + 1024)) # Random high port
    ping_result=$(ping -c1 -W1 "$ip" | grep "time=" | awk -F"time=" '{print $2}' | cut -d" " -f1)

    if [[ -n "$ping_result" ]]; then
      echo "$ip:$port  ${ping_result}ms" >> warp_tmp/valid_ips.txt
    fi

    [[ $(wc -l < warp_tmp/valid_ips.txt) -ge 10 ]] && break
  done

  if [[ -s warp_tmp/valid_ips.txt ]]; then
    echo -e "\n✅ Found working IPs:\n"
    cat warp_tmp/valid_ips.txt
  else
    echo "❌ No working IPs found."
  fi

  rm -rf warp_tmp
  echo
  read -p "Press Enter to return to menu..."
}

#====================[ Telegram Proxy ]====================#
telegram_proxy() {
  print_header
  echo "🌐 Fetching fresh Telegram proxies..."

  proxies=$(curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt | head -n 10)

  if [[ -z "$proxies" ]]; then
    echo "❌ Failed to fetch proxies."
  else
    echo -e "\n🧩 Available Telegram Proxies:\n"
    i=1
    while IFS= read -r proxy; do
      echo "$i. tg://proxy?server=$(echo "$proxy" | cut -d':' -f1)&port=$(echo "$proxy" | cut -d':' -f2)"
      ((i++))
    done <<< "$proxies"
  fi

  echo
  read -p "Press Enter to return to menu..."
}

#====================[ Main Menu ]====================#
main_menu() {
  while true; do
    print_header
    echo "1️⃣  WARP IP Scanner"
    echo "2️⃣  Telegram Proxy"
    echo "3️⃣  Exit"
    echo
    read -p "Select an option [1-3]: " choice
    case $choice in
      1) warp_ip_scanner ;;
      2) telegram_proxy ;;
      3) exit ;;
      *) echo "❌ Invalid option." ;;
    esac
  done
}

#====================[ Run Script ]====================#
install_dependencies
main_menu
