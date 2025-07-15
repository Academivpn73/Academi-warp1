#!/bin/bash

=======================================================

✨ Academi VPN Warp Tool - Version 1.6.1

🌐 Telegram: @Academi_vpn

👤 Admin: @MahdiAGM0

=======================================================

VERSION="1.6.1" PROXY_FILE="proxies.txt"

Ensure required tools are installed

dep_install() { for pkg in curl jq ping; do if ! command -v $pkg &>/dev/null; then echo "Installing $pkg..." pkg install -y $pkg || apt install -y $pkg fi done }

dep_install

Fetch Telegram proxies from external API

fetch_proxies() { echo "\n🔄 Fetching fresh Telegram proxies..." URL="https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json" PROXIES=$(curl -s "$URL" | jq -r '.[].host + ":" + (.[].port|tostring)' 2>/dev/null) if [[ -z "$PROXIES" ]]; then echo "❌ No valid Telegram proxies found." return 1 fi echo "$PROXIES" > "$PROXY_FILE" echo "✅ Proxies updated successfully." }

Show top 10 proxies with ping

show_proxies() { echo -e "\n🌐 Top 10 Telegram MTProto Proxies with Ping:\n" if [[ ! -s "$PROXY_FILE" ]]; then fetch_proxies || { echo -e "\nPress Enter to return..."; read; return; } fi

COUNT=1
while IFS= read -r proxy && [[ $COUNT -le 10 ]]; do
    host=$(echo "$proxy" | cut -d':' -f1)
    ping_result=$(ping -c 1 -W 1 "$host" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -z "$ping_result" ]]; then
        ping_result="Timeout"
    else
        ping_result="${ping_result}ms"
    fi
    echo "Proxy $COUNT: $proxy  (Ping: $ping_result)"
    ((COUNT++))
done < "$PROXY_FILE"
echo -e "\nPress Enter to return..."
read

}

Main menu

main_menu() { while true; do clear echo -e "\e[36m============================================\e[0m" echo -e "         🚀 Academi VPN WARP Tool" echo -e "         🔹 Version: $VERSION" echo -e "         🔹 Telegram: @Academi_vpn" echo -e "         🔹 Admin: @MahdiAGM0" echo -e "\e[36m============================================\e[0m" echo -e "\nSelect an option:\n" echo -e "1) Update Proxies" echo -e "2) Show Top 10 Proxies" echo -e "3) Exit" echo -ne "\nYour choice: " read CHOICE case $CHOICE in 1) fetch_proxies && sleep 2;; 2) show_proxies;; 3) echo -e "\nExiting..."; exit 0;; *) echo -e "\nInvalid option. Press Enter..."; read;; esac done }

main_menu

