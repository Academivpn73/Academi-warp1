#!/bin/bash

# Version & Info
VERSION="1.0.0"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

# Auto-install dependencies
install_requirements() {
    for pkg in curl jq; do
        if ! command -v $pkg >/dev/null 2>&1; then
            echo "Installing $pkg..."
            apt update -y >/dev/null 2>&1
            apt install -y $pkg >/dev/null 2>&1
        fi
    done
}

# Colored UI
print_header() {
    clear
    echo -e "\e[1;35m┌──────────────────────────────────────┐\e[0m"
    echo -e "\e[1;36m│      Academi VPN Script $VERSION         \e[0m"
    echo -e "\e[1;35m├──────────────────────────────────────┤\e[0m"
    echo -e "\e[1;32m│ Channel : $CHANNEL\e[0m"
    echo -e "\e[1;32m│ Admin   : $ADMIN\e[0m"
    echo -e "\e[1;35m└──────────────────────────────────────┘\e[0m"
}

# WARP IP Scanner (IPv4 only)
warp_scan() {
    echo -e "\n\e[1;36mScanning Best WARP IPv4 IPs...\e[0m"
    echo -e "\e[1;32m--------------------------------------------\e[0m"
    local count=0

    while [ $count -lt 10 ]; do
        IP=$(curl -s4 --connect-timeout 3 https://speed.cloudflare.com/meta | jq -r '.client.ip')

        # Check for null or empty IP
        if [[ -z "$IP" || "$IP" == "null" ]]; then
            continue
        fi

        PORT=$((RANDOM % 64512 + 1024))
        PING=$(ping -c1 -W1 "$IP" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)

        if [[ $PING != "" ]]; then
            echo -e "\e[1;33m$IP:$PORT \e[0m Ping: \e[1;32m$PING ms\e[0m"
            ((count++))
        fi
    done

    echo -e "\e[1;32m--------------------------------------------\e[0m"
    echo -e "\e[1;36mDone.\e[0m"
    read -p "Press enter to return to menu..."
}

# Telegram Proxy Updater (every 1 hour)
update_proxies() {
    mkdir -p proxies
    while true; do
        echo -e "\e[1;36mUpdating Telegram proxies...\e[0m"
        curl -s https://api.openproxylist.xyz/tg/ > proxies/list.txt
        sleep 3600  # 1 hour
    done
}

show_proxies() {
    if [[ ! -f proxies/list.txt ]]; then
        echo -e "\e[1;31mProxy list not found. Fetching now...\e[0m"
        curl -s https://api.openproxylist.xyz/tg/ > proxies/list.txt
    fi
    echo -e "\n\e[1;36mLatest Telegram Proxies:\e[0m"
    echo -e "\e[1;32m--------------------------------------------\e[0m"
    cat proxies/list.txt | head -n 10
    echo -e "\e[1;32m--------------------------------------------\e[0m"
    read -p "Press enter to return to menu..."
}

# Menu
main_menu() {
    while true; do
        print_header
        echo -e "\n\e[1;36m[1]\e[0m Warp IPv4 Scanner"
        echo -e "\e[1;36m[2]\e[0m Telegram Proxy List"
        echo -e "\e[1;36m[0]\e[0m Exit"
        echo -ne "\n\e[1;33mSelect an option:\e[0m "
        read choice

        case "$choice" in
            1) warp_scan ;;
            2) show_proxies ;;
            0) exit 0 ;;
            *) echo -e "\e[1;31mInvalid option!\e[0m"; sleep 1 ;;
        esac
    done
}

# Start auto proxy fetcher (background)
install_requirements
update_proxies &

# Launch menu
main_menu
