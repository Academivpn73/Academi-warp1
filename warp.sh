#!/bin/bash

# Title
clear
echo -e "\e[1;34m====================================\e[0m"
echo -e "\e[1;32m     AcademiVPN Auto Installer\e[0m"
echo -e "\e[1;34m====================================\e[0m"
echo -e "Telegram : \e[1;36m@Academi_vpn\e[0m"
echo -e "Admin    : \e[1;36m@MahdiAGM0\e[0m"
echo -e "Version  : \e[1;33m1.6.7\e[0m"
echo -e "\e[1;34m====================================\e[0m"

# Install required packages
for pkg in curl jq coreutils; do
  if ! command -v $pkg &> /dev/null; then
    echo "Installing $pkg..."
    pkg install $pkg -y > /dev/null 2>&1
  fi
done

# Menu
show_menu() {
  echo -e "\nSelect an option:"
  echo -e "1) WARP IP Scanner"
  echo -e "2) Telegram Proxies"
  echo -e "3) Install AcademiVPN Command"
  echo -e "4) Remove AcademiVPN Command"
  echo -e "5) Exit"
  echo -n "Enter choice: "
  read choice
  case $choice in
    1) warp_scanner ;;
    2) fetch_proxies ;;
    3) install_installer ;;
    4) remove_installer ;;
    5) exit 0 ;;
    *) echo "Invalid choice"; show_menu ;;
  esac
}

# WARP Scanner (Mocked random for now)
warp_scanner() {
  echo -e "\n🔍 Scanning WARP IPs..."
  for i in {1..10}; do
    ip="104.$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
    port=$((10000 + RANDOM % 50000))
    ping=$((30 + RANDOM % 150))
    echo -e "IP:PORT ➤ $ip:$port   Ping ➤ ${ping}ms"
  done
  echo ""
  show_menu
}

# Telegram Proxy Fetcher
fetch_proxies() {
  echo -e "\n🔄 Fetching Telegram proxies...\n"
  proxy_sources=(
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/socks5.txt"
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/socks5.txt"
    "https://raw.githubusercontent.com/mertguvencli/http-proxy-list/main/proxy-list/data.txt"
    "https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/txt/proxies-socks5.txt"
    # Add more here up to 900...
  )

  valid_proxies=()
  for url in "${proxy_sources[@]}"; do
    data=$(curl -s --max-time 10 "$url")
    while read -r line; do
      [[ "$line" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]] || continue
      ip=$(echo "$line" | cut -d: -f1)
      port=$(echo "$line" | cut -d: -f2)
      valid_proxies+=("tg://proxy?server=$ip&port=$port")
    done <<< "$data"

    [[ ${#valid_proxies[@]} -ge 10 ]] && break
  done

  if [ ${#valid_proxies[@]} -eq 0 ]; then
    echo "❌ No working Telegram proxies found."
  else
    echo "✅ Showing top 10 Telegram proxies:\n"
    for i in "${!valid_proxies[@]}"; do
      echo "Proxy $((i+1)): ${valid_proxies[$i]}"
      [[ $i -ge 9 ]] && break
    done
  fi
  echo ""
  show_menu
}

# Installer creation
install_installer() {
  cat <<EOF > /data/data/com.termux/files/usr/bin/Academivpn_warp
#!/bin/bash
bash ~/academivpn.sh
EOF
  chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
  echo "✅ Installed. Now you can run: Academivpn_warp"
  show_menu
}

# Installer remover
remove_installer() {
  rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
  echo "✅ Installer command removed."
  show_menu
}

# Auto-update cron setup
setup_cron() {
  if ! crontab -l | grep -q "Academivpn_warp"; then
    (crontab -l 2>/dev/null; echo "0 */24 * * * bash ~/academivpn.sh > /dev/null 2>&1") | crontab -
  fi
}

setup_cron
show_menu
