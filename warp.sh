#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Info
VERSION="1.0.5"
CHANNEL="@AcademiVpn"
ADMIN="@MahdiAGM0"

# Installer command alias
INSTALLER_CMD="Academivpn_warp"

# Auto requirements
auto_install_requirements() {
  echo -e "${CYAN}Installing required packages...${RESET}"
  pkg update -y > /dev/null
  pkg install -y curl jq grep coreutils > /dev/null
}

# Create installer
create_installer() {
  echo -e "${GREEN}Creating installer command: ${INSTALLER_CMD}${RESET}"
  cat > "/data/data/com.termux/files/usr/bin/$INSTALLER_CMD" <<- EOF
#!/data/data/com.termux/files/usr/bin/bash
bash ~/warp.sh
EOF
  chmod +x "/data/data/com.termux/files/usr/bin/$INSTALLER_CMD"
  echo -e "${GREEN}✅ Installer created. Run using '${INSTALLER_CMD}'${RESET}"
}

# Remove installer
remove_installer() {
  rm -f "/data/data/com.termux/files/usr/bin/$INSTALLER_CMD"
  echo -e "${RED}❌ Installer removed.${RESET}"
}

# Telegram Proxy Section
fetch_proxies() {
  echo -e "${CYAN}Fetching Telegram MTProto proxies...${RESET}"

  sources=(
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://raw.githubusercontent.com/zaaero/proxy-list/main/telegram.txt"
    "https://raw.githubusercontent.com/hookzof/proxy-list/master/mtproto.txt"
    "https://raw.githubusercontent.com/shellhub/tg-proxy-list/main/list.txt"
  )

  all_proxies=""
  for src in "${sources[@]}"; do
    if curl --head --silent --fail "$src" > /dev/null; then
      content=$(curl -s --max-time 10 "$src")
      matches=$(echo "$content" | grep -Eo 'tg://proxy\?server=.*?(&port=.*?)?(&secret=.*?)?')
      [[ -n "$matches" ]] && all_proxies+=$'\n'"$matches"
    fi
  done

  valid=$(echo "$all_proxies" | grep '^tg://' | sort -u | shuf | head -n 10)

  if [[ -z "$valid" ]]; then
    echo -e "${RED}❌ No valid Telegram proxies found.${RESET}"
  else
    echo -e "${GREEN}✅ Top 10 Telegram Proxies:${RESET}"
    echo "$valid"
  fi
}

# WARP IP Scanner
scan_warp_ips() {
  echo -e "${CYAN}Scanning WARP IPs & Ports...${RESET}"

  BASES=("104.16" "162.159" "188.114" "198.41" "172.67")
  PORTS=(80 443 8080 8443 2052 2053 2082 2083 2086 2095 2096 8880)

  for i in $(seq 1 10); do
    base=${BASES[$RANDOM % ${#BASES[@]}]}
    ip="$base.$((RANDOM % 256)).$((RANDOM % 256))"
    port=${PORTS[$RANDOM % ${#PORTS[@]}]}
    ping_ms=$(ping -c1 -W1 "$ip" | grep 'time=' | sed -E 's/.*time=([0-9.]+).*/\1 ms/')

    if [[ -n "$ping_ms" ]]; then
      echo -e "${GREEN}IP: $ip:$port    Ping: $ping_ms${RESET}"
    else
      echo -e "${RED}IP: $ip:$port    ❌ Unreachable${RESET}"
    fi
  done
}

# Main Menu
main_menu() {
  clear
  echo -e "${YELLOW}Academi VPN WARP Panel  |  Version: $VERSION${RESET}"
  echo -e "${CYAN}Channel: $CHANNEL   Admin: $ADMIN${RESET}"
  echo
  echo -e "${GREEN}[1]${RESET} Telegram Proxy Scraper"
  echo -e "${GREEN}[2]${RESET} WARP IP Scanner"
  echo -e "${GREEN}[3]${RESET} Install Installer Command"
  echo -e "${GREEN}[4]${RESET} Remove Installer Command"
  echo -e "${GREEN}[0]${RESET} Exit"
  echo
  read -p "Select: " choice

  case "$choice" in
    1) fetch_proxies ;;
    2) scan_warp_ips ;;
    3) create_installer ;;
    4) remove_installer ;;
    0) exit ;;
    *) echo -e "${RED}Invalid option.${RESET}" ;;
  esac

  echo
  read -p "Press enter to return to menu..." dummy
  main_menu
}

# Initial setup
auto_install_requirements
main_menu
