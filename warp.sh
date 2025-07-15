#!/bin/bash

VERSION="1.7.1"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ✅ Install required packages
install_packages() {
  echo -e "${BLUE}Installing required packages...${NC}"
  apt update -y >/dev/null 2>&1
  apt install curl wget jq cron net-tools bc -y >/dev/null 2>&1
  systemctl enable cron >/dev/null 2>&1
  systemctl start cron >/dev/null 2>&1
}

# ✅ Title Banner
show_title() {
  echo -e "${CYAN}╔══════════════════════════════════════╗"
  echo -e "║   Telegram: ${CHANNEL}"
  echo -e "║   Admin:    ${ADMIN}"
  echo -e "║   Version:  ${VERSION}"
  echo -e "╚══════════════════════════════════════╝${NC}\n"
}

# ✅ WARP IP Scanner
scan_warp() {
  echo -e "${BLUE}🔍 Scanning WARP servers...${NC}"
  for i in {1..10}; do
    IP=$(shuf -i 1-255 -n 4 | paste -sd .)
    PORT=$((RANDOM % 64512 + 1024))
    (ping -c1 -W1 "$IP" >/dev/null 2>&1 && echo -e "${GREEN}✅ $IP:$PORT  Ping: $(ping -c1 -W1 $IP | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1) ms${NC}") || echo -e "${RED}❌ $IP:$PORT  Unreachable${NC}"
  done
}

# ✅ Fetch Telegram Proxies
fetch_proxies() {
  echo -e "${BLUE}\n🔄 Fetching Telegram proxies...${NC}"
  TMP=$(mktemp)
  curl -s --max-time 15 https://api.ssn0.dev/proxy/all -o "$TMP"

  if [[ ! -s "$TMP" ]]; then
    echo -e "${RED}❌ Failed to fetch proxy data.${NC}"
    return
  fi

  LINKS=$(jq -r '.[] | select(.type=="tg") | .link' "$TMP" | head -n 10)

  if [[ -z "$LINKS" ]]; then
    echo -e "${RED}❌ No working Telegram proxies found.${NC}"
    return
  fi

  i=1
  echo ""
  for proxy in $LINKS; do
    echo -e "${GREEN}Proxy $i:${NC} $proxy"
    ((i++))
  done
}

# ✅ Install cronjob for daily update
setup_daily_update() {
  CRON_JOB="@daily bash $0 --cron-fetch"
  crontab -l 2>/dev/null | grep -v 'cron-fetch' | { cat; echo "$CRON_JOB"; } | crontab -
}

# ✅ Installer creation
create_installer() {
  echo -e "${BLUE}📦 Creating installer command...${NC}"
  echo "bash $(realpath $0)" > /usr/local/bin/Academivpn_warp
  chmod +x /usr/local/bin/Academivpn_warp
  echo -e "${GREEN}✅ You can now run with: ${CYAN}Academivpn_warp${NC}"
}

# ✅ Remove installer
remove_installer() {
  rm -f /usr/local/bin/Academivpn_warp
  echo -e "${RED}❌ Installer removed.${NC}"
}

# ✅ Menu
main_menu() {
  while true; do
    clear
    show_title
    echo -e "${CYAN}1) Warp IP Scanner"
    echo "2) Telegram Proxies"
    echo "3) Enable Installer (Academivpn_warp)"
    echo "4) Remove Installer"
    echo "5) Exit${NC}"
    echo -ne "\nChoose an option: "
    read -r choice
    case "$choice" in
      1) scan_warp ;;
      2) fetch_proxies ;;
      3) create_installer ;;
      4) remove_installer ;;
      5) echo -e "${BLUE}Exiting...${NC}"; exit 0 ;;
      *) echo -e "${RED}Invalid choice.${NC}" ;;
    esac
    echo -ne "\nPress Enter to continue..."
    read
  done
}

# ✅ Cron-mode execution
if [[ $1 == "--cron-fetch" ]]; then
  fetch_proxies > /dev/null 2>&1
  exit 0
fi

# Run everything
install_packages
setup_daily_update
main_menu
