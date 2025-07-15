#!/bin/bash

VERSION="1.0.1"
CHANNEL="Telegram: @Academi_vpn"
SUPPORT="Admin: @MahdiAGM0"

GREEN='\e[1;32m'; YELLOW='\e[1;33m'; BLUE='\e[1;34m'; RED='\e[1;31m'; NC='\e[0m'
PROXY_FILE="proxies_mtproto.txt"; IP_FILE="working_ips.txt"

install_deps() {
  for pkg in curl jq ping; do
    command -v $pkg >/dev/null || { echo -e "${YELLOW}Installing $pkg...${NC}"; pkg install -y $pkg >/dev/null; }
  done
}

show_header() {
  clear
  echo -e "${BLUE}===================================="
  echo -e "${GREEN}    Academi WARP Tool - v$VERSION"
  echo -e "${YELLOW}    $CHANNEL"
  echo -e "${YELLOW}    $SUPPORT"
  echo -e "${BLUE}====================================${NC}"
}

warp_scanner() {
  show_header
  echo -e "${YELLOW}🔍 Scanning real Cloudflare WARP IPv4 IPs...${NC}"
  > $IP_FILE; count=0
  for prefix in 162.159.192 162.159.193; do
    for ip in $(seq 1 254); do
      addr="$prefix.$ip"
      # تست پورت (443) و پینگ
      timeout 1 bash -c "</dev/tcp/$addr/443" &>/dev/null || continue
      ping_ms=$(ping -c1 -W1 $addr 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
      [[ -z "$ping_ms" ]] && continue
      echo "$addr:443  Ping(${ping_ms}ms)" | tee -a $IP_FILE
      ((count++))
      [[ $count -ge 10 ]] && break 2
    done
  done
  if ((count==0)); then echo -e "${RED}❌ No real WARP IPs working.${NC}"
  else echo -e "\n${GREEN}✅ Found $count real WARP IPs:${NC}"; cat $IP_FILE; fi
  echo; read -p "Press Enter..."
}

update_proxies() {
  echo -e "${BLUE}Updating MTProto proxy list...${NC}"
  curl -s https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt -o $PROXY_FILE
  [[ -s $PROXY_FILE ]] && echo -e "${GREEN}✔ Proxies updated.${NC}" || echo -e "${RED}❌ Proxy update failed.${NC}"
}

show_proxies() {
  show_header
  [[ ! -f $PROXY_FILE ]] && update_proxies
  echo -e "${YELLOW}📡 Telegram MTProto Proxies (top 10):${NC}"
  head -n 10 $PROXY_FILE | nl
  echo -e "${BLUE}\nLast updated: $(date)${NC}"
  echo; read -p "Press Enter..."
}

main_menu() {
  install_deps
  update_proxies
  # cron setup:
  (crontab -l 2>/dev/null | grep -v "$PROXY_FILE"; echo "0 */3 * * * curl -s https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt -o $(pwd)/$PROXY_FILE") | crontab -
  while true; do
    show_header
    echo -e "${YELLOW}1) Scan WARP IPv4 IPs"
    echo -e "2) Show Telegram Proxies"
    echo -e "0) Exit${NC}"
    read -rp "Choose option: " opt
    case $opt in
      1) warp_scanner ;;
      2) show_proxies ;;
      0) exit ;;
      *) echo -e "${RED}Invalid choice.${NC}"; sleep 1 ;;
    esac
  done
}

main_menu
