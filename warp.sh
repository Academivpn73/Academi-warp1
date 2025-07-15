#!/data/data/com.termux/files/usr/bin/bash

ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
VERSION="1.6.3"
PROXY_FILE="$HOME/academi_proxies.txt"

# 🧩 Dependencies
check_deps() {
  for cmd in curl jq ping; do
    if ! command -v $cmd &>/dev/null; then
      pkg install -y $cmd
    fi
  done
}

# ✅ INSTALLER
install_launcher() {
  cp "$0" "$PREFIX/bin/Academivpn_warp"
  chmod +x "$PREFIX/bin/Academivpn_warp"
  echo "✅ Installed launcher: Academivpn_warp"
}

remove_launcher() {
  rm -f "$PREFIX/bin/Academivpn_warp"
  echo "✅ Removed launcher"
}

# 🔁 Update proxies daily
daily_cron() {
  (crontab -l 2>/dev/null; echo "0 4 * * * bash '$0' --update-proxies") | crontab -
  echo "✅ Daily proxy update enabled"
}

# 🌍 Random IPv4 generator
random_ipv4() {
  echo "$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
}

# 🚀 WARP IP Scanner (Mocked Random IPs)
scan_warp() {
  echo "🔍 Scanning random IPs from public range..."
  count=0
  while [ $count -lt 10 ]; do
    ip=$(random_ipv4)
    port=$((RANDOM % 65535 + 1))
    pingm=$(ping -c1 -W1 "$ip" 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$pingm" ]]; then
      echo "IP: $ip:$port  ping=${pingm}ms"
      ((count++))
    fi
  done
}

# 🌐 Fetch Telegram proxies from multiple sources
fetch_proxies() {
  echo "⏬ Fetching fresh proxies..."
  curl -s https://raw.githubusercontent.com/TelegramMessenger/MTProxy/master/proxy_list.json | jq -r '.[]|"\(.host):\(.port)"' 2>/dev/null >>"$PROXY_FILE"
  curl -s https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json | jq -r '.[]|"\(.host):\(.port)"' 2>/dev/null >>"$PROXY_FILE"
  curl -s https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/telegram.txt >>"$PROXY_FILE"
  sort -u "$PROXY_FILE" -o "$PROXY_FILE"
}

# 🧪 Show Top 10 Working Proxies
show_proxies() {
  [[ ! -f "$PROXY_FILE" ]] && fetch_proxies
  echo "🔌 Showing top 10 working proxies:"
  count=1
  shuf "$PROXY_FILE" | head -n 50 | while read proxy; do
    ip=${proxy%%:*}
    pingm=$(ping -c1 -W1 "$ip" 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$pingm" ]]; then
      echo "Proxy $count: $proxy  ping=${pingm}ms"
      ((count++))
    fi
    [[ $count -gt 10 ]] && break
  done
}

print_header() {
  clear
  echo "============================================"
  echo "   🎯 AcademiVPN Tool — Version: $VERSION"
  echo "   📢 Telegram: $CHANNEL"
  echo "   🛠️ Admin: $ADMIN"
  echo "============================================"
}

# 📅 --update-proxies (for CRON)
if [[ "$1" == "--update-proxies" ]]; then
  fetch_proxies
  exit 0
fi

# ⚙️ Main Menu
check_deps
while true; do
  print_header
  echo "1) Install Launcher        (Academivpn_warp)"
  echo "2) Remove Launcher"
  echo "3) WARP IP Scanner (10)"
  echo "4) Telegram Proxies (10)"
  echo "5) Enable daily proxy update"
  echo "0) Exit"
  read -p "Choose: " opt
  case "$opt" in
    1) install_launcher ;;
    2) remove_launcher ;;
    3) scan_warp ;;
    4) show_proxies ;;
    5) daily_cron ;;
    0) echo "Goodbye!"; exit ;;
    *) echo "❌ Invalid option!" ;;
  esac
  echo "Press Enter..."; read
done
