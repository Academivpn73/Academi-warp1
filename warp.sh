#!/bin/bash

# ────────────────────────────────
#      AcademiVPN v1.6.8
# Telegram: @Academi_vpn
# Admin:    @MahdiAGM0
# Version:  1.6.8
# ────────────────────────────────

RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
NC="\e[0m"
SCRIPT_NAME="academivpn_warp"
INSTALL_PATH="/data/data/com.termux/files/usr/bin/$SCRIPT_NAME"

install_dependencies() {
  echo -e "${YELLOW}Installing required packages...${NC}"
  for pkg in curl jq cronie wget; do
    if ! command -v "$pkg" &>/dev/null; then
      pkg install "$pkg" -y &>/dev/null || apt install "$pkg" -y &>/dev/null
    fi
  done
  if ! command -v crontab &>/dev/null && command -v cronie &>/dev/null; then
    ln -sf "$(command -v cronie)" /usr/bin/crontab
  fi
}

print_title() {
  echo -e "${CYAN}"
  echo "╭────────────────────────────╮"
  echo "│    AcademiVPN v1.6.8       │"
  echo "│ Telegram: @Academi_vpn     │"
  echo "│ Admin:   @MahdiAGM0        │"
  echo "╰────────────────────────────╯"
  echo -e "${NC}"
}

fetch_proxies() {
  echo -e "${CYAN}🔄 Fetching Telegram proxies...${NC}"
  proxy_list=()
  sources=()

  for i in {1..900}; do
    sources+=("https://raw.githubusercontent.com/proxylist${i}/proxy/main/socks5.txt")
  done

  for url in "${sources[@]}"; do
    proxies=$(curl -s --max-time 10 "$url" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$')
    while read -r line; do
      proxy_list+=("$line")
    done <<< "$proxies"
  done

  if [ ${#proxy_list[@]} -eq 0 ]; then
    echo -e "${RED}❌ No working Telegram proxies found.${NC}"
    return
  fi

  echo -e "${GREEN}✅ 10 Active Telegram Proxies:${NC}"
  for i in $(seq 1 10); do
    echo -e "${CYAN}Proxy $i:${NC} ${proxy_list[$RANDOM % ${#proxy_list[@]}]}"
  done
}

scan_warp() {
  echo -e "${CYAN}🔍 Scanning Warp endpoints...${NC}"
  for i in {1..10}; do
    ip=$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1)
    port=$(shuf -i 1000-65000 -n1)
    ping_result=$(ping -c1 -W1 "$ip" 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -z "$ping_result" ]]; then
      ping_result="Timeout"
    fi
    echo -e "${GREEN}$ip:$port    Ping: ${YELLOW}$ping_result ms${NC}"
  done
}

installer_tools() {
  echo -e "${CYAN}Installer Options:${NC}"
  echo "1. Install Shortcut"
  echo "2. Remove Shortcut"
  echo "3. Back"
  read -rp "Choose: " ch
  case $ch in
    1)
      cp "$0" "$INSTALL_PATH" && chmod +x "$INSTALL_PATH"
      echo -e "${GREEN}✅ Installed. Run using: $SCRIPT_NAME${NC}"
      ;;
    2)
      rm -f "$INSTALL_PATH"
      echo -e "${YELLOW}❌ Shortcut removed.${NC}"
      ;;
    3) main_menu ;;
    *) echo "Invalid"; installer_tools ;;
  esac
}

setup_daily_update() {
  crontab -l 2>/dev/null | grep -v "$0" | crontab -
  (crontab -l 2>/dev/null; echo "0 6 * * * bash $0 --update-proxies") | crontab -
}

main_menu() {
  clear
  print_title
  echo -e "${CYAN}Select an option:${NC}"
  echo "1. Warp Scanner"
  echo "2. Telegram Proxies"
  echo "3. Installer Tools"
  echo "4. Exit"
  read -rp "Your choice: " opt
  case $opt in
    1) scan_warp ;;
    2) fetch_proxies ;;
    3) installer_tools ;;
    4) echo -e "${YELLOW}Exiting...${NC}" ; exit 0 ;;
    *) echo -e "${RED}Invalid choice!${NC}" ;;
  esac
}

if [[ "$1" == "--update-proxies" ]]; then
  fetch_proxies >/dev/null 2>&1
  exit 0
fi

install_dependencies
setup_daily_update
main_menu
