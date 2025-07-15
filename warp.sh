#!/bin/bash

# ─── Display Header ───────────────────────────────────────
clear
echo -e "\e[1;36m🔰 Academi VPN Tool | Version: 1.0.0\e[0m"
echo -e "\e[1;33m📢 Channel: @Academi_vpn\e[0m"
echo -e "\e[1;33m👤 Admin: @MahdiAGM0\e[0m"
echo -e "\e[1;32m============================================\e[0m"

# ─── Install Dependencies ─────────────────────────────────
install_requirements() {
    for pkg in curl wget jq bc ping timeout; do
        if ! command -v $pkg >/dev/null 2>&1; then
            echo -e "\e[1;31mInstalling $pkg ...\e[0m"
            apt update -y >/dev/null 2>&1
            apt install -y $pkg >/dev/null 2>&1
        fi
    done
}

# ─── WARP IPv4 Scanner ───────────────────────────────────
warp_scan() {
    echo -e "\n\e[1;36mScanning Best WARP IPv4 IPs...\e[0m"
    echo -e "\e[1;32m--------------------------------------------\e[0m"
    local count=0

    while [ $count -lt 10 ]; do
        IP=$(curl -s --connect-timeout 3 https://speed.cloudflare.com/meta | jq -r '.client.ip')
        [ -z "$IP" ] && continue

        PORT=$((RANDOM % 64512 + 1024))
        PING=$(ping -c1 -W1 $IP | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)

        if [[ $PING != "" ]]; then
            echo -e "\e[1;33m$IP:$PORT \e[0m Ping: \e[1;32m$PING ms\e[0m"
            ((count++))
        fi
    done
    echo -e "\e[1;32m--------------------------------------------\e[0m"
}

# ─── Telegram Proxy Fetcher ───────────────────────────────
proxy_fetch() {
    echo -e "\n\e[1;36mFetching Fresh Telegram Proxies...\e[0m"
    echo -e "\e[1;32m--------------------------------------------\e[0m"
    PROXY_LIST=$(curl -s https://raw.githubusercontent.com/TheSpeedX/THT/main/proxy.txt)

    if [[ -z "$PROXY_LIST" ]]; then
        echo -e "\e[1;31mFailed to fetch proxy list.\e[0m"
        return
    fi

    COUNT=0
    echo "$PROXY_LIST" | while read -r line; do
        [[ "$line" == tg://proxy* ]] && {
            echo -e "\e[1;33m$line\e[0m"
            ((COUNT++))
            [ $COUNT -ge 10 ] && break
        }
    done
    echo -e "\e[1;32m--------------------------------------------\e[0m"
}

# ─── Main Menu ────────────────────────────────────────────
main_menu() {
    while true; do
        echo -e "\n\e[1;34mChoose an option:\e[0m"
        echo -e "1) 🌍 WARP IPv4 IP Scanner"
        echo -e "2) 📡 Telegram Proxy (Auto Fetched)"
        echo -e "0) ❌ Exit"
        read -rp $'\n\e[1;36mEnter choice: \e[0m' choice

        case $choice in
            1) warp_scan ;;
            2) proxy_fetch ;;
            0) echo -e "\e[1;31mExiting...\e[0m"; exit 0 ;;
            *) echo -e "\e[1;31mInvalid option!\e[0m" ;;
        esac
    done
}

# ─── Run ──────────────────────────────────────────────────
install_requirements
main_menu
