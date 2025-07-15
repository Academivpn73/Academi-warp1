#!/bin/bash

# Colors
GRN="\e[32m"
RED="\e[31m"
YEL="\e[33m"
NC="\e[0m"

# Banner
banner() {
  clear
  echo -e "${GRN}╔═══════════════════════════════════════╗"
  echo -e "║  Telegram: @Academi_vpn  / Admin Support: @MahdiAGM0  ║"
  echo -e "╚═══════════════════════════════════════╝${NC}"
}

# WARP IP Scanner
warp_scanner() {
  banner
  echo -e "${YEL}Scanning WARP IPs (max 10)...${NC}"
  count=0
  while [ $count -lt 10 ]; do
    ip=$(curl -4 -s --connect-timeout 3 https://api.ipify.org)
    port=$(shuf -n 1 -e 80 443 2086 8443 8080)
    ping_ms=$(ping -c 1 -W 1 "$ip" | grep time= | sed -E 's/.*time=([0-9.]+).*/\1/')
    nc -z -w1 "$ip" "$port" >/dev/null 2>&1
    if [[ $? -eq 0 && $ping_ms != "" ]]; then
      echo -e "${GRN}$ip:$port  Ping: ${ping_ms}ms${NC}"
      ((count++))
    fi
  done
  echo ""
  read -p "Press Enter to return to menu..."
}

# Telegram Proxy Viewer
telegram_proxy() {
  banner
  echo -e "${YEL}Telegram Proxy List:${NC}"
  echo ""
  
  # 👇 Add your proxies manually here
  echo -e "${GRN}1. tg://proxy?server=1.1.1.1&port=443&secret=ee00000000000000000000000000000000000000"
  echo -e "2. tg://proxy?server=2.2.2.2&port=443&secret=ee00000000000000000000000000000000000000${NC}"
  echo ""
  echo -e "${YEL}Update this list inside the script manually.${NC}"
  echo ""
  read -p "Press Enter to return to menu..."
}

# Menu
main_menu() {
  while true; do
    banner
    echo -e "${GRN}Select an option:${NC}"
    echo "1) WARP IP Scanner"
    echo "2) Telegram Proxy List"
    echo "0) Exit"
    echo ""
    read -p "Choice: " choice
    case $choice in
      1) warp_scanner ;;
      2) telegram_proxy ;;
      0) exit ;;
      *) echo -e "${RED}Invalid option.${NC}" && sleep 1 ;;
    esac
  done
}

main_menu
