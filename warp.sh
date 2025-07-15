#!/bin/bash

# ─────────────────────────────────────────────
# Academi Tools - WARP Scanner & Telegram Proxy
# Telegram: @Academi_vpn
# Admin: @MahdiAGM0
# Version 1.0.0
# ─────────────────────────────────────────────

install_dependencies() {
    echo "🔧 Installing dependencies..."
    apt update -y &>/dev/null
    apt install curl wget jq ping -y &>/dev/null
}

main_menu() {
    clear
    echo -e "============ Academi Tools ============"
    echo -e "1. WARP IPv4 IP Scanner"
    echo -e "2. Telegram Proxy Fetcher"
    echo -e "0. Exit"
    echo -e "======================================="
    read -p "Select an option: " option
    case $option in
        1) warp_scanner ;;
        2) fetch_telegram_proxies ;;
        0) exit ;;
        *) echo "❌ Invalid option"; sleep 2; main_menu ;;
    esac
}

warp_scanner() {
    echo -e "\n📡 Scanning best WARP IPv4 IPs..."
    ports=(80 443 2086 2087 2095 2096)
    IP_LIST=()

    for i in $(seq 1 50); do
        ip=$(curl -s --interface warp --connect-timeout 3 https://api64.ipify.org)
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            for port in "${ports[@]}"; do
                (echo > /dev/tcp/$ip/$port) >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    ping_result=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
                    if [[ ! -z "$ping_result" ]]; then
                        IP_LIST+=("$ip:$port  Ping: ${ping_result}ms")
                        break
                    fi
                fi
            done
        fi
        [ ${#IP_LIST[@]} -ge 10 ] && break
    done

    if [ ${#IP_LIST[@]} -eq 0 ]; then
        echo "❌ No working IPs found."
    else
        echo -e "\n✔ Best WARP IPv4 IPs:"
        for ip in "${IP_LIST[@]}"; do
            echo "$ip"
        done
    fi
    echo -e "\n🔁 Returning to menu..."
    read -p "Press enter to continue..." nothing
    main_menu
}

fetch_telegram_proxies() {
    echo -e "\n📡 Fetching Telegram Proxies..."
    proxies=$(curl -s "https://raw.githubusercontent.com/TelegramProxies/proxy-list/main/proxies.json" | jq -r '.[] | "\(.ip):\(.port)"' | head -n 10)
    if [ -z "$proxies" ]; then
        echo "❌ Failed to fetch proxies."
    else
        echo -e "\n✔ Telegram Proxies:"
        echo "$proxies"
    fi
    echo -e "\n🔁 Returning to menu..."
    read -p "Press enter to continue..." nothing
    main_menu
}

# Start the script
install_dependencies
main_menu
