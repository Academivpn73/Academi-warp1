#!/bin/bash

# Academi VPN Tool - Version 1.3.0
# Channel: @Academi_vpn
# Admin: @MahdiAGM0

VERSION="1.3.0"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[36m"
NC="\e[0m"

# Installer name
INSTALLER_NAME="Academivpn_warp"

# Auto install dependencies
install_dependencies() {
  echo -e "${YELLOW}[+] Installing required packages...${NC}"
  apt update -y &>/dev/null
  apt install -y curl jq netcat grep wget dnsutils &>/dev/null
}

# Show header
show_header() {
  clear
  echo -e "${BLUE}"
  echo "=============================================="
  echo "          Academi VPN Tool - v$VERSION        "
  echo "        Telegram Channel: $CHANNEL            "
  echo "             Admin: $ADMIN                   "
  echo "=============================================="
  echo -e "${NC}"
}

# WARP Scanner
warp_scanner() {
  show_header
  echo -e "${YELLOW}[+] Scanning best WARP IPv4 IPs...${NC}"
  sleep 1

  RANGE="162.159.{192..255}.{1..254}"
  PORTS=(80 443 8080 8443 2052 2082 2086 2095 2087 2096)

  count=0
  for ip in $(shuf -n 500 -e $(eval echo $RANGE)); do
    for port in "${PORTS[@]}"; do
      (timeout 1 bash -c "echo > /dev/tcp/$ip/$port") 2>/dev/null
      if [ $? -eq 0 ]; then
        PING=$(ping -c1 -W1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [[ $PING != "" ]]; then
          echo -e "${GREEN}IP:$ip:$port  Ping:${PING}ms${NC}"
          count=$((count + 1))
        fi
      fi
      [[ $count -ge 10 ]] && break 2
    done
  done

  if [[ $count -eq 0 ]]; then
    echo -e "${RED}[!] No working WARP IPs found.${NC}"
  fi

  echo ""
  read -p "Press Enter to return to menu..."
  main_menu
}

# Telegram Proxy
telegram_proxy() {
  show_header
  echo -e "${YELLOW}[+] Fetching fresh Telegram proxies...${NC}"
  sleep 1

  URLS=(
    "https://api.openproxylist.xyz/tg" 
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt"
  )

  proxies=()
  for url in "${URLS[@]}"; do
    resp=$(curl -s "$url")
    if [[ ! -z "$resp" ]]; then
      for line in $(echo "$resp"); do
        [[ $line == *":"* ]] && proxies+=("$line")
      done
    fi
  done

  if [ ${#proxies[@]} -eq 0 ]; then
    echo -e "${RED}[!] No proxies found.${NC}"
  else
    echo -e "${GREEN}[+] Showing up to 10 proxies:${NC}"
    for i in "${!proxies[@]}"; do
      echo "Proxy[$((i+1))]: tg://proxy?server=$(echo ${proxies[$i]} | cut -d':' -f1)&port=$(echo ${proxies[$i]} | cut -d':' -f2)"
      [[ $i -eq 9 ]] && break
    done
  fi

  echo ""
  read -p "Press Enter to return to menu..."
  main_menu
}

# Installer Manager
install_installer() {
  cp "$0" /data/data/com.termux/files/usr/bin/$INSTALLER_NAME
  chmod +x /data/data/com.termux/files/usr/bin/$INSTALLER_NAME
  echo -e "${GREEN}[+] Installer added. Run using '${INSTALLER_NAME}' command.${NC}"
  sleep 1
  main_menu
}

remove_installer() {
  rm -f /data/data/com.termux/files/usr/bin/$INSTALLER_NAME
  echo -e "${YELLOW}[-] Installer removed.${NC}"
  sleep 1
  main_menu
}

# Main Menu
main_menu() {
  show_header
  echo "1. WARP IPv4 Scanner"
  echo "2. Telegram Proxy List"
  echo "3. Install Installer"
  echo "4. Remove Installer"
  echo "0. Exit"
  echo ""
  read -p "Select an option: " opt

  case "$opt" in
    1) warp_scanner ;;
    2) telegram_proxy ;;
    3) install_installer ;;
    4) remove_installer ;;
    0) exit ;;
    *) echo "Invalid option."; sleep 1; main_menu ;;
  esac
}

# Run everything
install_dependencies
main_menu
