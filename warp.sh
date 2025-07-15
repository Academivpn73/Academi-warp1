#!/bin/bash

VERSION="1.0.4"
BIN_PATH="/data/data/com.termux/files/usr/bin/Academivpn_warp"

# ========== Install Dependencies ==========
install_dependencies() {
  echo -e "\nInstalling required packages..."
  apt update -y > /dev/null 2>&1
  apt install -y curl wget jq netcat unzip > /dev/null 2>&1
}

# ========== WARP Scanner ==========
warp_scan() {
  echo -e "\n[+] Scanning best WARP IPv4 IPs..."
  ips_found=0
  for i in {1..250}; do
    ip=$(shuf -n 1 -i 162.159.192.0-162.159.255.255)
    for port in 80 443 2086 2087 2052 2053 2095 2096 8080 8443; do
      ping_output=$(ping -c 1 -W 1 $ip | grep 'time=')
      if [[ $ping_output ]]; then
        ping_ms=$(echo "$ping_output" | grep -oP 'time=\K[0-9.]+')
        echo "$ip:$port  Ping: ${ping_ms}ms"
        ((ips_found++))
        break
      fi
      [[ $ips_found -ge 10 ]] && break 2
    done
  done
  [[ $ips_found -eq 0 ]] && echo "[!] No working IPs found."
}

# ========== Telegram Proxy ==========
fetch_proxies() {
  echo -e "\n[+] Fetching fresh Telegram proxies..."
  proxies=$(curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt | head -n 10)
  if [[ -z "$proxies" ]]; then
    echo "[!] Failed to fetch proxies."
  else
    echo "[✔] Found Proxies:"
    echo "$proxies"
  fi
}

# ========== Installer ==========
install_launcher() {
  echo -e "\n[+] Installing launcher as 'Academivpn_warp'..."
  echo "bash $(realpath "$0")" > "$BIN_PATH"
  chmod +x "$BIN_PATH"
  echo "[✔] Installed. You can now run: Academivpn_warp"
}

uninstall_launcher() {
  if [[ -f "$BIN_PATH" ]]; then
    rm "$BIN_PATH"
    echo "[✔] Launcher removed."
  else
    echo "[!] Launcher not found."
  fi
}

# ========== Main Menu ==========
main_menu() {
  while true; do
    echo -e "\n=============== Academi VPN Menu ==============="
    echo "Version: $VERSION"
    echo "Channel: @Academi_vpn"
    echo "Admin:   @MahdiAGM0"
    echo "-----------------------------------------------"
    echo "1. WARP IP Scanner"
    echo "2. Telegram Proxy"
    echo "3. Install Launcher (Academivpn_warp)"
    echo "4. Uninstall Launcher"
    echo "5. Exit"
    echo "-----------------------------------------------"
    read -p "Select option: " choice
    case "$choice" in
      1) warp_scan ;;
      2) fetch_proxies ;;
      3) install_launcher ;;
      4) uninstall_launcher ;;
      5) echo "Goodbye!"; exit 0 ;;
      *) echo "[!] Invalid choice." ;;
    esac
  done
}

# Run
install_dependencies
main_menu
