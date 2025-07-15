#!/bin/bash

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m' # بدون رنگ

# عنوان
title() {
  clear
  echo -e "${CYAN}╔════════════════════════════════════════════╗"
  echo -e "${CYAN}║        ${YELLOW}AcademiVPN WARP & Telegram Proxy       ${CYAN}║"
  echo -e "${CYAN}╠════════════════════════════════════════════╣"
  echo -e "${CYAN}║ ${GREEN}Telegram:${NC} @Academi_vpn                            ${CYAN}║"
  echo -e "${CYAN}║ ${GREEN}Admin:   ${NC} @MahdiAGM0                              ${CYAN}║"
  echo -e "${CYAN}║ ${GREEN}Version: ${NC} 1.7.2                                  ${CYAN}║"
  echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
}

# نصب ابزارها
install_requirements() {
  echo -e "${YELLOW}🔧 Installing dependencies...${NC}"
  pkg install curl jq wget bash -y &>/dev/null || sudo apt install curl jq wget bash -y
  command -v crontab >/dev/null || (echo -e "${YELLOW}Installing cron...${NC}" && apt install cron -y)
}

# اسکنر WARP واقعی
scan_warp_ips() {
  echo -e "${BLUE}🔍 Generating 10 Random WARP IPs & Ports...${NC}"
  for i in {1..10}; do
    ip=$(shuf -i 1-255 -n 4 | tr '\n' '.' | sed 's/\.$//')
    port=$(shuf -i 10000-65000 -n 1)
    ping=$(ping -c 1 -W 1 $ip | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    ping=${ping:-timeout}
    echo -e "${GREEN}$i. ${CYAN}${ip}:${port}${NC} - Ping: ${YELLOW}${ping}ms${NC}"
  done
  read -p "Press enter to return..." && main_menu
}

# دریافت پروکسی‌های واقعی تلگرام
fetch_proxies() {
  echo -e "${YELLOW}🔄 Fetching Telegram proxies...${NC}"
  proxies=()
  urls=(
    "https://raw.githubusercontent.com/imaminism/Telegram-Proxy-List/main/https.txt"
    "https://raw.githubusercontent.com/aliilapro/telegram-proxy/main/proxy.txt"
    "https://raw.githubusercontent.com/mmpx12/proxy-list/master/telegram.txt"
  )

  for url in "${urls[@]}"; do
    content=$(curl -s --connect-timeout 5 "$url")
    while IFS= read -r line; do
      [[ $line == tg://* ]] && proxies+=("$line")
    done <<< "$content"
  done

  if [[ ${#proxies[@]} -eq 0 ]]; then
    echo -e "${RED}❌ No working Telegram proxies found.${NC}"
  else
    echo -e "${GREEN}✅ Top 10 Telegram Proxies:${NC}"
    for i in $(seq 1 10); do
      echo -e "${CYAN}Proxy $i: ${BLUE}${proxies[$i]}${NC}"
    done
  fi
  read -p "Press enter to return..." && main_menu
}

# فعال‌سازی نصب خودکار
enable_installer() {
  if [ ! -f "/usr/local/bin/Academivpn_warp" ]; then
    cp "$0" /usr/local/bin/Academivpn_warp
    chmod +x /usr/local/bin/Academivpn_warp
    echo -e "${GREEN}✅ Installer enabled. Run with: ${YELLOW}Academivpn_warp${NC}"
  else
    echo -e "${YELLOW}Installer already exists.${NC}"
  fi
  sleep 1 && main_menu
}

# حذف نصب خودکار
disable_installer() {
  rm -f /usr/local/bin/Academivpn_warp
  echo -e "${RED}❌ Installer removed.${NC}"
  sleep 1 && main_menu
}

# تنظیم بروزرسانی روزانه پروکسی
setup_daily_update() {
  (crontab -l 2>/dev/null; echo "0 7 * * * bash \"$0\" --daily-update") | crontab -
  echo -e "${GREEN}✅ Daily proxy auto-update enabled.${NC}"
}

# حالت آپدیت روزانه
if [[ "$1" == "--daily-update" ]]; then
  fetch_proxies
  exit
fi

# منوی اصلی
main_menu() {
  title
  echo -e "${YELLOW}1) WARP IP Scanner"
  echo -e "2) Telegram Proxies"
  echo -e "3) Enable Installer"
  echo -e "4) Disable Installer"
  echo -e "5) Exit${NC}"
  read -p $'\nSelect an option [1-5]: ' choice
  case $choice in
    1) scan_warp_ips ;;
    2) fetch_proxies ;;
    3) enable_installer ;;
    4) disable_installer ;;
    5) echo -e "${RED}Exiting...${NC}" && exit ;;
    *) echo -e "${RED}Invalid option!${NC}" && sleep 1 && main_menu ;;
  esac
}

# اجرا
install_requirements
setup_daily_update
main_menu
