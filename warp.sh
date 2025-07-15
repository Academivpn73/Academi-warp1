#!/usr/bin/env bash
VERSION="1.0.0"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

GREEN='\e[1;32m'; YELLOW='\e[1;33m'; CYAN='\e[1;36m'; RED='\e[1;31m'; NC='\e[0m'
PROXY_DIR="proxies"; PROXY_FILE="$PROXY_DIR/list.txt"; IP_FILE="warp_ips.txt"

install_req() {
  for pkg in curl jq ping; do
    if ! command -v $pkg >/dev/null 2>&1; then
      echo -e "${YELLOW}Installing $pkg...${NC}"
      pkg install -y $pkg >/dev/null 2>&1 || apt-get install -y $pkg >/dev/null 2>&1
    fi
  done
}

print_header() {
  clear
  echo -e "${CYAN}┌──────────────────────────────┐${NC}"
  echo -e "${CYAN}│   Academi VPN Tool v$VERSION   │${NC}"
  echo -e "${CYAN}├──────────────────────────────┤${NC}"
  echo -e "${GREEN}│ Channel: $CHANNEL"
  echo -e "│ Admin:   $ADMIN${NC}"
  echo -e "${CYAN}└──────────────────────────────┘${NC}"
}

warp_scan() {
  > $IP_FILE
  echo -e "\n${CYAN}Scanning real WARP IPv4 IPs...${NC}"
  local c=0
  while [[ $c -lt 10 ]]; do
    IP=$(curl -s4 --connect-timeout 2 https://speed.cloudflare.com/meta | jq -r '.client.ip')
    if [[ -z "$IP" || "$IP" == "null" ]]; then
      sleep 1; continue
    fi
    port=443
    ping_ms=$(ping -c1 -W1 "$IP" 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$ping_ms" ]]; then
      echo -e "${GREEN}$IP:$port  Ping: $ping_ms ms${NC}"
      echo "$IP:$port  Ping: $ping_ms ms" >> $IP_FILE
      ((c++))
    fi
    sleep 1
  done
  if [[ $c -eq 0 ]]; then
    echo -e "${RED}No real WARP IP found!${NC}"
  fi
  read -p "Press Enter to return..."
}

fetch_proxies() {
  mkdir -p $PROXY_DIR
  echo -e "${CYAN}Fetching Telegram MTProto proxies...${NC}"
  curl -s https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt -o "$PROXY_DIR/tmp.txt"
  grep '^tg://' "$PROXY_DIR/tmp.txt" | sort -u | head -n 20 > $PROXY_FILE
  rm "$PROXY_DIR/tmp.txt"
}

show_proxies() {
  if [[ ! -f $PROXY_FILE ]]; then fetch_proxies; fi
  echo -e "\n${CYAN}Telegram MTProto Proxies (top 10):${NC}"
  head -n 10 $PROXY_FILE | nl -w2 -s'. '
  echo -e "${CYAN}\nLast Updated: $(date)${NC}"
  read -p "Press Enter to return..."
}

auto_fetch_proxies() {
  while true; do
    fetch_proxies
    sleep 18000
  done
}

main_menu() {
  while true; do
    print_header
    echo -e "\n${YELLOW}1) Warp IPv4 Scanner"
    echo -e "2) Telegram Proxy List"
    echo -e "0) Exit${NC}"
    read -rp $'\nChoose option: ' opt
    case $opt in
      1) warp_scan ;;
      2) show_proxies ;;
      0) exit ;;
      *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
  done
}

install_req
auto_fetch_proxies &>/dev/null &
main_menu
