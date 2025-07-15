#!/bin/bash

# ╔═══════════════════════════════════════╗
# ║ Academi Tool - Version 1.0.5         ║
# ║ Channel: @Academi_vpn                ║
# ║ Support: @MahdiAGM0                  ║
# ╚═══════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# پورت‌های مهم
PORTS=(80 443 8080 8443 2083 2087 2053 2095 2096 8880)

# رنج‌های واقعی WARP
RANGES=(
  "162.159.192"
  "162.159.193"
  "162.159.195"
  "188.114.96"
  "188.114.97"
  "188.114.98"
)

# نصب ابزارها
install_deps() {
  for pkg in curl timeout ping jq; do
    if ! command -v $pkg &>/dev/null; then
      echo -e "${YELLOW}Installing $pkg...${NC}"
      apt update -y &>/dev/null
      apt install -y $pkg &>/dev/null
    fi
  done
}

# تست IP و پورت
test_ip() {
  ip=$1
  for port in "${PORTS[@]}"; do
    timeout 1 bash -c "</dev/tcp/$ip/$port" &>/dev/null
    if [ $? -eq 0 ]; then
      ping_ms=$(ping -c 1 -W 1 $ip | grep "time=" | awk -F'time=' '{print $2}' | cut -d' ' -f1)
      if [[ $ping_ms != "" ]]; then
        echo -e "${GREEN}${ip}:${port}${NC}  Ping: ${ping_ms}ms"
        return 0
      fi
    fi
  done
  return 1
}

# ساخت IPهای رندوم از رنج‌ها
generate_ips() {
  base=$1
  for i in $(shuf -i 2-254 -n 20); do
    echo "${base}.${i}"
  done
}

# اسکن IPهای WARP
warp_scan() {
  echo -e "\n${CYAN}🔍 Scanning best WARP IPv4 IPs...${NC}"
  count=0
  found=0
  for range in "${RANGES[@]}"; do
    for ip in $(generate_ips "$range"); do
      test_ip "$ip" &
      ((count++))
      if [ "$count" -ge 300 ]; then break 2; fi
      sleep 0.1
    done
  done
  wait
}

# دریافت پروکسی از چند منبع
get_proxies() {
  echo -e "\n${CYAN}🌍 Fetching fresh Telegram proxies...${NC}"
  proxies=""
  sources=(
    "https://api.openproxy.space/lists/telegram/all.txt"
    "https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/http.txt"
    "https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/txt/proxies-http.txt"
  )

  for src in "${sources[@]}"; do
    tmp=$(curl -s "$src" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | head -n 10)
    if [[ -n "$tmp" ]]; then
      proxies+="$tmp"$'\n'
    fi
  done

  final=$(echo "$proxies" | sort -u | head -n 10)
  if [[ -z "$final" ]]; then
    echo -e "${RED}❌ No proxies found.${NC}"
  else
    echo -e "${GREEN}✔ Found Proxies:${NC}"
    echo "$final" | nl
  fi
}

# منوی اصلی
main_menu() {
  clear
  echo -e "${YELLOW}╔═══════════════════════════════════════╗"
  echo -e "║        Academi Tool - v1.0.5          ║"
  echo -e "║  Channel: @Academi_vpn                ║"
  echo -e "║  Support: @MahdiAGM0                  ║"
  echo -e "╚═══════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}1.${NC} WARP IPv4 IP Scanner"
  echo -e "${CYAN}2.${NC} Telegram Proxy Updater"
  echo -e "${CYAN}0.${NC} Exit"
  echo -ne "\nSelect: "; read opt

  case "$opt" in
    1) warp_scan ;;
    2) get_proxies ;;
    0) echo -e "${YELLOW}Bye!${NC}"; exit ;;
    *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
  esac
}

# اجرای برنامه
install_deps
while true; do main_menu; echo -e "\nPress enter to return to menu..."; read; done
