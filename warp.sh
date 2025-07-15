#!/data/data/com.termux/files/usr/bin/bash

# ════ Academi WARP Toolkit v1.1.0 ════
VERSION="1.1.0"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

GREEN="\e[32m"; RED="\e[31m"; CYAN="\e[36m"; YELLOW="\e[33m"; NC="\e[0m"

install_dependencies() {
  echo -e "${YELLOW}🔧 در حال نصب ابزارهای مورد نیاز...${NC}"
  pkg update -y >/dev/null 2>&1
  pkg install -y curl jq wireguard >/dev/null 2>&1
  if ! command -v wgcf &>/dev/null; then
    wget -qO wgcf "https://github.com/ViRb3/wgcf/releases/latest/download/wgcf_$(uname -m | sed 's/aarch64/arm64/;s/armv7l/armv6l/')"
    chmod +x wgcf
    mv wgcf /data/data/com.termux/files/usr/bin/
  fi
}

telegram_proxy_fetcher() {
  echo -e "${CYAN}\n🌐 در حال بارگذاری پروکسی‌های تلگرام...${NC}"
  sources=(
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/tg/mtproto.txt"
    "https://raw.githubusercontent.com/TheSpeedX/TBomb/master/core/proxies/mtproto.txt"
  )
  for url in "${sources[@]}"; do
    proxies=$(curl -s --max-time 5 "$url" | grep '^tg://' | head -n 10)
    if [[ -n "$proxies" ]]; then
      echo -e "${GREEN}✔ پروکسی‌های سالم از $url:${NC}"
      echo "$proxies" | nl -w2 -s'. '
      return
    fi
  done
  echo -e "${RED}❌ پروکسی‌ی سالمی یافت نشد.${NC}"
}

warp_scanner() {
  echo -e "${CYAN}\n🔍 اسکن IPهای واقعی WARP IPv4...${NC}"
  cidr_blocks=("162.159.192.0/24" "162.159.193.0/24" "162.159.195.0/24" "188.114.96.0/24" "188.114.97.0/24")
  found=0
  while [[ $found -lt 10 ]]; do
    block=${cidr_blocks[$RANDOM % ${#cidr_blocks[@]}]}
    base=$(echo "$block" | cut -d'/' -f1 | cut -d'.' -f1-3)
    for i in $(shuf -i 1-254 -n 15); do
      ip="${base}.${i}"
      port=$(( (RANDOM % 65535) + 1 ))
      ping_ms=$(ping -c1 -W1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
      if [[ -n "$ping_ms" ]]; then
        echo -e "${GREEN}✔ $ip:$port  Ping: ${ping_ms}ms${NC}"
        ((found++))
        break
      fi
    done
  done
}

generate_wireguard_config() {
  echo -e "${CYAN}\n🛠 در حال ساخت کانفیگ WireGuard واقعی...${NC}"
  mkdir -p "$HOME/wg_academi"
  cd "$HOME/wg_academi" || return
  wgcf register --accept-tos >/dev/null 2>&1
  wgcf generate >/dev/null 2>&1
  if [[ -f wgcf-profile.conf ]]; then
    echo -e "${GREEN}✔ کانفیگ ساخته‌شد در:${NC} $HOME/wg_academi/wgcf-profile.conf"
    echo -e "\n----- نمایشی از کانفیگ (۲۰ خط اول) -----\n"
    head -n 20 wgcf-profile.conf
  else
    echo -e "${RED}❌ ساخت کانفیگ ناموفق بود.${NC}"
  fi
}

installer_setup() {
  chmod +x "$0"
  cp "$0" /data/data/com.termux/files/usr/bin/Academi_warp 2>/dev/null
  echo -e "${GREEN}✔ دستور Academi_warp نصب شد. حالا فقط تایپ کن:${NC} Academi_warp"
}

main_menu() {
  clear
  echo -e "${YELLOW}Academi WARP Toolkit v${VERSION}${NC}"
  echo -e "${CYAN}Channel:${NC} ${CHANNEL}   ${CYAN}Support:${NC} ${ADMIN}"
  echo ""
  echo -e "${CYAN}1) WARP IPv4 Scanner"
  echo -e "2) Telegram Proxy List"
  echo -e "3) Generate Real WireGuard Config"
  echo -e "0) Exit"
  echo -en "\n${YELLOW}>>> ${NC}"
  read choice
  case "$choice" in
    1) warp_scanner ;;
    2) telegram_proxy_fetcher ;;
    3) generate_wireguard_config ;;
    0) exit 0 ;;
    *) echo -e "${RED}❌ انتخاب نامعتبر!${NC}"; sleep 1 ;;
  esac
  echo -e "\n${CYAN}Press Enter to return to menu...${NC}"
  read
  main_menu
}

install_dependencies
installer_setup
main_menu
