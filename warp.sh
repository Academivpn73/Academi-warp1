#!/usr/bin/env bash

# ========== Info ==========
VERSION="1.0.1"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

# ========== Colors ==========
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
NC='\e[0m'

# ========== Directories ==========
PROXY_DIR="Academi_Proxy"
PROXY_FILE="$PROXY_DIR/proxies.txt"
IP_FILE="Academi_IPs/warp_ipv4.txt"
mkdir -p $PROXY_DIR
mkdir -p Academi_IPs

# ========== Requirements ==========
install_requirements() {
  for tool in curl jq ping; do
    if ! command -v $tool >/dev/null 2>&1; then
      echo -e "${YELLOW}Installing $tool...${NC}"
      apt install -y $tool >/dev/null 2>&1 || pkg install -y $tool >/dev/null 2>&1
    fi
  done
}

# ========== Header ==========
show_header() {
  clear
  echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
  echo -e "${CYAN}│        Academi VPN Tool - v$VERSION        │${NC}"
  echo -e "${CYAN}├────────────────────────────────────────┤${NC}"
  echo -e "${GREEN}│ Channel : $CHANNEL"
  echo -e "│ Admin   : $ADMIN${NC}"
  echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
}

# ========== WARP IPv4 Scanner ==========
scan_warp_ips() {
  echo -e "\n${YELLOW}Scanning real Cloudflare WARP IPv4 addresses...${NC}"
  > $IP_FILE
  local count=0
  while [[ $count -lt 10 ]]; do
    IP=$(curl -s4 --connect-timeout 3 https://speed.cloudflare.com/meta | jq -r '.client.ip')
    [[ "$IP" == "null" || -z "$IP" ]] && continue

    PORTS=(80 443 8443 2083)
    for port in "${PORTS[@]}"; do
      timeout 1 bash -c "echo > /dev/tcp/$IP/$port" 2>/dev/null
      if [[ $? -eq 0 ]]; then
        PING=$(ping -c1 -W1 $IP 2>/dev/null | grep time= | cut -d= -f4 | cut -d' ' -f1)
        [[ -z "$PING" ]] && continue
        echo -e "${GREEN}$IP:$port  Ping: ${PING}ms${NC}"
        echo "$IP:$port  Ping: ${PING}ms" >> $IP_FILE
        ((count++))
        break
      fi
    done
    sleep 1
  done

  echo -e "\n${CYAN}✔ Saved to $IP_FILE${NC}"
  read -p "Press Enter to return to menu..."
}

# ========== Fetch Telegram Proxies ==========
fetch_proxies() {
  echo -e "\n${YELLOW}Updating Telegram MTProto Proxies...${NC}"
  curl -s https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt -o "$PROXY_FILE"
  if [[ -s $PROXY_FILE ]]; then
    echo -e "${GREEN}✔ Proxies updated. Showing top 10:${NC}"
    head -n 10 $PROXY_FILE | nl
  else
    echo -e "${RED}❌ Failed to fetch proxies.${NC}"
  fi
  echo -e "\n${CYAN}Next update in 5 hours.${NC}"
  read -p "Press Enter to return to menu..."
}

# ========== Auto Update Proxies Every 5 Hours ==========
auto_update_proxies() {
  while true; do
    fetch_proxies >/dev/null
    sleep 18000  # 5 hours
  done
}

# ========== Main Menu ==========
main_menu() {
  while true; do
    show_header
    echo -e "${YELLOW}1) WARP IPv4 Scanner"
    echo -e "2) Telegram Proxy List"
    echo -e "0) Exit${NC}"
    echo
    read -rp "Choose an option: " opt
    case $opt in
      1) scan_warp_ips ;;
      2) fetch_proxies ;;
      0) exit ;;
      *) echo -e "${RED}Invalid choice!${NC}"; sleep 1 ;;
    esac
  done
}

# ========== Run ==========
install_requirements
auto_update_proxies & disown
main_menu
