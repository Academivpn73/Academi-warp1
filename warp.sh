#!/bin/bash

VERSION="1.1.0"
CHANNEL_ID="@Academi_vpn"
SUPPORT_ID="@MahdiAGM0"

GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

TMP_DIR="warp_tmp"
PROXY_FILE="telegram_proxies.txt"

# ------------------------
# HEADER
# ------------------------
print_header() {
  clear
  echo -e "${GREEN}╔════════════════════════════════════════╗"
  echo -e "║      Academi WARP Tool - v$VERSION          ║"
  echo -e "╠════════════════════════════════════════╣"
  echo -e "║  Channel : $CHANNEL_ID"
  echo -e "║  Support : $SUPPORT_ID"
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo ""
}

# ------------------------
# INSTALL REQUIREMENTS
# ------------------------
install_requirements() {
  apt update -y &>/dev/null
  apt install -y curl jq iputils-ping net-tools &>/dev/null
  mkdir -p $TMP_DIR
}

# ------------------------
# DOWNLOAD PROXIES
# ------------------------
update_proxies() {
  curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt -o $PROXY_FILE
}

# ------------------------
# AUTO UPDATE PROXIES EVERY HOUR
# ------------------------
schedule_proxy_update() {
  (crontab -l 2>/dev/null | grep -v "$PROXY_FILE"; echo "0 * * * * curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt -o $PWD/$PROXY_FILE") | crontab -
}

# ------------------------
# SHOW PROXY LIST
# ------------------------
proxy_list() {
  print_header
  echo -e "🌍 Telegram Proxies (Auto updated):\n"

  if [[ ! -f $PROXY_FILE ]]; then
    update_proxies
  fi

  head -n 10 $PROXY_FILE
  echo
  read -p "Press Enter to return to menu..."
}

# ------------------------
# WARP IP SCANNER (REAL WORKING IPs)
# ------------------------
warp_ip_scanner() {
  print_header
  echo -e "🔍 Scanning best WARP IPv4 IPs (up to 10)...\n"

  > $TMP_DIR/valid_ips.txt
  COUNT=0

  for ip in $(shuf -n 200 -i 162.159.192.0-162.159.193.254); do
    for port in 80 443 2083 8443; do
      timeout 1 bash -c "</dev/tcp/$ip/$port" &>/dev/null
      if [[ $? -eq 0 ]]; then
        ping_ms=$(ping -c1 -W1 $ip | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [[ -n "$ping_ms" ]]; then
          echo "$ip:$port  ${ping_ms}ms" >> $TMP_DIR/valid_ips.txt
          echo -e "${GREEN}$ip:$port  ${ping_ms}ms${NC}"
          ((COUNT++))
          break
        fi
      fi
    done
    [[ $COUNT -ge 10 ]] && break
  done

  if [[ $COUNT -eq 0 ]]; then
    echo -e "${RED}❌ No working IPs found.${NC}"
  else
    echo -e "\n✅ Top $COUNT WARP IPs:"
    cat $TMP_DIR/valid_ips.txt
  fi

  echo
  read -p "Press Enter to return to menu..."
}

# ------------------------
# MAIN MENU
# ------------------------
main_menu() {
  while true; do
    print_header
    echo "1️⃣  WARP IPv4 Scanner"
    echo "2️⃣  Telegram Proxy List"
    echo "0️⃣  Exit"
    echo
    read -p "Choose an option: " choice

    case $choice in
      1) warp_ip_scanner ;;
      2) proxy_list ;;
      0) echo -e "\n${GREEN}Exiting...${NC}"; exit 0 ;;
      *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
    esac
  done
}

# ------------------------
# START
# ------------------------
install_requirements
update_proxies
schedule_proxy_update
main_menu
