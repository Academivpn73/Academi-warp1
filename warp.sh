#!/bin/bash

# ===[ AcademiVPN Script ]===
VERSION="1.6.0"
PROXY_FILE="$HOME/.academi_proxies.txt"
CRON_JOB="/etc/cron.daily/academivpn_proxy_update"

show_header() {
    clear
    echo -e "🛰️  AcademiVPN MTProto Proxy Fetcher v$VERSION"
    echo -e "Telegram: @Academi_vpn"
    echo -e "Admin: @MahdiAGM0"
    echo -e "--------------------------------------------"
}

fetch_proxies() {
    echo -e "\n🌐 Fetching MTProto proxies from GitHub & Web..."

    > "$TMP_PROXIES"

    SOURCES=(
        "https://raw.githubusercontent.com/aliilapro/MTProtoProxy/main/mtproto.txt"
        "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
        "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/mtproto.txt"
    )

    for url in "${SOURCES[@]}"; do
        echo "📥 Downloading from: $url"
        data=$(curl -s --max-time 10 "$url")
        if [[ $? -eq 0 ]]; then
            echo "$data" | grep -Eo 'tls://[a-zA-Z0-9_-]+' >> "$TMP_PROXIES"
            echo "$data" | grep -Eo 't.me/proxy\?server=[^[:space:]]+' >> "$TMP_PROXIES"
        else
            echo "⚠️ Failed to fetch from $url"
        fi
    done

    sort -u "$TMP_PROXIES" > "$PROXY_FILE"

    if [[ -s "$PROXY_FILE" ]]; then
        echo -e "✅ Saved proxies to $PROXY_FILE"
    else
        echo -e "❌ No valid proxies found."
    fi
}

generate_warp_ips() {
    echo -e "\n🌍 Generating random WARP IPs...\n"
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
    cp "$0" "$BIN_PATH"
    chmod +x "$BIN_PATH"
    echo -e "✅ Installed. Now you can run: Academivpn_warp"
}

remove_launcher() {
    echo -e "\n🗑️ Removing launcher..."
    rm -f /usr/local/bin/Academivpn_warp
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

# ===[ Handle Auto Update via Flag ]===
if [[ "$1" == "--auto-update" ]]; then
    TMP_PROXIES=$(mktemp)
    fetch_proxies
    rm -f "$TMP_PROXIES"
    exit 0
fi

# ===[ Main Menu ]===
while true; do
    show_header
    echo -e "\n📋 Choose an option:"
    echo "1) 📥 Install Launcher"
    echo "2) ❌ Remove Launcher"
    echo "3) 🌐 Show Telegram MTProto Proxies"
    echo "4) 🌍 Generate WARP IPs"
    echo "5) 🔁 Enable Daily Proxy Auto-Update"
    echo "0) 🧱 Exit"

    echo -ne "\n>> "
    read -r option

    TMP_PROXIES=$(mktemp)

    case "$option" in
        1) install_launcher ;;
        2) remove_launcher ;;
        3)
            echo -e "\n🌐 Telegram Proxies:\n"
            if [[ ! -s "$PROXY_FILE" ]]; then
                echo "⚠️ No proxies found. Fetching now..."
                fetch_proxies
            fi
            cat "$PROXY_FILE"
            echo -e "\nPress Enter to return..."
            read
            ;;
        4) generate_warp_ips ;;
        5) enable_daily_auto_update ;;
        0) echo -e "\n👋 Goodbye!"; break ;;
        *) echo -e "\n❌ Invalid option. Try again."; sleep 1 ;;
    esac
done
