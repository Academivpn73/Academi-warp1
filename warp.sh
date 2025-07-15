#!/bin/bash

VERSION="1.0.1"
CHANNEL_ID="@Academi_vpn"
SUPPORT_ID="@MahdiAGM0"

# رنگ‌ها
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

# هدر برنامه
print_header() {
  clear
  echo -e "${GREEN}╔══════════════════════════════════════╗"
  echo -e "║        WARP IP Scanner v$VERSION          ║"
  echo -e "╠══════════════════════════════════════╣"
  echo -e "║  Channel : $CHANNEL_ID"
  echo -e "║  Support : $SUPPORT_ID"
  echo -e "╚══════════════════════════════════════╝${NC}"
  echo ""
}

# نصب ابزارها
install_requirements() {
  apt update -y &>/dev/null
  apt install -y iputils-ping curl &>/dev/null
}

# اسکنر WARP
warp_ip_scanner() {
  print_header
  echo -e "🌐 Scanning best WARP IPv4 IPs...\n"

  mkdir -p warp_tmp
  > warp_tmp/valid_ips.txt

  PORTS=(80 443 8443 2083 2096)
  COUNT=0

  for ip_prefix in 162.159.192 162.159.193 188.114.96 188.114.97; do
    for i in {1..254}; do
      ip="$ip_prefix.$i"
      for port in "${PORTS[@]}"; do
        ping_ms=$(ping -c1 -W1 $ip | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [[ -n "$ping_ms" ]]; then
          echo "$ip:$port  ${ping_ms}ms" >> warp_tmp/valid_ips.txt
          echo -e "${GREEN}$ip:$port  ${ping_ms}ms${NC}"
          ((COUNT++))
          break
        fi
      done
      [[ $COUNT -ge 10 ]] && break
    done
    [[ $COUNT -ge 10 ]] && break
  done

  if [[ $COUNT -eq 0 ]]; then
    echo -e "${RED}❌ No working WARP IPs found.${NC}"
  else
    echo -e "\n✅ Top $COUNT Working WARP IPs:"
    cat warp_tmp/valid_ips.txt
  fi

  echo
  read -p "Press Enter to return to menu..."
}

# نمایش لیست پروکسی تلگرام
proxy_list() {
  print_header
  echo -e "🌍 Today's Telegram Proxy List:\n"

  # این بخش قابل آپدیت روزانه‌ست. می‌تونی دستی یا از API پرش کنی.
  curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt | head -n 10 || {
    echo "tg://proxy?server=proxy1.example.com&port=443&secret=ee00000000000000000000000000000000000000"
    echo "tg://proxy?server=proxy2.example.com&port=443&secret=ee00000000000000000000000000000000000000"
  }

  echo
  read -p "Press Enter to return to menu..."
}

# منو اصلی
main_menu() {
  while true; do
    print_header
    echo "1️⃣  WARP IPv4 Scanner"
    echo "2️⃣  Telegram Proxy List"
    echo "0️⃣  Exit"
    echo
    read -p "Select an option: " choice

    case $choice in
      1) warp_ip_scanner ;;
      2) proxy_list ;;
      0) echo -e "\nExiting... 👋"; exit 0 ;;
      *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
    esac
  done
}

# اجرای اولیه
install_requirements
main_menu
