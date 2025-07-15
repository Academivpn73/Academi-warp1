#!/data/data/com.termux/files/usr/bin/bash

# Version
VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Channel Info
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

# Dependencies
install_dependencies() {
  for pkg in curl jq; do
    if ! command -v $pkg &>/dev/null; then
      echo -e "${YELLOW}Installing $pkg...${NC}"
      pkg install -y $pkg >/dev/null 2>&1
    fi
  done
}

# WARP IPv4 Scanner
warp_ipv4_scanner() {
  echo -e "${CYAN}\n🔍 Scanning best WARP IPv4 IPs (max 10)...${NC}"
  sleep 1

  count=0
  for i in {1..300}; do
    IP="162.159.$((RANDOM % 256)).$((RANDOM % 256))"
    PORT=$((RANDOM % 65535 + 1))
    ping_time=$(ping -c1 -W1 "$IP" 2>/dev/null | grep 'time=' | sed -n 's/.*time=\(.*\) ms/\1/p')
    if [[ -n "$ping_time" ]]; then
      echo -e "${GREEN}✔ $IP:$PORT  Ping: ${ping_time}ms${NC}"
      ((count++))
    fi
    [[ $count -ge 10 ]] && break
  done

  [[ $count -eq 0 ]] && echo -e "${RED}❌ No working IPv4 WARP IPs found.${NC}"
}

# Telegram Proxy Fetcher
telegram_proxy_fetcher() {
  echo -e "${CYAN}\n🌐 Fetching fresh Telegram proxies...${NC}"
  sleep 1

  response=$(curl -s https://t.me/s/proxy?before=999999)
  proxies=$(echo "$response" | grep -oE 'tg://proxy\?server=[^"]+' | head -n 10)

  if [[ -z "$proxies" ]]; then
    echo -e "${RED}❌ Failed to fetch proxies.${NC}"
  else
    echo -e "${GREEN}✔ Showing 10 fresh proxies:${NC}"
    echo "$proxies" | nl -w2 -s'. '
  fi
}

# Installer
install_globally() {
  echo -e "${CYAN}\n📦 Installing Academi_warp as global command...${NC}"
  curl -fsSL https://raw.githubusercontent.com/Academivpn73/Academi-warp1/main/warp.sh -o $PREFIX/bin/Academi_warp
  chmod +x $PREFIX/bin/Academi_warp
  echo -e "${GREEN}✔ Installed! Now you can run with: ${YELLOW}Academi_warp${NC}\n"
}

# Main Menu
main_menu() {
  clear
  echo -e "${YELLOW}Academi Warp Tool ${NC} - ${CYAN}Version $VERSION${NC}"
  echo -e "${GREEN}Channel:${NC} $CHANNEL   ${GREEN}Support:${NC} $ADMIN"
  echo -e "\n${CYAN}Select an option:${NC}"
  echo -e "${CYAN}1.${NC} WARP IP Scanner"
  echo -e "${CYAN}2.${NC} Telegram Proxy List"
  echo -e "${CYAN}3.${NC} Install as Command (Academi_warp)"
  echo -e "${CYAN}0.${NC} Exit"
  echo -ne "\n${YELLOW}>>> ${NC}"
  read choice

  case $choice in
    1) warp_ipv4_scanner ;;
    2) telegram_proxy_fetcher ;;
    3) install_globally ;;
    0) echo -e "${GREEN}Bye.${NC}"; exit ;;
    *) echo -e "${RED}❌ Invalid option.${NC}" ;;
  esac

  echo -e "\n${CYAN}Press Enter to return to menu...${NC}"
  read
  main_menu
}

install_dependencies
main_menu
