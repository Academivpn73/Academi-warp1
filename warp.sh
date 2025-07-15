#!/bin/bash

# اطلاعات
ADMIN_ID="@AcademiVPN"
CHANNEL_ID="@AcademiProxies"
VERSION="1.6.1"
PROXY_FILE="proxies.txt"

# چک و نصب ابزارهای مورد نیاز
check_dependencies() {
  echo "Checking dependencies..."

  for pkg in jq iputils; do
    if ! command -v jq >/dev/null 2>&1 && [[ "$pkg" == "jq" ]]; then
      echo "Installing jq..."
      pkg install -y jq >/dev/null
    elif ! command -v ping >/dev/null 2>&1 && [[ "$pkg" == "iputils" ]]; then
      echo "Installing iputils (ping)..."
      pkg install -y iputils >/dev/null
    fi
  done
}

# دریافت پروکسی
fetch_proxies() {
  echo ""
  echo "Fetching fresh Telegram proxies..."

  URL="https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json"
  PROXIES=$(curl -s "$URL" | jq -r '.[] | "\(.host):\(.port)"' 2>/dev/null)

  if [[ -z "$PROXIES" ]]; then
    echo "❌ No valid Telegram proxies found."
    return 1
  fi

  echo "$PROXIES" > "$PROXY_FILE"
  echo "✅ Proxies updated successfully."
}

# نمایش پروکسی‌ها با پینگ
show_proxies() {
  if [[ ! -f "$PROXY_FILE" ]]; then
    echo "Proxy list not found. Fetching now..."
    fetch_proxies
  fi

  echo ""
  echo "------ TOP 10 TELEGRAM PROXIES ------"
  count=1
  while IFS= read -r proxy && [[ $count -le 10 ]]; do
    host=$(echo "$proxy" | cut -d: -f1)
    port=$(echo "$proxy" | cut -d: -f2)
    ping=$(ping -c 1 -W 1 "$host" 2>/dev/null | grep time= | awk -F"time=" '{print $2}' | cut -d" " -f1)

    if [[ -z "$ping" ]]; then
      ping="Timeout"
    fi

    echo "Proxy $count: $proxy - Ping: $ping"
    ((count++))
  done < "$PROXY_FILE"
  echo "-------------------------------------"
}

# اجرای ابزار
check_dependencies

while true; do
  clear
  echo "======== TELEGRAM PROXY TOOL ========"
  echo " Admin   : $ADMIN_ID"
  echo " Channel : $CHANNEL_ID"
  echo " Version : $VERSION"
  echo "====================================="
  echo "1) Show Top 10 Telegram Proxies"
  echo "2) Update Proxy List"
  echo "0) Exit"
  echo "====================================="
  read -p "Choose an option: " opt

  case $opt in
    1) show_proxies ;;
    2) fetch_proxies ;;
    0) echo "Goodbye!"; exit ;;
    *) echo "Invalid option!" ;;
  esac

  read -p "Press Enter to continue..."
done
