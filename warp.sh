#!/bin/bash

# ============ Title Section ============

VERSION="1.0.9"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

clear
echo -e "\e[36m===============================\e[0m"
echo -e "  🚀 Academi VPN Panel v$VERSION"
echo -e "  📢 Channel: $CHANNEL"
echo -e "  👤 Admin: $ADMIN"
echo -e "\e[36m===============================\e[0m"

# ============ Dependencies ============

install_dependencies() {
    echo -e "\n🔧 Installing dependencies..."
    pkg update -y &> /dev/null
    pkg install curl grep sed coreutils -y &> /dev/null
}

# ============ Installer Setup ============

setup_installer() {
    echo -e "\n🛠 Setting up installer..."
    INSTALLER_PATH="/data/data/com.termux/files/usr/bin/Academivpn_warp"
    SCRIPT_PATH=$(realpath "$0")

    echo "bash $SCRIPT_PATH" > "$INSTALLER_PATH"
    chmod +x "$INSTALLER_PATH"
    echo -e "✅ Installer created. Run using: \e[32mAcademivpn_warp\e[0m"
}

remove_installer() {
    INSTALLER_PATH="/data/data/com.termux/files/usr/bin/Academivpn_warp"
    if [[ -f "$INSTALLER_PATH" ]]; then
        rm -f "$INSTALLER_PATH"
        echo "❌ Installer removed."
    else
        echo "⚠️ Installer not found."
    fi
}

# ============ Proxy Fetch ============

proxy_sources=(
    "https://t.me/s/Mtpro_xyz"
    "https://t.me/s/proxyMTProto"
    "https://t.me/s/mtprotonline"
    "https://t.me/s/TelegramProxiesList"
)

fetch_proxies() {
    echo -e "\n🌐 Fetching Telegram proxies..."
    proxies=""

    for url in "${proxy_sources[@]}"; do
        result=$(curl -s "$url" | grep -oE "tg://proxy\?server=[^\"\'\s]+" | head -n 10)
        proxies+="$result"$'\n'
    done

    if [[ -n "$proxies" ]]; then
        echo "$proxies" | sort -u > ~/.academi_proxies.txt
        echo -e "✅ Proxies saved to ~/.academi_proxies.txt"
    else
        echo -e "❌ No valid proxies found."
    fi
}

start_proxy_updater() {
    cat <<EOF > ~/.proxy_updater.sh
#!/bin/bash
while true; do
    bash $SCRIPT_PATH --fetch-proxies
    sleep 18000  # 5 hours
done
EOF
    chmod +x ~/.proxy_updater.sh
    nohup bash ~/.proxy_updater.sh &> /dev/null &
    echo "📡 Proxy auto-updater started in background."
}

telegram_proxies() {
    echo -e "\n📬 Telegram Proxies:"
    if [[ -f ~/.academi_proxies.txt ]]; then
        cat ~/.academi_proxies.txt
    else
        echo "⚠️ No proxies found. Fetching now..."
        fetch_proxies
        cat ~/.academi_proxies.txt
    fi
}

# ============ Warp IP Generator ============

generate_warp_ips() {
    echo -e "\n🌍 Generating random WARP IPs..."
    for i in {1..10}; do
        ip="162.$((100 + RANDOM % 50)).$((RANDOM % 256)).$((RANDOM % 256))"
        port=$((1000 + RANDOM % 90000))
        echo "➡️ $ip:$port"
    done
}

# ============ Main Menu ============

main_menu() {
    echo -e "\n📋 Select an option:"
    echo "1) 🔄 Install Installer"
    echo "2) ❌ Remove Installer"
    echo "3) 🌐 Telegram Proxies"
    echo "4) 🌍 Generate WARP IPs"
    echo "0) 🚪 Exit"
    read -p ">> " opt

    case "$opt" in
        1) setup_installer ;;
        2) remove_installer ;;
        3) telegram_proxies ;;
        4) generate_warp_ips ;;
        0) exit 0 ;;
        *) echo "❌ Invalid option." ;;
    esac

    read -p "Press Enter to return..." dummy
    main_menu
}

# ============ Auto-Handling Args ============

if [[ "$1" == "--fetch-proxies" ]]; then
    fetch_proxies
    exit 0
fi

# Run setup and main
install_dependencies
main_menu
