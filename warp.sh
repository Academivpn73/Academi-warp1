#!/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#     Academi VPN Script v1.0.3
#     Telegram: @Academi_vpn
#     Support: @MahdiAGM0
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

function header() {
  clear
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "${GREEN}      Academi VPN Script - Version 1.0.3"
  echo "${YELLOW}      Telegram: @Academi_vpn"
  echo "${YELLOW}      Support: @MahdiAGM0"
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo
}

function install_requirements() {
  echo "${CYAN}Installing required packages...${RESET}"
  pkg install curl jq -y > /dev/null 2>&1
}

function menu() {
  echo "${GREEN}[1]${RESET} WARP IP Scanner (IPv4)"
  echo "${GREEN}[2]${RESET} Telegram Proxy List"
  echo "${GREEN}[0]${RESET} Exit"
  echo
  read -rp "${CYAN}Choose an option: ${RESET}" opt
  case "$opt" in
    1) warp_scanner ;;
    2) telegram_proxies ;;
    0) echo "${YELLOW}Exiting.${RESET}"; exit 0 ;;
    *) echo "${RED}Invalid choice.${RESET}"; sleep 1; main ;;
  esac
}

function warp_scanner() {
  echo
  echo "${CYAN}Scanning best WARP IPv4 IPs...${RESET}"
  found=0
  for i in {1..100}; do
    IP="162.159.$((RANDOM % 256)).$((RANDOM % 256))"
    PORT=$(shuf -n 1 -e 80 443 8080 8443 2053 2083 2087 2096)
    ping_time=$(ping -c1 -W1 $IP | grep 'time=' | sed -E 's/.*time=([0-9.]+) ms/\1/')
    if [[ ! -z "$ping_time" ]]; then
      echo "${GREEN}$IP:$PORT${RESET}  Ping: ${YELLOW}${ping_time}ms${RESET}"
      ((found++))
    fi
    [[ $found -ge 10 ]] && break
  done
  [[ $found -eq 0 ]] && echo "${RED}❌ No working IPs found.${RESET}"
  echo
  read -p "Press Enter to return..."
}

function telegram_proxies() {
  echo
  echo "${CYAN}Fetching Telegram proxies...${RESET}"
  proxies=$(curl -s "https://api.openproxylist.xyz/tg" | jq -r '.[] | "tg://proxy?server=\(.host)&port=\(.port)&secret=\(.secret)"' | head -n 10)
  if [[ -z "$proxies" ]]; then
    echo "${RED}No proxies found.${RESET}"
  else
    echo "${GREEN}$proxies${RESET}"
  fi
  echo
  read -p "Press Enter to return..."
}

function main() {
  header
  install_requirements
  while true; do
    header
    menu
  done
}

main
