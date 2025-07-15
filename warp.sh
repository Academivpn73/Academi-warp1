#!/bin/bash
# Academi WARP Tool v1.0 — Telegram:@Academi_vpn — Support:@MahdiAGM0

GREEN='\e[1;32m'; YELLOW='\e[1;33m'; BLUE='\e[1;34m'; RED='\e[1;31m'; NC='\e[0m'
PROXY_FILE="proxies_mtproto.txt"
IP_FILE="warp_real_ips.txt"

install_warp() {
  if ! command -v warp-cli >/dev/null; then
    echo -e "${YELLOW}Installing Cloudflare WARP...${NC}"
    pkg update -y >/dev/null
    pkg install -y gnupg curl wget >/dev/null
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --dearmor -o cloudflare-archive.gpg
    mv cloudflare-archive.gpg $PREFIX/etc/apt/trusted.gpg.d/
    echo "deb [signed-by=$PREFIX/etc/apt/trusted.gpg.d/cloudflare-archive.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs; echo unknown) main" \
      > $PREFIX/etc/apt/sources.list.d/cloudflare-client.list
    pkg update -y >/dev/null
    pkg install -y cloudflare-warp >/dev/null
  fi
}

connect_warp() {
  echo -e "${GREEN}Registering and connecting WARP...${NC}"
  warp-cli register >/dev/null
  warp-cli connect >/dev/null
  sleep 3
}

scan_real_warp_ips() {
  echo -e "${BLUE}🔍 Scanning real WARP IPv4...${NC}"
  > $IP_FILE
  IP=$(curl -s https://api64.ipify.org)
  ping_ms=$(ping -c1 -W1 $IP 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
  if [[ -n "$ping_ms" ]]; then
    echo "$IP:443  Ping(${ping_ms}ms)" | tee -a $IP_FILE
    echo -e "${GREEN}✔ WARP IP: $IP  Ping: ${ping_ms}ms${NC}"
  else
    echo -e "${RED}❌ Failed to ping WARP IP.${NC}"
  fi
}

update_proxies() {
  echo -e "${YELLOW}Updating MTProto proxies...${NC}"
  curl -s https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt -o $PROXY_FILE
  [[ -s $PROXY_FILE ]] && echo -e "${GREEN}✅ Proxies updated${NC}" || echo -e "${RED}❌ Proxy update failed${NC}"
}

show_proxies() {
  [[ ! -f $PROXY_FILE ]] && update_proxies
  echo -e "\n${BLUE}📡 Telegram MTProto Proxies (Top 10):${NC}"
  head -n 10 $PROXY_FILE | nl
  echo -e "\nLast updated: $(date)"; echo
  read -p "Press enter to return..."
}

main_menu() {
  echo -e "${BLUE}======== Academi WARP Script v1.0 ========${NC}"
  echo -e "${GREEN}1) Scan real WARP IPv4 IP${NC}"
  echo -e "${GREEN}2) Show Telegram Proxy List${NC}"
  echo -e "${GREEN}0) Exit${NC}"
  echo
  read -rp "Choose option: " opt
  case $opt in
    1) scan_real_warp_ips ;;
    2) show_proxies ;;
    0) exit ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
}

# Setup
install_warp
connect_warp
update_proxies
# Setup cron to update proxy every 3 hours
(crontab -l 2>/dev/null | grep -v "$PROXY_FILE"; echo "0 */3 * * * curl -s https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt -o $(pwd)/$PROXY_FILE") | crontab -

# Loop menu
while true; do
  scan_real_warp_ips
  echo
  main_menu
  read
done
