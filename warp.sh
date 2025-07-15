#!/bin/bash

# ========== Color codes ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========== Title ==========
show_title() {
  clear
  echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}   🚀 ACADEMI VPN MULTI TOOL - VERSION 1.7.1   ${NC}"
  echo -e "${BLUE}╠══════════════════════════════════════════════╣${NC}"
  echo -e "${YELLOW}  Telegram: @Academi_vpn${NC}"
  echo -e "${CYAN}  Admin: @MahdiAGM0${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
}

# ========== Install required packages ==========
install_dependencies() {
  for pkg in curl jq ping bc cron; do
    if ! command -v $pkg &> /dev/null; then
      echo -e "${YELLOW}Installing missing package: $pkg...${NC}"
      apt install -y $pkg >/dev/null 2>&1 || yum install -y $pkg >/dev/null 2>&1
    fi
  done
}

# ========== Warp IP Scanner ==========
scan_warp_ips() {
  echo -e "${YELLOW}🔍 Scanning WARP IPs...${NC}"
  for i in {1..10}; do
    IP=$(shuf -i 1-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1)
    PORT=$((RANDOM % 65535 + 1))
    PING=$(ping -c 1 -W 1 $IP | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [ -z "$PING" ]; then
      PING="Timeout"
    fi
    echo -e "${CYAN}IP:$IP:$PORT   ${GREEN}Ping: ${PING} ms${NC}"
  done
  read -p "Press enter to return..." && main_menu
}

# ========== Fetch Telegram Proxies ==========
fetch_proxies() {
  echo -e "${YELLOW}🔄 Fetching Telegram proxies...${NC}"
  proxies=()
  urls=(
    "https://raw.githubusercontent.com/officialputuid/KangProxy/KangList/tg.txt"
    "https://raw.githubusercontent.com/aliilapro/telegram-proxy/main/proxy.txt"
    "https://raw.githubusercontent.com/prxchk/proxy-list/main/tg.txt"
  )

  for url in "${urls[@]}"; do
    response=$(curl -s --connect-timeout 5 "$url")
    if [[ $? -eq 0 && -n "$response" ]]; then
      while IFS= read -r line; do
        [[ "$line" == tg://proxy* ]] && proxies+=("$line")
      done <<< "$response"
    fi
  done

  if [[ ${#proxies[@]} -eq 0 ]]; then
    echo -e "${RED}❌ No working Telegram proxies found.${NC}"
  else
    echo -e "${GREEN}✅ Found ${#proxies[@]} Telegram proxies.${NC}"
    for i in $(seq 1 10); do
      echo -e "${CYAN}Proxy $i:${NC} ${proxies[$i]}"
    done
  fi
  read -p "Press enter to return..." && main_menu
}

# ========== Cron Job (Auto update) ==========
setup_daily_update() {
  cron_job="0 */5 * * * /bin/bash $0 fetch"
  (crontab -l 2>/dev/null | grep -v "$0 fetch"; echo "$cron_job") | crontab -
}

# ========== Installer Alias ==========
setup_installer_alias() {
  ln -sf "$PWD/$0" /usr/local/bin/Academivpn_warp
  chmod +x /usr/local/bin/Academivpn_warp
}

remove_installer_alias() {
  rm -f /usr/local/bin/Academivpn_warp
}

# ========== Menu ==========
main_menu() {
  show_title
  echo -e "${YELLOW}[1]${NC} Warp IP Scanner"
  echo -e "${YELLOW}[2]${NC} Telegram Proxy Fetcher"
  echo -e "${YELLOW}[3]${NC} Enable Installer (Academivpn_warp)"
  echo -e "${YELLOW}[4]${NC} Remove Installer"
  echo -e "${YELLOW}[5]${NC} Exit"
  echo -ne "${GREEN}Choose an option:${NC} "
  read opt
  case $opt in
    1) scan_warp_ips ;;
    2) fetch_proxies ;;
    3) setup_installer_alias; echo -e "${GREEN}✅ Installer enabled. Use command: Academivpn_warp${NC}"; sleep 2; main_menu ;;
    4) remove_installer_alias; echo -e "${RED}❌ Installer removed.${NC}"; sleep 2; main_menu ;;
    5) echo -e "${BLUE}Goodbye!${NC}"; exit ;;
    *) echo -e "${RED}❌ Invalid option${NC}"; sleep 1; main_menu ;;
  esac
}

# ========== Execute ==========
if [[ "$1" == "fetch" ]]; then
  fetch_proxies
else
  install_dependencies
  setup_daily_update
  main_menu
fi
