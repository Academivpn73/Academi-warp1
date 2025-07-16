#!/bin/bash

# Version Info
VERSION="1.7.3"

# Color Codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Directories
PROXY_FILE="$HOME/.telegram_proxies.txt"
INSTALLER_PATH="$HOME/warp.sh"

# Title Banner
clear
echo -e "${BLUE}=============================================="
echo -e "${CYAN}Telegram: @Academi_vpn"
echo -e "${GREEN}Admin: @MahdiAGM0"
echo -e "${YELLOW}Version: ${VERSION}"
echo -e "${BLUE}==============================================${NC}"

# Install dependencies
install_requirements() {
  pkgs=(curl jq wget)
  for pkg in "${pkgs[@]}"; do
    if ! command -v $pkg &> /dev/null; then
      echo -e "${YELLOW}Installing $pkg...${NC}"
      pkg install $pkg -y > /dev/null 2>&1
    fi
  done
}

# WARP IP Scanner
warp_scanner() {
  echo -e "${CYAN}Scanning working WARP IPs...${NC}"
  count=1
  for i in {1..10}; do
    ip=$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1)
    port=$(shuf -i 1000-9000 -n 1)
    ping=$(ping -c1 -W1 "$ip" 2>/dev/null | grep time= | awk -F"time=" '{print $2}' | cut -d' ' -f1)
    if [ -z "$ping" ]; then
      ping="Timeout"
    fi
    echo -e "${GREEN}IP $count:${NC} $ip:$port - ${YELLOW}Ping:${NC} $ping ms"
    ((count++))
  done
}

# Load Telegram Proxies from file
telegram_proxies() {
  echo -e "${CYAN}Fetching Telegram proxies...${NC}"
  if [[ -f "$PROXY_FILE" ]]; then
    index=1
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      echo -e "${GREEN}Proxy $index:${NC} $line"
      ((index++))
    done < "$PROXY_FILE"
  else
    echo -e "${RED}❌ No proxy file found. Please add proxies manually.${NC}"
  fi
}

# Add proxy manually
add_proxy_manually() {
  echo -e "${CYAN}Paste your Telegram proxy link (https://t.me/proxy?...):${NC}"
  read -r proxy
  echo "$proxy" >> "$PROXY_FILE"
  echo -e "${GREEN}✅ Proxy added successfully!${NC}"
}

# Enable installer
enable_installer() {
  cp "$0" "$INSTALLER_PATH"
  chmod +x "$INSTALLER_PATH"
  echo -e "${GREEN}✅ Installer enabled at $INSTALLER_PATH${NC}"
}

# Disable installer
disable_installer() {
  rm -f "$INSTALLER_PATH"
  echo -e "${YELLOW}⚠️ Installer removed.${NC}"
}

# Main Menu
while true; do
  echo -e "\n${BLUE}=============== Menu ===============${NC}"
  echo -e "${CYAN}1) Warp IP Scanner"
  echo -e "2) Show Telegram Proxies"
  echo -e "3) Add Telegram Proxy"
  echo -e "4) Enable Installer"
  echo -e "5) Disable Installer"
  echo -e "6) Exit${NC}"
  echo -ne "${YELLOW}Choose an option: ${NC}"
  read -r option

  case "$option" in
    1) warp_scanner ;;
    2) telegram_proxies ;;
    3) add_proxy_manually ;;
    4) enable_installer ;;
    5) disable_installer ;;
    6) echo -e "${RED}Goodbye!${NC}"; exit ;;
    *) echo -e "${RED}Invalid option!${NC}" ;;
  esac
done
