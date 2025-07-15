#!/bin/bash

# 🌐 AcademiVPN Warp Panel | Version 1.3.0
# Channel: @AcademiVPN | Support: @MahdiAGM0

# 🎨 Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# 🧱 Install required packages
install_dependencies() {
  pkgs=(curl grep sed jq)
  for pkg in "${pkgs[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
      echo -e "${YELLOW}[INFO] Installing $pkg...${RESET}"
      pkg install -y "$pkg" 2>/dev/null || apt install -y "$pkg"
    fi
  done
}

# 📦 Install launcher
install_launcher() {
  cp "$0" /data/data/com.termux/files/usr/bin/Academivpn_warp 2>/dev/null || cp "$0" /usr/local/bin/Academivpn_warp
  chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp 2>/dev/null || chmod +x /usr/local/bin/Academivpn_warp
  echo -e "${GREEN}✅ Installed launcher: Academivpn_warp${RESET}"
}

# ❌ Remove launcher
remove_launcher() {
  rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp /usr/local/bin/Academivpn_warp
  echo -e "${RED}❌ Removed launcher: Academivpn_warp${RESET}"
}

# 🌐 Telegram Proxy Fetcher
fetch_proxies() {
  echo -e "${CYAN}Fetching fresh Telegram MTProto proxies...${RESET}"

  sources=(
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://raw.githubusercontent.com/Azd325/Telegram-Proxy/master/tg.txt"
    "https://raw.githubusercontent.com/shellhub/tg-proxy-list/main/list.txt"
    "https://raw.githubusercontent.com/zaaero/proxy-list/main/telegram.txt"
    "https://raw.githubusercontent.com/hookzof/proxy-list/master/mtproto.txt"
  )

  proxies=""
  for src in "${sources[@]}"; do
    temp=$(curl -s --max-time 10 "$src" | grep -Eo 'tg://proxy\?server=.*?(&port=.*?)?(&secret=.*?)?' || true)
    [[ -n "$temp" ]] && proxies+=$'\n'"$temp"
  done

  final=$(echo "$proxies" | grep '^tg://' | sort -u | shuf | head -n 10)

  if [[ -z "$final" ]]; then
    echo -e "${RED}❌ Failed to fetch MTProto proxies.${RESET}"
  else
    echo -e "${GREEN}✅ Top 10 Telegram Proxies:${RESET}"
    echo "$final"
  fi
}

# 🔍 WARP IP Scanner (Simulated, randomized)
warp_scanner() {
  echo -e "${CYAN}Generating random Cloudflare WARP IPs...${RESET}"
  for i in {1..10}; do
    ip="162.$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
    port=$((RANDOM % 65535 + 1))
    echo -e "${GREEN}➤ $ip:$port${RESET}"
  done
}

# 📋 Main menu
main_menu() {
  clear
  echo -e "${CYAN}┌──────────────────────────────────────────┐"
  echo -e "${CYAN}│    AcademiVPN WARP Panel - v1.3.0        │"
  echo -e "${CYAN}├──────────────────────────────────────────┤"
  echo -e "${CYAN}│ Channel: @AcademiVPN                     │"
  echo -e "${CYAN}│ Support: @MahdiAGM0                      │"
  echo -e "${CYAN}└──────────────────────────────────────────┘${RESET}"
  echo
  echo -e "${YELLOW}[1]${RESET} Get Telegram MTProto Proxies"
  echo -e "${YELLOW}[2]${RESET} Generate Random WARP IPs"
  echo -e "${YELLOW}[3]${RESET} Install 'Academivpn_warp' Launcher"
  echo -e "${YELLOW}[4]${RESET} Remove 'Academivpn_warp'"
  echo -e "${YELLOW}[5]${RESET} Exit"
  echo
  read -p $'\033[1;36mSelect an option: \033[0m' choice

  case "$choice" in
    1) fetch_proxies ;;
    2) warp_scanner ;;
    3) install_launcher ;;
    4) remove_launcher ;;
    5) exit 0 ;;
    *) echo -e "${RED}Invalid choice.${RESET}" ;;
  esac

  echo
  read -p "Press Enter to return to menu..."
  main_menu
}

# 🚀 Start script
install_dependencies
main_menu
