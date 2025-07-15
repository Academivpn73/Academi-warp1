#!/bin/bash

# ───── رنگ‌ها ─────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# ───── تایتل ─────
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}         Telegram Channel:${NC} ${CYAN}@Academi_vpn${NC}"
echo -e "${GREEN}         Admin:${NC}           ${GREEN}@MahdiAGM0${NC}"
echo -e "${YELLOW}         Version:${NC}         ${YELLOW}1.7.4${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ───── نصب اتومات پکیج‌ها ─────
for pkg in curl jq cron; do
  if ! command -v $pkg &> /dev/null; then
    echo -e "${YELLOW}Installing ${pkg}...${NC}"
    apt install -y $pkg &>/dev/null
  fi
done

# ───── اسکنر وارپ ─────
warp_scan() {
  echo -e "${GREEN}⏳ Scanning 10 random WARP IPs...${NC}"
  for i in {1..10}; do
    ip="1.$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
    port=$((RANDOM % 64512 + 1024))
    ping=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -z "$ping" ]]; then ping="timeout"; fi
    echo -e "${CYAN}IP $i:${NC} ${ip}:${port}  ${YELLOW}Ping:${NC} ${ping} ms"
  done
  read -p "Press enter to return..." && main_menu
}

# ───── دریافت پروکسی تلگرام ─────
fetch_proxies() {
  echo -e "${YELLOW}🔄 Fetching Telegram proxies...${NC}"
  proxies=()
  urls=(
    "https://raw.githubusercontent.com/TelegramProxies/proxies/main/proxies.txt"
    "https://raw.githubusercontent.com/mmpx12/proxy-list/master/telegram.txt"
    "https://raw.githubusercontent.com/imaminism/Telegram-Proxy-List/main/https.txt"
    "https://raw.githubusercontent.com/aliilapro/telegram-proxy/main/proxy.txt"
    "https://raw.githubusercontent.com/prxchk/proxy-list/main/tg.txt"
    "https://raw.githubusercontent.com/officialputuid/KangProxy/KangList/tg.txt"
    # (در نسخه پایدار نهایی می‌توان این تعداد را به 900 رساند)
  )

  for url in "${urls[@]}"; do
    response=$(curl -s --connect-timeout 5 "$url")
    if [[ $? -eq 0 && -n "$response" ]]; then
      while IFS= read -r line; do
        [[ "$line" =~ ^tg://proxy\?server= ]] && proxies+=("$line")
      done <<< "$response"
    fi
  done

  if [[ ${#proxies[@]} -eq 0 ]]; then
    echo -e "${RED}❌ No working Telegram proxies found.${NC}"
  else
    echo -e "${GREEN}✅ Found ${#proxies[@]} Telegram proxies.${NC}"
    for i in $(seq 1 10); do
      echo -e "${CYAN}Proxy $i:${NC} ${proxies[$i]}"
    done
  fi
  read -p "Press enter to return..." && main_menu
}

# ───── ستاپ کرون برای آپدیت روزانه ─────
setup_daily_cron() {
  cron_job="0 6 * * * bash /root/Academivpn_warp.sh >/dev/null 2>&1"
  (crontab -l 2>/dev/null | grep -v 'Academivpn_warp.sh'; echo "$cron_job") | crontab -
}

# ───── نصب دستور میانبر ─────
create_installer() {
  echo -e "#!/bin/bash
bash /root/Academivpn_warp.sh" > /usr/bin/Academivpn_warp
  chmod +x /usr/bin/Academivpn_warp
  echo -e "${GREEN}✅ Installer command added: ${CYAN}Academivpn_warp${NC}"
}

delete_installer() {
  rm -f /usr/bin/Academivpn_warp
  echo -e "${RED}❌ Installer removed.${NC}"
}

# ───── منوی اصلی ─────
main_menu() {
  clear
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}         Telegram Channel:${NC} ${CYAN}@Academi_vpn${NC}"
  echo -e "${GREEN}         Admin:${NC}           ${GREEN}@MahdiAGM0${NC}"
  echo -e "${YELLOW}         Version:${NC}         ${YELLOW}1.7.4${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}[1]${NC} WARP IP Scanner"
  echo -e "${GREEN}[2]${NC} Telegram Proxy Fetcher"
  echo -e "${GREEN}[3]${NC} Create Installer"
  echo -e "${GREEN}[4]${NC} Remove Installer"
  echo -e "${GREEN}[5]${NC} Exit"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  read -p "🎯 Choose an option [1-5]: " choice

  case "$choice" in
    1) warp_scan ;;
    2) fetch_proxies ;;
    3) create_installer ;;
    4) delete_installer ;;
    5) exit 0 ;;
    *) echo -e "${RED}❌ Invalid choice!${NC}" && sleep 1 && main_menu ;;
  esac
}

# ───── اجرای اولیه ─────
setup_daily_cron
main_menu
