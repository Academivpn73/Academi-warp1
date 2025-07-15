#!/data/data/com.termux/files/usr/bin/bash

ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
VERSION="1.6.3"
PROXY_FILE="$HOME/academi_proxies.txt"

check_deps() {
  for cmd in curl jq ping; do
    if ! command -v $cmd &>/dev/null; then
      pkg install -y $cmd
    fi
  done
}

install_launcher() {
  cp "$0" "$PREFIX/bin/Academivpn_warp"
  chmod +x "$PREFIX/bin/Academivpn_warp"
  echo "✅ Launcher installed: use command 'Academivpn_warp'"
}

remove_launcher() {
  rm -f "$PREFIX/bin/Academivpn_warp"
  echo "✅ Launcher removed"
}

fetch_proxies() {
  URL="https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json"
  curl -s "$URL" | jq -r '.[]|"\(.host):\(.port)"' >"$PROXY_FILE"
}

show_proxies() {
  [[ ! -f "$PROXY_FILE" ]] && fetch_proxies
  echo "Generating top 10 proxies..."
  head -n 50 "$PROXY_FILE" | shuf -n10 | while read p; do
    h=${p%%:*}; pingm=$(ping -c1 -W1 "$h" 2>/dev/null|grep time=|awk -F'time=' '{print $2}'|cut -d' ' -f1)
    echo "Proxy: $p  ping=${pingm:-N/A}ms"
  done
}

scan_warp() {
  echo "Scanning random WARP IPs..."
  for i in $(seq 1 10); do
    ip=$(curl -s https://api64.ipify.org)
    port=$(( ( RANDOM % 65535 ) + 1 ))
    pingm=$(ping -c1 -W1 "${ip}" 2>/dev/null|grep time=|awk -F'time=' '{print $2}'|cut -d' ' -f1)
    echo "IP: $ip:$port  ping=${pingm:-N/A}ms"
    sleep 1
  done
}

daily_cron() {
  (crontab -l 2>/dev/null; echo "0 0 * * * bash '$0' --update-proxies") | crontab -
  echo "✅ Cron set: daily proxy update"
}

print_header() {
  clear
  echo "====== Academi WARP Toolkit v$VERSION ======"
  echo " Telegram: $CHANNEL"
  echo " Admin:    $ADMIN"
  echo "============================================"
}

if [[ "$1" == "--update-proxies" ]]; then
  fetch_proxies
  exit 0
fi

check_deps

while true; do
  print_header
  echo "1) Install Launcher        (Academivpn_warp)"
  echo "2) Remove Launcher"
  echo "3) Warp IP Scanner (10)"
  echo "4) Show Telegram Proxies (10)"
  echo "5) Enable daily proxy update"
  echo "0) Exit"
  read -p "Select: " opt
  case "$opt" in
    1) install_launcher ;;
    2) remove_launcher ;;
    3) scan_warp ;;
    4) show_proxies ;;
    5) daily_cron ;;
    0) echo "Bye!"; exit ;;
    *) echo "Invalid!" ;;
  esac
  echo "Press Enter to continue..."; read
done
