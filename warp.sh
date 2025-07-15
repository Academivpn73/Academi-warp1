#!/bin/bash

# ════[ رنگ‌ها ]════
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
NC="\e[0m"

# ════[ هدر ]════
clear
echo -e "${CYAN}╔════════════════════════════════════════════════════╗"
echo -e "║     ${GREEN}Academi WARP Toolkit ${YELLOW}v1.1.0${CYAN}                  ║"
echo -e "║ ${NC}Channel: @Academi_vpn   ${CYAN}Support: @MahdiAGM0        ║"
echo -e "╚════════════════════════════════════════════════════╝${NC}"
echo ""

# ════[ نصب ابزارها ]════
install_dependencies() {
  echo -e "${YELLOW}🔧 Installing requirements...${NC}"
  pkg update -y >/dev/null 2>&1
  pkg install curl jq wireguard -y >/dev/null 2>&1
  if ! command -v wgcf &>/dev/null; then
    curl -sL https://github.com/ViRb3/wgcf/releases/latest/download/wgcf_$(uname -m | sed 's/aarch64/arm64/;s/armv7l/armv6l/') -o wgcf
    chmod +x wgcf
    mv wgcf /data/data/com.termux/files/usr/bin/
  fi
}

# ════[ بخش پروکسی تلگرام ]════
telegram_proxy_fetcher() {
  echo -e "${CYAN}\n🌐 Fetching fresh Telegram proxies...${NC}"
  sources=(
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/tg/mtproto.txt"
    "https://raw.githubusercontent.com/ejnv/freemtproto/main/proxies.txt"
  )
  for url in "${sources[@]}"; do
    proxies=$(curl -s --max-time 5 "$url" | grep '^tg://' | head -n 10)
    if [[ -n "$proxies" ]]; then
      echo -e "${GREEN}✔ Found proxies from $url:${NC}"
      echo "$proxies" | nl -w2 -s'. '
      return
    fi
  done
  echo -e "${RED}❌ No working proxies found.${NC}"
}

# ════[ بخش اسکن WARP IP ]════
warp_scanner() {
  echo -e "${CYAN}\n🔍 Scanning best WARP IPv4 IPs...${NC}"
  cidr_blocks=("162.159.192.0/24" "188.114.96.0/24")
  ips=()
  while [[ ${#ips[@]} -lt 10 ]]; do
    cidr=${cidr_blocks[$RANDOM % ${#cidr_blocks[@]}]}
    base=$(echo "$cidr" | cut -d'/' -f1 | cut -d'.' -f1-3)
    for i in $(seq 1 254); do
      ip="${base}.${i}"
      port=$((RANDOM % 65535 + 1))
      ping=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
      if [[ -n "$ping" ]]; then
        echo -e "${GREEN}✔ $ip:$port  Ping: ${ping}ms${NC}"
        ips+=("$ip:$port")
        if [[ ${#ips[@]} -ge 10 ]]; then break; fi
      fi
    done
    [[ ${#ips[@]} -ge 10 ]] && break
  done
  [[ ${#ips[@]} -eq 0 ]] && echo -e "${RED}❌ No responsive IPs found.${NC}"
}

# ════[ ساخت کانفیگ واقعی وایرگارد ]════
generate_wireguard_config() {
  echo -e "${CYAN}\n🛠 Generating real WireGuard config via Cloudflare...${NC}"
  mkdir -p ~/wg_academi
  cd ~/wg_academi || return
  wgcf register --accept-tos >/dev/null 2>&1
  wgcf generate >/dev/null 2>&1
  if [[ -f wgcf-profile.conf ]]; then
    echo -e "${GREEN}✔ WireGuard config generated at ~/wg_academi/wgcf-profile.conf${NC}"
    echo ""
    cat wgcf-profile.conf | grep -v '^#' | head -n 20
  else
    echo -e "${RED}❌ Failed to generate config.${NC}"
  fi
}

# ════[ منوی اصلی ]════
main_menu() {
  echo -e "\n${CYAN}Select an option:${NC}"
  echo -e " 1️⃣  WARP IPv4 Scanner"
  echo -e " 2️⃣  Telegram Proxies"
  echo -e " 3️⃣  Generate Real WireGuard Config"
  echo -e " 0️⃣  Exit"
  echo -en "${YELLOW}\nEnter choice: ${NC}"
  read choice
  case $choice in
    1) warp_scanner ;;
    2) telegram_proxy_fetcher ;;
    3) generate_wireguard_config ;;
    0) exit 0 ;;
    *) echo -e "${RED}❌ Invalid choice!${NC}" && sleep 1 && main_menu ;;
  esac
}

# ════[ نصب شورتکات ]════
installer_setup() {
  chmod +x "$0"
  cp "$0" /data/data/com.termux/files/usr/bin/Academi_warp 2>/dev/null
  echo -e "${GREEN}✔ You can now run this script with: ${CYAN}Academi_warp${NC}"
}

# ════[ اجرا ]════
install_dependencies
installer_setup
main_menu
