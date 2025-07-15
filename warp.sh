#!/data/data/com.termux/files/usr/bin/bash

VERSION="1.3.0"
ALIAS_PATH="/data/data/com.termux/files/usr/bin/Academi_warp"

GREEN="\033[0;32m"; CYAN="\033[0;36m"
YELLOW="\033[1;33m"; RED="\033[0;31m"; NC="\033[0m"

install_requirements() {
  echo -e "${YELLOW}🔧 Installing dependencies...${NC}"
  pkg update -y >/dev/null
  pkg install curl wget jq -y >/dev/null
  if ! command -v wgcf &>/dev/null; then
    wget -qO wgcf "https://github.com/ViRb3/wgcf/releases/latest/download/wgcf_$(uname -m)"
    chmod +x wgcf && mv wgcf /data/data/com.termux/files/usr/bin/
  fi
  echo -e "${GREEN}✔ Requirements OK${NC}"
}

scan_warp_ips() {
  echo -e "${CYAN}\n🌍 Scanning active WARP IPv4 IPs...${NC}"
  count=0
  while [[ $count -lt 10 ]]; do
    ip="162.159.$((RANDOM % 256)).$((RANDOM % 256))"
    port=$((RANDOM % 60000 + 1000))
    ping_ms=$(ping -c1 -W1 $ip 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$ping_ms" ]]; then
      echo -e "${GREEN}✔ $ip:$port  Ping: ${ping_ms}ms${NC}"
      ((count++))
    fi
  done
}

fetch_proxies() {
  echo -e "${CYAN}\n🌐 Fetching Telegram proxies...${NC}"
  proxies=$(curl -s https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt | grep '^tg://' | head -n10)
  if [[ -z "$proxies" ]]; then
    echo -e "${RED}✘ Failed to fetch proxies.${NC}"
  else
    echo -e "${GREEN}✔ Proxies:${NC}"
    echo "$proxies"
  fi
}

generate_wireguard_config() {
  echo -e "${CYAN}\n⚙ Registering & generating WireGuard config via wgcf...${NC}"
  wgcf register --accept-tos >/dev/null
  wgcf generate >/dev/null
  if [[ -f wgcf-profile.conf ]]; then
    echo -e "${GREEN}✔ Config ready: ${CYAN}wgcf-profile.conf${NC}"
    echo -e "${YELLOW}⚠ Run 'wgcf trace' after connection to verify warp=on${NC}"
  else
    echo -e "${RED}✘ Failed to create profile via wgcf.${NC}"
  fi
}

install_alias() {
  cp "$0" "$ALIAS_PATH"
  chmod +x "$ALIAS_PATH"
  echo -e "${GREEN}✔ Installed! Run with: ${CYAN}Academi_warp${NC}"
}

remove_alias() {
  rm -f "$ALIAS_PATH"
  echo -e "${RED}✖ Alias removed.${NC}"
}

main_menu() {
  clear
  echo -e "${CYAN}┌────────────────────────┐"
  echo -e "│ Academi WARP Toolkit v${VERSION} │"
  echo -e "└────────────────────────┘${NC}"
  echo -e "Channel: @Academi_vpn   Support: @MahdiAGM0"
  echo ""
  echo "1) Scan WARP IPs"
  echo "2) Get Telegram Proxies"
  echo "3) Generate WireGuard Config"
  echo "4) Install alias 'Academi_warp'"
  echo "5) Remove alias"
  echo "0) Exit"
  echo ""
  read -p "Select: " choice
  case "$choice" in
    1) scan_warp_ips ;;
    2) fetch_proxies ;;
    3) generate_wireguard_config ;;
    4) install_alias ;;
    5) remove_alias ;;
    0) exit 0 ;;
    *) echo -e "${RED}[!] Invalid choice.${NC}" ;;
  esac
  echo ""
  read -p "Press Enter to continue..."
  main_menu
}

install_requirements
main_menu
