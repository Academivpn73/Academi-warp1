#!/data/data/com.termux/files/usr/bin/bash

ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
VERSION="1.6.4"
PROXY_FILE="$HOME/.academi_proxies.txt"
LAST_UPDATE_FILE="$HOME/.proxy_update_time"

# 🎨 Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# 🧩 Dependencies
check_deps() {
  for cmd in curl jq ping timeout; do
    if ! command -v $cmd &>/dev/null; then
      pkg install -y $cmd
    fi
  done
}

# 📦 Launcher
install_launcher() {
  cp "$0" "$PREFIX/bin/Academivpn_warp"
  chmod +x "$PREFIX/bin/Academivpn_warp"
  echo -e "${GREEN}✅ Installed launcher: Academivpn_warp${RESET}"
}

remove_launcher() {
  rm -f "$PREFIX/bin/Academivpn_warp"
  echo -e "${RED}✅ Removed launcher${RESET}"
}

# 🌐 Random IP Generator
random_ipv4() {
  echo "$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
}

# 🔍 WARP Scanner
scan_warp() {
  echo -e "${CYAN}🔍 Scanning WARP IPs...${RESET}"
  count=0
  while [ $count -lt 10 ]; do
    ip=$(random_ipv4)
    port=$((RANDOM % 65535 + 1))
    pingm=$(ping -c1 -W1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$pingm" ]]; then
      echo -e "${GREEN}IP: $ip:$port    ping=${pingm}ms${RESET}"
      ((count++))
    fi
  done
}

# 🔁 Proxy Update
fetch_proxies() {
  echo -e "${YELLOW}⏬ Fetching Telegram proxies...${RESET}"
  > "$PROXY_FILE"
  curl -s https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/telegram.txt >> "$PROXY_FILE"
  curl -s https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json |
    jq -r '.[]|"\(.host):\(.port)"' 2>/dev/null >> "$PROXY_FILE"
  grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{2,5}' "$PROXY_FILE" | sort -u > "$PROXY_FILE.tmp"
  mv "$PROXY_FILE.tmp" "$PROXY_FILE"
  date +%s > "$LAST_UPDATE_FILE"
}

check_proxy_update() {
  now=$(date +%s)
  last=$(cat "$LAST_UPDATE_FILE" 2>/dev/null || echo 0)
  diff=$(( (now - last) / 3600 ))
  if (( diff >= 24 )); then
    fetch_proxies
  fi
}

show_proxies() {
  check_proxy_update
  [[ ! -f "$PROXY_FILE" ]] && fetch_proxies
  echo -e "${CYAN}📡 Top 10 Telegram Proxies:${RESET}"
  count=1
  shuf "$PROXY_FILE" | head -n 50 | while read proxy; do
    ip=${proxy%%:*}
    pingm=$(timeout 1 ping -c1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$pingm" ]]; then
      echo -e "${BLUE}Proxy $count:${RESET} $proxy   ${GREEN}ping=${pingm}ms${RESET}"
      ((count++))
    fi
    [[ $count -gt 10 ]] && break
  done
  [[ $count -eq 1 ]] && echo -e "${RED}❌ No working proxies found.${RESET}"
}

# 🎯 Header
print_header() {
  clear
  echo -e "${CYAN}"
  echo "╔════════════════════════════════════════════════════╗"
  echo "║               🎯  AcademiVPN Terminal              ║"
  echo "╠════════════════════════════════════════════════════╣"
  echo "║ 📢 Telegram: ${CHANNEL}                     ║"
  echo "║ 👤 Admin   : ${ADMIN}                        ║"
  echo "║ 🧪 Version : ${VERSION}                                ║"
  echo "╚════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

# 🧭 Menu
check_deps
while true; do
  print_header
  echo -e "${YELLOW}1)${RESET} 🧱 Install Launcher        (${GREEN}Academivpn_warp${RESET})"
  echo -e "${YELLOW}2)${RESET} 🧹 Remove Launcher"
  echo -e "${YELLOW}3)${RESET} 🔍 WARP IP Scanner (10 IP:PORT)"
  echo -e "${YELLOW}4)${RESET} 📡 Telegram Proxies (10 Working)"
  echo -e "${YELLOW}0)${RESET} ❌ Exit"
  echo ""
  read -p "💡 Choose an option: " opt
  case "$opt" in
    1) install_launcher ;;
    2) remove_launcher ;;
    3) scan_warp ;;
    4) show_proxies ;;
    0) echo -e "${RED}Goodbye!${RESET}"; exit ;;
    *) echo -e "${RED}❌ Invalid choice!${RESET}" ;;
  esac
  echo ""
  read -p "🔁 Press Enter to return to menu..."
done
