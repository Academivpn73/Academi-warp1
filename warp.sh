#!/bin/bash

VERSION="1.6.1"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"

TITLE="==============================="
TITLE+="\n  Academi WARP | Telegram Proxy Tool"
TITLE+="\n  Version: $VERSION"
TITLE+="\n  Telegram: $CHANNEL"
TITLE+="\n  Admin: $ADMIN"
TITLE+="\n===============================\n"

PROXY_FILE="$HOME/.academi_proxies.txt"

show_title() {
    clear
    echo -e "$TITLE"
}

fetch_proxies() {
    echo -e "\nFetching fresh Telegram proxies...\n"
    URL="https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json"
    PROXIES=$(curl -s "$URL" | jq -r '.[] | "\(.host):\(.port)"' 2>/dev/null)

    if [[ -z "$PROXIES" ]]; then
        echo "❌ No valid Telegram proxies found."
        return 1
    fi

    echo "$PROXIES" > "$PROXY_FILE"
    echo "✅ Proxies updated successfully."
}

show_proxies() {
    if [[ ! -f "$PROXY_FILE" ]]; then
        echo "⚠️ No proxies file found. Fetching now..."
        fetch_proxies
    fi

    echo -e "\n🌐 Top 10 Telegram MTProto Proxies:\n"
    COUNTER=1
    while IFS= read -r proxy && [[ $COUNTER -le 10 ]]; do
        PING=$(ping -c 1 -W 1 "${proxy%%:*}" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        [[ -z "$PING" ]] && PING="N/A"
        echo "Proxy $COUNTER: $proxy  |  Ping: ${PING} ms"
        ((COUNTER++))
    done < "$PROXY_FILE"
    echo ""
}

generate_warp_ips() {
    echo -e "\nGenerating 10 random WARP IPs...\n"
    for i in {1..10}; do
        IP=$(shuf -i 1-255 -n 4 | paste -sd.)
        PORT=$((RANDOM % 65535 + 1))
        echo "$IP:$PORT"
    done
    echo ""
}

setup_cron() {
    echo -e "\n🕒 Enabling daily auto-update for proxies..."
    (crontab -l 2>/dev/null; echo "0 */5 * * * bash $0 --auto-update") | crontab -
    echo "✅ Auto-update scheduled every 5 hours."
}

handle_input() {
    while true; do
        echo -e "\n📋 Choose an option:"
        echo "1) 🧰 Install Launcher"
        echo "2) ❌ Remove Launcher"
        echo "3) 🌐 Show Top 10 Telegram Proxies"
        echo "4) 💎 Generate 10 WARP IPs"
        echo "5) 🕒 Enable Daily Proxy Auto-Update"
        echo "0) 🧱 Exit"
        echo -n ">> "; read -r choice

        case $choice in
            1) echo "Launcher installation not implemented yet." ;;
            2) echo "Launcher removal not implemented yet." ;;
            3) show_proxies ;;
            4) generate_warp_ips ;;
            5) setup_cron ;;
            0) echo "👋 Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Try again." ;;
        esac
    done
}

if [[ "$1" == "--auto-update" ]]; then
    fetch_proxies
    exit 0
fi

show_title
handle_input
