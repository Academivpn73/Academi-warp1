#!/bin/bash

# ===[ AcademiVPN Script ]===
VERSION="1.6.0"
PROXY_FILE="$HOME/.academi_proxies.txt"
CRON_JOB="/etc/cron.daily/academivpn_proxy_update"

show_header() {
    clear
    echo -e "┌────────────────────────────────────────────┐"
    echo -e "│       🛰️  AcademiVPN Proxy Tool v$VERSION       │"
    echo -e "├────────────────────────────────────────────┤"
    echo -e "│ 🌐 Channel : @Academi_vpn                   │"
    echo -e "│ 👤 Admin   : @MahdiAGM0                     │"
    echo -e "└────────────────────────────────────────────┘"
}

fetch_proxies() {
    echo -e "\n🔄 Fetching latest Telegram proxies..."

    TMP_PROXIES=$(mktemp)

    SOURCES=(
        "https://raw.githubusercontent.com/aliilapro/MTProtoProxy/main/mtproto.txt"
        "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/mtproto.txt"
        "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    )

    for url in "${SOURCES[@]}"; do
        data=$(curl -s --max-time 10 "$url")
        echo "$data" | grep -Eo 't.me/proxy\?server=[^[:space:]]+' >> "$TMP_PROXIES"
    done

    sort -u "$TMP_PROXIES" > "$PROXY_FILE"
    rm -f "$TMP_PROXIES"

    if [[ -s "$PROXY_FILE" ]]; then
        echo -e "✅ Proxies updated successfully."
    else
        echo -e "❌ Failed to fetch valid proxies."
    fi
}

generate_warp_ips() {
    echo -e "\n🌍 Generating 10 random WARP IPs with ports...\n"
    for i in {1..10}; do
        IP=$(shuf -i 162000000000-162255255255 -n 1 | awk '{ip=sprintf("%d.%d.%d.%d", int($1/256/256/256)%256, int($1/256/256)%256, int($1/256)%256, $1%256); print ip}')
        PORT=$((RANDOM % 65535 + 1000))
        echo "📶 $IP:$PORT"
    done
    echo -e "\nPress Enter to return..."
    read
}

install_launcher() {
    echo -e "\n📥 Installing launcher as 'Academivpn_warp'"
    BIN_PATH="/usr/local/bin/Academivpn_warp"
    sudo cp "$0" "$BIN_PATH"
    sudo chmod +x "$BIN_PATH"
    echo -e "✅ Installed. Now you can run: Academivpn_warp"
}

remove_launcher() {
    echo -e "\n🗑️ Removing launcher..."
    sudo rm -f /usr/local/bin/Academivpn_warp
    echo -e "✅ Removed."
}

enable_daily_auto_update() {
    echo -e "\n🕐 Enabling daily auto-update..."
    sudo tee "$CRON_JOB" > /dev/null <<EOF
#!/bin/bash
bash "$0" --auto-update
EOF
    sudo chmod +x "$CRON_JOB"
    echo "✅ Daily auto-update enabled via cron."
}

# ===[ Auto Update Handler ]===
if [[ "$1" == "--auto-update" ]]; then
    fetch_proxies
    exit 0
fi

# ===[ Main Menu ]===
while true; do
    show_header
    echo -e "\n📋 Choose an option:"
    echo "1) 📥 Install Launcher"
    echo "2) ❌ Remove Launcher"
    echo "3) 🌐 Show Top 10 Telegram Proxies"
    echo "4) 🌍 Generate 10 WARP IPs"
    echo "5) 🔁 Enable Daily Proxy Auto-Update"
    echo "0) 🧱 Exit"

    echo -ne "\n>> "
    read -r option

    case "$option" in
        1) install_launcher ;;
        2) remove_launcher ;;
        3)
            echo -e "\n🌐 Top 10 Telegram MTProto Proxies:\n"
            if [[ ! -s "$PROXY_FILE" ]]; then
                fetch_proxies
            fi
            head -n 10 "$PROXY_FILE"
            echo -e "\nPress Enter to return..."
            read
            ;;
        4) generate_warp_ips ;;
        5) enable_daily_auto_update ;;
        0) echo -e "\n👋 Goodbye!"; break ;;
        *) echo -e "\n❌ Invalid option. Try again."; sleep 1 ;;
    esac
done
