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

MAX_IPS=10
PORTS=(80 443 2086 8443 2052 2087)
TEMP_IP_FILE=$(mktemp)
PROXY_CACHE_DIR="$HOME/.academi_proxy_cache"
TODAY=$(date +%F)
PROXY_FILE="$PROXY_CACHE_DIR/proxies_$TODAY.txt"

mkdir -p "$PROXY_CACHE_DIR"

# Get IPv4 from WARP interface
get_warp_ip() {
  curl -s4 --interface wgcf-warp https://api.ipify.org
}

# Test IP for open port and ping
test_ip() {
  local IP=$1
  for PORT in "${PORTS[@]}"; do
    timeout 1 bash -c "</dev/tcp/$IP/$PORT" &>/dev/null
    if [ $? -eq 0 ]; then
      local START=$(date +%s%3N)
      timeout 1 bash -c "</dev/tcp/$IP/$PORT" &>/dev/null
      local END=$(date +%s%3N)
      local PING=$(echo "scale=2; ($END - $START)/1000" | bc)
      echo "$IP:$PORT  Ping(${PING}ms)"
      return 0
    fi
  done
  return 1
}

# WARP IPv4 Scanner
scan_warp_ips() {
  echo -e "${YELLOW}🔍 Scanning best WARP IPv4 IPs...${NC}"
  COUNT=0
  > "$TEMP_IP_FILE"
  while [ $COUNT -lt $MAX_IPS ]; do
    IP=$(get_warp_ip)
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      if test_ip "$IP" >> "$TEMP_IP_FILE"; then
        ((COUNT++))
      fi
    fi
    sleep 1
  done
  echo -e "${GREEN}\n✅ Found $COUNT working WARP IPs:${NC}"
  cat "$TEMP_IP_FILE"
  echo ""
}

# Fetch and cache proxy list if not already cached today
fetch_telegram_proxies() {
  if [[ ! -f "$PROXY_FILE" ]]; then
    echo -e "${YELLOW}📡 Fetching fresh Telegram MTProto proxies...${NC}"
    curl -s "https://mtpro.xyz/api/?type=mtproto" | \
      jq -r '.[] | "\(.host):\(.port) secret:\(.secret) ping:\(.ping)ms country:\(.country)"' \
      > "$PROXY_FILE"
  else
    echo -e "${GREEN}✔ Using cached proxy list for today ($TODAY).${NC}"
  fi
}

# Show proxies
show_telegram_proxies() {
  fetch_telegram_proxies
  echo -e "${GREEN}\nTop 10 Telegram MTProto Proxies:${NC}"
  head -n 10 "$PROXY_FILE" | while IFS= read -r line; do
    HOST=$(echo "$line" | awk -F':' '{print $1}')
    PORT=$(echo "$line" | awk -F'[: ]' '{print $2}')
    SECRET=$(echo "$line" | awk -F'secret:' '{print $2}' | awk '{print $1}')
    echo "tg://proxy?server=${HOST}&port=${PORT}&secret=${SECRET}"
  done
  echo ""
}

# Main Menu
while true; do
  echo -e "${GREEN}"
  echo "============================"
  echo "    Academi VPN Toolkit"
  echo "============================"
  echo -e "${NC}"
  echo "1) Warp IPv4 Scanner"
  echo "2) Telegram Proxy List (auto-updated daily)"
  echo "0) Exit"
  echo ""
  read -p "Choose an option: " OPT
  case $OPT in
    1) scan_warp_ips ;;
    2) show_telegram_proxies ;;
    0) echo "Goodbye!"; break ;;
    *) echo -e "${RED}Invalid option. Try again.${NC}" ;;
  esac
done

# Cleanup
rm -f "$TEMP_IP_FILE"
