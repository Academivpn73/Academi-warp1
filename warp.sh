#!/bin/bash

# ─── COLORS ─────────────────────────────────────────────────────────────
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
NC="\e[0m"

# ─── TITLE ──────────────────────────────────────────────────────────────
clear
echo -e "${CYAN}╔══════════════════════════════════════════════╗"
echo -e "║         ${GREEN}Academi WARP Toolkit ${YELLOW}v1.0.0${CYAN}              ║"
echo -e "║   ${NC}Channel: @Academi_vpn${CYAN}     Admin: @MahdiAGM0   ║"
echo -e "╚══════════════════════════════════════════════╝${NC}"
echo ""

# ─── CHECK DEPENDENCIES ────────────────────────────────────────────────
install_dependencies() {
  echo -e "${YELLOW}🔧 Installing requirements...${NC}"
  pkg update -y >/dev/null 2>&1
  pkg install curl jq -y >/dev/null 2>&1
}

# ─── FETCH TELEGRAM PROXIES ────────────────────────────────────────────
telegram_proxy_fetcher() {
  echo -e "${CYAN}\n🌐 Fetching fresh Telegram proxies...${NC}"
  sleep 1
  urls=(
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/tg/mtproto.txt"
    "https://raw.githubusercontent.com/TheSpeedX/TBomb/master/core/proxies/mtproto.txt"
  )
  for url in "${urls[@]}"; do
    proxies=$(curl -s "$url" | grep '^tg://' | head -n 10)
    if [[ -n "$proxies" ]]; then
      echo -e "${GREEN}✔ Showing 10 fresh proxies from $url:${NC}"
      echo "$proxies" | nl -w2 -s'. '
      return
    fi
  done
  echo -e "${RED}❌ Failed to fetch proxies from all sources.${NC}"
}

# ─── WARP SCANNER ───────────────────────────────────────────────────────
warp_scanner() {
  echo -e "${CYAN}\n🔍 Scanning best WARP IPv4 IPs...${NC}"
  sleep 1

  # Example CIDRs from Cloudflare (replace with full list as needed)
  cidr_blocks=("162.159.192.0/24" "188.114.96.0/24")

  ips=()
  while [[ ${#ips[@]} -lt 10 ]]; do
    cidr=${cidr_blocks[$RANDOM % ${#cidr_blocks[@]}]}
    base=$(echo "$cidr" | cut -d'/' -f1 | cut -d'.' -f1-3)
    for i in $(seq 1 254); do
      ip="${base}.${i}"
      port=$((RANDOM % 65535 + 1))
      ping=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
      if [[ -n "$ping" ]]; then
        echo -e "${GREEN}✔ $ip:$port  Ping: ${ping}ms${NC}"
        ips+=("$ip:$port")
        if [[ ${#ips[@]} -ge 10 ]]; then break; fi
      fi
    done
    [[ ${#ips[@]} -ge 10 ]] && break
  done

  [[ ${#ips[@]} -eq 0 ]] && echo -e "${RED}❌ No responsive IPs found.${NC}"
}

# ─── MAIN MENU ──────────────────────────────────────────────────────────
main_menu() {
  echo -e "\n${CYAN}Select an option:${NC}"
  echo -e " 1️⃣  WARP IPv4 Scanner"
  echo -e " 2️⃣  Telegram Proxies"
  echo -e " 0️⃣  Exit"
  echo -en "${YELLOW}\nEnter choice: ${NC}"
  read choice
  case $choice in
    1) warp_scanner ;;
    2) telegram_proxy_fetcher ;;
    0) exit 0 ;;
    *) echo -e "${RED}❌ Invalid choice!${NC}" && sleep 1 && main_menu ;;
  esac
}

# ─── INSTALLER SETUP ────────────────────────────────────────────────────
installer_setup() {
  chmod +x "$0"
  cp "$0" /data/data/com.termux/files/usr/bin/Academi_warp 2>/dev/null
  echo -e "${GREEN}✔ You can now run this script with: ${CYAN}Academi_warp${NC}"
}

# ─── RUN ────────────────────────────────────────────────────────────────
install_dependencies
installer_setup
main_menu
