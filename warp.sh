#!/bin/bash

# ===================================================
#  Academi VPN Toolkit
#  Telegram: @Academi_vpn
#  Admin: @MahdiAGM0
# ===================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SAVE_DIR="Academi_Configs"
mkdir -p "$SAVE_DIR"
MAX_IPS=10
PORTS=(80 443 8080 8443 2052 2082 2086 2095)

# Get external IPv4 from Cloudflare
get_warp_ip() {
  curl --connect-timeout 3 -s4 https://www.cloudflare.com/cdn-cgi/trace | grep '^ip=' | cut -d= -f2
}

# Ping function using TCP connect
test_ip() {
  IP=$1
  for PORT in "${PORTS[@]}"; do
    START=$(date +%s%3N)
    timeout 1 bash -c "echo >/dev/tcp/$IP/$PORT" 2>/dev/null
    if [ $? -eq 0 ]; then
      END=$(date +%s%3N)
      PING=$(echo "scale=2; ($END - $START)/1000" | bc)
      echo "$IP:$PORT  Ping(${PING}ms)"
      return 0
    fi
  done
  return 1
}

# Warp Scanner
scan_warp_ips() {
  echo -e "${YELLOW}Scanning best WARP IPv4 IPs...${NC}"
  COUNT=0
  while [ $COUNT -lt $MAX_IPS ]; do
    IP=$(get_warp_ip)
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      if test_ip $IP; then
        ((COUNT++))
      fi
    fi
  done
}

# Telegram Proxy List (update manually)
show_telegram_proxies() {
  echo -e "${GREEN}Available Telegram Proxies:${NC}"
  echo ""
  cat <<EOF
tg://proxy?server=1.1.1.1&port=443&secret=ee00000000000000000000000000000000000000
tg://proxy?server=2.2.2.2&port=443&secret=ee11111111111111111111111111111111111111
tg://proxy?server=3.3.3.3&port=443&secret=ee22222222222222222222222222222222222222
EOF
  echo ""
  echo -e "${YELLOW}You can edit proxies in the script directly.${NC}"
}

# Main Menu
while true; do
  echo -e "${GREEN}"
  echo "============================"
  echo "    Academi VPN Toolkit"
  echo "============================"
  echo -e "${NC}"
  echo "1. Warp IPv4 IP Scanner"
  echo "2. Telegram Proxy List"
  echo "0. Exit"
  echo ""
  read -p "Choose an option: " CHOICE

  case $CHOICE in
    1)
      scan_warp_ips
      ;;
    2)
      show_telegram_proxies
      ;;
    0)
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Try again.${NC}"
      ;;
  esac
done
