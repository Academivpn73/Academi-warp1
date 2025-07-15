#!/bin/bash

#=====[ Config ]=====
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
VERSION="1.7.0"
CRON_JOB="/etc/cron.daily/proxy_update"
INSTALLER_NAME="Academivpn_warp"

#=====[ Check dependencies ]=====
check_dependencies() {
  for pkg in curl jq ping crontab; do
    if ! command -v $pkg &> /dev/null; then
      echo "Installing missing package: $pkg"
      apt update -y &>/dev/null
      apt install -y $pkg &>/dev/null
    fi
  done
}

#=====[ Display Title ]=====
print_title() {
  clear
  echo -e "\e[1;32m=============================="
  echo -e "  Telegram: $CHANNEL"
  echo -e "  Admin: $ADMIN"
  echo -e "  Version: $VERSION"
  echo -e "==============================\e[0m"
}

#=====[ WARP IP Scanner ]=====
scan_warp_ips() {
  echo -e "\n🔎 Scanning WARP IPs...\n"
  for i in {1..10}; do
    IP=$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1)
    PORT=$((RANDOM%65535+1))
    PING=$(ping -c 1 -W 1 $IP | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$PING" ]]; then
      echo -e "\e[32m$IP:$PORT  ${PING}ms\e[0m"
    else
      echo -e "$IP:$PORT  Timeout"
    fi
  done
}

#=====[ Telegram Proxies ]=====
fetch_telegram_proxies() {
  echo -e "\n🔄 Fetching Telegram proxies..."

  TMP_FILE=$(mktemp)
  curl -s --max-time 10 https://raw.githubusercontent.com/peasoft/mtprotoproxy-telegram/master/proxies.json -o "$TMP_FILE"

  if [[ ! -s "$TMP_FILE" ]]; then
    echo "❌ Failed to fetch proxies"
    return
  fi

  PROXIES=$(grep -oP '(?<=link": ")[^"]+' "$TMP_FILE" | head -n 10)
  rm -f "$TMP_FILE"

  if [[ -z "$PROXIES" ]]; then
    echo "❌ No working Telegram proxies found."
    return
  fi

  i=1
  echo
  for proxy in $PROXIES; do
    echo -e "Proxy $i:\n🔗 \e[36m$proxy\e[0m"
    ((i++))
  done
}

#=====[ Daily Proxy Auto-Update ]=====
setup_cron() {
  cat <<EOF > "$CRON_JOB"
#!/bin/bash
curl -s --max-time 10 https://raw.githubusercontent.com/peasoft/mtprotoproxy-telegram/master/proxies.json -o /tmp/proxy_update.json
EOF
  chmod +x "$CRON_JOB"
}

#=====[ Installer Management ]=====
installer_menu() {
  echo -e "\n🛠️ Installer Management:"
  echo "1) Enable Installer ($INSTALLER_NAME)"
  echo "2) Remove Installer"
  read -p "Choose: " opt
  case $opt in
    1)
      echo "bash $PWD/$0" > /usr/local/bin/$INSTALLER_NAME
      chmod +x /usr/local/bin/$INSTALLER_NAME
      echo "✅ Installer enabled: use command '$INSTALLER_NAME'"
      ;;
    2)
      rm -f /usr/local/bin/$INSTALLER_NAME
      echo "✅ Installer removed"
      ;;
    *)
      echo "❌ Invalid option"
      ;;
  esac
}

#=====[ Main Menu ]=====
main_menu() {
  while true; do
    print_title
    echo "1) WARP IP Scanner"
    echo "2) Telegram Proxies"
    echo "3) Installer Manager"
    echo "4) Exit"
    echo -n "Choose an option: "
    read -r option
    case $option in
      1) scan_warp_ips ;;
      2) fetch_telegram_proxies ;;
      3) installer_menu ;;
      4) echo "Goodbye 👋"; exit ;;
      *) echo "❌ Invalid option" ;;
    esac
    echo -e "\nPress Enter to return to menu..."
    read
  done
}

#=====[ Run ]=====
check_dependencies
setup_cron
main_menu
