#!/bin/bash

VERSION="1.3.0"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"
PROXY_FILE="$HOME/.academi_proxies.txt"

clear
echo -e "\e[36m===============================\e[0m"
echo -e "  🚀 Academi VPN Panel v$VERSION"
echo -e "  📢 Telegram: $CHANNEL"
echo -e "  👤 Admin: $ADMIN"
echo -e "\e[36m===============================\e[0m"

install_launcher() {
  echo "bash $(realpath "$0")" > /data/data/com.termux/files/usr/bin/Academivpn_warp
  chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
  echo -e "✅ Installed: use \e[32mAcademivpn_warp\e[0m to launch"
}

remove_launcher() {
  rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
  echo "🗑️ Launcher removed"
}

warp_scanner() {
  echo -e "\n🌍 Generating 10 random WARP IPs with ping:"
  for i in {1..10}; do
    ip="162.$((100 + RANDOM % 50)).$((RANDOM % 256)).$((RANDOM % 256))"
    port=$((1000 + RANDOM % 64500))
    ping=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    [[ -z "$ping" ]] && ping="Timeout"
    echo "➡️ $ip:$port   📶 Ping: $ping ms"
  done
  echo; read -rp "Press Enter to return..." _
}

fetch_mtproto() {
  echo -e "\n🌐 Fetching MTProto proxies from GitHub..."
  urls=(
    "https://raw.githubusercontent.com/ALIILAPRO/MTProtoProxy/main/mtproto.txt"
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://raw.githubusercontent.com/TelegramMessenger/MTProxy/master/proxies.csv"
  )

  > "$PROXY_FILE"

  for url in "${urls[@]}"; do
    echo "📥 Downloading from: $url"
    content=$(curl -fsSL "$url")
    [[ -z "$content" ]] && continue

    # extract MTProto proxies: ip:port:secret
    echo "$content" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+:[a-zA-Z0-9]+' >> "$PROXY_FILE"
    # check if it's CSV format
    echo "$content" | grep -E 'proxy\.telegram\.org' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+:[a-zA-Z0-9]+' >> "$PROXY_FILE"
  done

  if [[ ! -s "$PROXY_FILE" ]]; then
    echo "❌ No proxies found."
    return
  fi

  sort -u "$PROXY_FILE" -o "$PROXY_FILE"
  echo -e "✅ $(wc -l < "$PROXY_FILE") proxies saved to $PROXY_FILE\n"
  head -n 10 "$PROXY_FILE" | nl -w2 -s'. '
  echo; read -rp "Press Enter to return..." _
}

auto_update() {
  (
    while true; do
      bash "$0" --auto-fetch &>/dev/null
      sleep 86400  # every 24 hours
    done
  ) &
  echo "✅ Auto-update enabled (daily)"
}

main_menu() {
  echo -e "\n📋 Choose an option:"
  echo "1) 🔄 Install Launcher"
  echo "2) ❌ Remove Launcher"
  echo "3) 🌐 Show Telegram MTProto Proxies"
  echo "4) 🌍 Generate WARP IPs"
  echo "5) 🔁 Enable Daily Proxy Auto-Update"
  echo "0) 🚪 Exit"
  echo
  read -rp ">> " opt
  case "$opt" in
    1) install_launcher ;;
    2) remove_launcher ;;
    3) fetch_mtproto ;;
    4) warp_scanner ;;
    5) auto_update ;;
    0) exit ;;
    *) echo "❌ Invalid option."; sleep 1 ;;
  esac
}

if [[ "$1" == "--auto-fetch" ]]; then
  fetch_mtproto
  exit
fi

main_menu
while true; do main_menu; echo; done
