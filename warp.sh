#!/bin/bash

# =========[ Setup Variables ]=========
PROXY_FILE="/tmp/telegram_proxies.txt"
VERSION="1.6.0"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

# =========[ Auto Dependency Installer ]=========
install_dependencies() {
    echo "📦 Installing required packages..."
    pkg update -y >/dev/null 2>&1
    pkg install curl jq -y >/dev/null 2>&1
}

# =========[ Fetch MTProto Proxies ]=========
fetch_proxies() {
    echo "🔄 Fetching fresh Telegram proxies..."
    curl -s "https://raw.githubusercontent.com/hookzof/socks5_list/master/tg/mtproto.txt" -o "$PROXY_FILE"

    if [[ ! -s "$PROXY_FILE" ]]; then
        echo "❌ No valid Telegram proxies found."
        return 1
    fi

    echo "✅ Proxies updated."
    return 0
}

# =========[ Auto-update every 5 hours ]=========
auto_update_proxies() {
    while true; do
        fetch_proxies
        sleep 18000  # 5 hours
    done &
}

# =========[ Display Title ]=========
print_title() {
    clear
    echo -e "\e[1;34m===========================================\e[0m"
    echo -e "\e[1;32m AcademiVPN Panel - Warp & Proxy Tool\e[0m"
    echo -e "\e[1;34m===========================================\e[0m"
    echo -e "Version : \e[1;33m$VERSION\e[0m"
    echo -e "Channel : \e[1;36m$CHANNEL\e[0m"
    echo -e "Admin   : \e[1;36m$ADMIN\e[0m"
    echo -e "\e[1;34m===========================================\e[0m"
}

# =========[ Main Menu ]=========
main_menu() {
    while true; do
        print_title
        echo -e "\n[1] Generate Warp IPs"
        echo "[2] Install/Uninstall Installer Command"
        echo "[3] Show Telegram MTProto Proxies"
        echo "[4] Exit"
        echo -ne "\nSelect an option: "; read choice

        case $choice in
            1)
                echo -e "\n🔍 Generating 10 Warp IPs with random ports...\n"
                for i in {1..10}; do
                    ip=$(curl -s https://api64.ipify.org)
                    port=$((RANDOM % 65535 + 1))
                    echo "IP $i: $ip:$port"
                done
                echo -e "\nPress Enter to return..."
                read
                ;;
            2)
                echo -e "\n[1] Install command (Academivpn_warp)"
                echo "[2] Uninstall command"
                echo "[3] Back"
                echo -ne "Select: "; read opt
                if [[ $opt == 1 ]]; then
                    cp "$0" /data/data/com.termux/files/usr/bin/Academivpn_warp
                    chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
                    echo "✅ Installed. Now run: Academivpn_warp"
                    sleep 2
                elif [[ $opt == 2 ]]; then
                    rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
                    echo "🗑️ Uninstalled successfully."
                    sleep 1
                fi
                ;;
            3)
                echo -e "\n🌐 Top 10 Telegram MTProto Proxies:\n"
                if [[ ! -s "$PROXY_FILE" ]]; then
                    fetch_proxies || {
                        echo -e "\nPress Enter to return..."; read
                        continue
                    }
                fi
                COUNT=1
                while IFS= read -r line && [[ $COUNT -le 10 ]]; do
                    echo "Proxy $COUNT: $line"
                    ((COUNT++))
                done < "$PROXY_FILE"
                echo -e "\nPress Enter to return..."
                read
                ;;
            4)
                echo -e "\n👋 Exiting..."
                exit 0
                ;;
            *)
                echo -e "\n❌ Invalid option."
                sleep 1
                ;;
        esac
    done
}

# =========[ Main Execution ]=========
install_dependencies
fetch_proxies
auto_update_proxies
main_menu
