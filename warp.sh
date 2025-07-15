#!/bin/bash

# ╔═══════════════════════════════════════╗
# ║ Academi Tool - Version 1.0.4         ║
# ║ Channel: @Academi_vpn                ║
# ║ Support: @MahdiAGM0                  ║
# ╚═══════════════════════════════════════╝

# ---- رنگ‌ها ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---- پورت‌های مهم ----
COMMON_PORTS=(80 443 2083 2087 8443 2053 2096 2095 8080 8880)

# ---- رنج‌های واقعی WARP IPv4 ----
WARP_RANGES=(
  "162.159.192"
  "162.159.193"
  "162.159.195"
  "188.114.96"
  "188.114.97"
  "188.114.98"
)

# ---- نصب وابستگی‌ها ----
install_deps() {
  for pkg in curl timeout ping jq; do
    if ! command -v $pkg &>/dev/null; then
      echo -e "${YELLOW}Installing $pkg...${NC}"
      apt update -y &>/dev/null
      apt install -y $pkg &>/dev/null
    fi
  done
}

# ---- تابع تست آی‌پی ----
check_ip() {
  ip=$1
  for port in "${COMMON_PORTS[@]}"; do
    timeout 1 bash -c "</dev/tcp/$ip/$port" &>/dev/null
    if [ $? -eq 0 ]; then
      ping_ms=$(ping -c 1 -W 1 $ip | grep "time=" | awk -F'time=' '{print $2}' | cut -d' ' -f1)
      if [ -n "$ping_ms" ]; then
        echo -e "${GREEN}${ip}:${port}${NC}  Ping: ${ping_ms}ms"
        return 0
      fi
    fi
  done
  return 1
}

# ---- تولید آی‌پی از رنج ----
generate_ips() {
  base=$1
  for i in $(shuf -i 1-254 -n 30); do
    echo "${base}.${i}"
  done
}

# ---- اسکن WARP ----
warp_scan() {
  echo -e "${CYAN}Scanning best WARP IPv4 IPs...${NC}"
  count=0
  for base in "${WARP_RANGES[@]}"; do
    ips=$(generate_ips "$base")
    for ip in $ips; do
      check_ip "$ip" &
      sleep 0.1
      ((count++))
      if [ $count -ge 300 ]; then break 2; fi
    done
  done
  wait
}

# ---- دریافت پروکسی تلگرام ----
get_proxies() {
  echo -e "\n${CYAN}Fetching Telegram proxies...${NC}"
  proxies=$(curl -s https://api.openproxy.space/lists/telegram/all.txt | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | head -n 10)
  if [ -z "$proxies" ]; then
    echo -e "${RED}❌ No proxies found.${NC}"
  else
    echo -e "${GREEN}✔ Top 10 Telegram Proxies:${NC}"
    echo "$proxies" | nl
  fi
}

# ---- منو اصلی ----
main_menu() {
  clear
  echo -e "${YELLOW}╔═══════════════════════════════════════╗"
  echo -e "║        Academi Tool - v1.0.4          ║"
  echo -e "║  Channel: @Academi_vpn                ║"
  echo -e "║  Support: @MahdiAGM0                  ║"
  echo -e "╚═══════════════════════════════════════╝${NC}\n"

  echo -e "${CYAN}1.${NC} WARP IPv4 Scanner"
  echo -e "${CYAN}2.${NC} Telegram Proxy List"
  echo -e "${CYAN}0.${NC} Exit"
  echo -ne "\nSelect: "; read choice

  case "$choice" in
    1) warp_scan ;;
    2) get_proxies ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
  esac
}

# ---- اجرا ----
install_deps
while true; do main_menu; echo -e "\nPress Enter to return..."; read; done
