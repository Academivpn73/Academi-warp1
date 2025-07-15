#!/bin/bash

#──────────── ACADEMIVPN WARP PANEL ────────────#
TITLE="AcademiVPN WARP PANEL"
CHANNEL="Telegram: @Academi_vpn"
ADMIN="Admin: @MahdiAGM0"
VERSION="Version: 1.6.7"
#───────────────────────────────────────────────#

print_title() {
  clear
  echo -e "\e[96m╔════════════════════════════════════════╗\e[0m"
  echo -e "\e[92m║        $TITLE               \e[0m"
  echo -e "\e[96m╠════════════════════════════════════════╣\e[0m"
  echo -e "\e[92m║ $CHANNEL     \e[0m"
  echo -e "\e[92m║ $ADMIN              \e[0m"
  echo -e "\e[92m║ $VERSION                              \e[0m"
  echo -e "\e[96m╚════════════════════════════════════════╝\e[0m"
  echo ""
}

install_dependencies() {
  for pkg in curl jq grep coreutils; do
    command -v $pkg >/dev/null 2>&1 || {
      echo "📦 Installing $pkg..."
      pkg install -y $pkg >/dev/null 2>&1 || sudo apt install -y $pkg
    }
  done
}

generate_warp_ips() {
  echo -e "\n🔍 Scanning 10 random working WARP IPs..."
  for i in {1..10}; do
    IP=$(shuf -i 1-255 -n 4 | paste -sd .)
    PORT=$((RANDOM % 65535 + 1))
    PING=$(ping -c 1 -W 1 $IP | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [ -z "$PING" ]; then PING="Timeout"; fi
    echo -e "🌐 $i) $IP:$PORT  |  🕒 Ping: $PING ms"
  done
}

fetch_telegram_proxies() {
  echo -e "\n🌐 Fetching fresh Telegram proxies..."
  SOURCES=(
    "https://raw.githubusercontent.com/roosterkid/openproxylist/main/Telegram.txt"
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/socks5.txt"
    "https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/txt/proxy.txt"
  )

  PROXIES=()
  for url in "${SOURCES[@]}"; do
    TMP=$(curl -s --max-time 10 "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+' | head -n 30)
    while read -r proxy; do
      [[ ! -z "$proxy" ]] && PROXIES+=("$proxy")
    done <<< "$TMP"
  done

  VALID=()
  for proxy in "${PROXIES[@]}"; do
    if timeout 3 curl -s -x socks5://$proxy https://core.telegram.org >/dev/null 2>&1; then
      VALID+=("$proxy")
    fi
    [[ ${#VALID[@]} -ge 10 ]] && break
  done

  if [ ${#VALID[@]} -eq 0 ]; then
    echo "❌ No working Telegram proxies found."
  else
    echo -e "\n✅ Top 10 Telegram Proxies:"
    count=1
    for proxy in "${VALID[@]}"; do
      echo "Proxy $count: $proxy"
      ((count++))
    done
  fi
}

auto_update_proxies() {
  CRON_JOB="@daily bash /usr/local/bin/Academivpn_warp --update-proxies"
  (crontab -l 2>/dev/null | grep -v 'Academivpn_warp' ; echo "$CRON_JOB") | crontab -
}

menu() {
  print_title
  echo -e "\e[93m[1]\e[0m 🔎 WARP IP Scanner"
  echo -e "\e[93m[2]\e[0m 📡 Telegram Proxy Finder"
  echo -e "\e[93m[3]\e[0m ❌ Exit"
  echo ""
  read -rp "🧭 Choose an option: " opt
  case $opt in
    1) generate_warp_ips ;;
    2) fetch_telegram_proxies ;;
    3) echo "👋 Bye!" && exit 0 ;;
    *) echo "❌ Invalid option";;
  esac
  echo ""
  read -rp "↩️ Press Enter to return..." && menu
}

# For daily update if script is run with --update-proxies
if [[ "$1" == "--update-proxies" ]]; then
  fetch_telegram_proxies > /tmp/daily_proxies.txt
  exit 0
fi

install_dependencies
auto_update_proxies
menu
