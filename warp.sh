#!/bin/bash

# Colors
RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; CYAN='\e[36m'; NC='\e[0m'

# Title
show_title() {
  clear
  echo -e "${CYAN}╔════════════════════════════════════╗"
  echo -e "║   Academi VPN MultiTool           ║"
  echo -e "║   Telegram: @Academi_vpn          ║"
  echo -e "║   Admin:    @MahdiAGM0            ║"
  echo -e "║   Version:  1.6.7                 ║"
  echo -e "╚════════════════════════════════════╝${NC}"
}

# Install dependencies
install_dependencies() {
  echo -e "${YELLOW}Installing required packages...${NC}"
  pkg update -y >/dev/null 2>&1
  pkg install curl jq coreutils -y >/dev/null 2>&1
  echo -e "${GREEN}✅ Dependencies installed!${NC}"
}

# Warp IP:Port Scanner
warp_scanner() {
  echo -e "${CYAN}🔍 Generating WARP IP:PORT with ping...${NC}"
  for i in {1..10}; do
    ip=$(shuf -i 1-255 -n 4 | paste -sd '.')
    port=$((RANDOM % 65535 + 1))
    ping_result=$(ping -c 1 -W 1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [ -n "$ping_result" ]; then
      echo -e "${GREEN}IP:$ip Port:$port Ping: ${ping_result}ms${NC}"
    else
      echo -e "${YELLOW}IP:$ip Port:$port Ping: Timeout${NC}"
    fi
  done
}

# Telegram Proxy Fetcher
fetch_proxies() {
  echo -e "${CYAN}🔄 Fetching Telegram proxies...${NC}"
  sources=(
    "https://raw.githubusercontent.com/hamid-gh/telegram-proxy-list/main/tg.txt"
    "https://raw.githubusercontent.com/erfannoori/proxy/main/proxy.txt"
    "https://raw.githubusercontent.com/mmpx12/proxy-list/master/telegram.txt"
  )

  all_proxies=""
  for url in "${sources[@]}"; do
    new_proxies=$(curl -s "$url" | grep -E '^tg://')
    all_proxies+="$new_proxies"$'\n'
  done

  filtered=$(echo "$all_proxies" | grep -E '^tg://' | sort -u | head -n 10)

  if [[ -z "$filtered" ]]; then
    echo -e "${RED}❌ No working Telegram proxies found.${NC}"
    return
  fi

  i=1
  > /etc/academivpn_proxies.txt
  while read -r proxy; do
    echo -e "${GREEN}Proxy $i: $proxy${NC}"
    echo "Proxy $i: $proxy" >> /etc/academivpn_proxies.txt
    ((i++))
  done <<< "$filtered"
}

# Installer toggle
installer_menu() {
  echo -e "${CYAN}Installer options:${NC}"
  echo "1. Install launcher (Academivpn_warp)"
  echo "2. Remove launcher"
  echo "3. Back"
  read -p "Choose: " choice
  case $choice in
    1)
      echo -e "#!/data/data/com.termux/files/usr/bin/bash" > /data/data/com.termux/files/usr/bin/Academivpn_warp
      echo -e "bash ~/warp.sh" >> /data/data/com.termux/files/usr/bin/Academivpn_warp
      chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
      echo -e "${GREEN}✅ Installed! Now use: Academivpn_warp${NC}"
      ;;
    2)
      rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
      echo -e "${YELLOW}❌ Launcher removed.${NC}"
      ;;
    3) return ;;
    *) echo "Invalid." ;;
  esac
}

# Main menu
main_menu() {
  while true; do
    show_title
    echo -e "${YELLOW}1) WARP IP:PORT Scanner"
    echo "2) Telegram Proxy Fetcher"
    echo "3) Installer Settings"
    echo "4) Exit${NC}"
    read -p "Choose: " opt
    case $opt in
      1) warp_scanner ;;
      2) fetch_proxies ;;
      3) installer_menu ;;
      4) echo -e "${CYAN}Exiting...${NC}"; exit 0 ;;
      *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press Enter to return to menu..."
  done
}

# Run
install_dependencies
main_menu
