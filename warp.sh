#!/bin/bash

VERSION="1.2.0"
CHANNEL="@Academi_vpn"
ADMIN="@MahdiAGM0"

clear
echo -e "\e[36m===============================\e[0m"
echo -e "  🚀 Academi VPN Panel v$VERSION"
echo -e "  📢 Telegram: $CHANNEL"
echo -e "  👤 Admin: $ADMIN"
echo -e "\e[36m===============================\e[0m"

install_dependencies() {
    pkg update -y &> /dev/null
    pkg install curl grep sed coreutils inetutils -y &> /dev/null
}

setup_installer() {
    echo "bash $(realpath $0)" > /data/data/com.termux/files/usr/bin/Academivpn_warp
    chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
    echo -e "✅ Installed. Run using: \e[32mAcademivpn_warp\e[0m"
}

remove_installer() {
    rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
    echo "❌ Installer removed."
}

generate_warp_ips() {
    echo -e "\n🌍 Generating WARP IPs with ping..."
    for i in {1..10}; do
        ip="162.$((100 + RANDOM % 50)).$((RANDOM % 256)).$((RANDOM % 256))"
        port=$((1000 + RANDOM % 65000))
        ping_result=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [[ -z "$ping_result" ]]; then ping_result="Timeout"; fi
        echo "➡️ $ip:$port  📶 Ping: $ping_result ms"
    done
}

fetch_proxies() {
    echo -e "\n🌐 Fetching public HTTP/SOCKS proxies..."

    urls=(
        "https://www.sslproxies.org"
        "https://free-proxy-list.net"
        "https://www.socks-proxy.net"
    )

    all_proxies=""

    for url in "${urls[@]}"; do
        html=$(curl -s "$url")
        ips=$(echo "$html" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}</td><td>[0-9]{2,5}' | sed 's/<\/td><td>/:/g' | head -n 10)
        all_proxies+="$ips"$'\n'
    done

    if [[ -n "$all_proxies" ]]; then
        echo "$all_proxies" | sort -u > ~/.academi_proxies.txt
        echo -e "\n✅ Proxies saved to ~/.academi_proxies.txt\n"
        echo "$all_proxies"
    else
        echo "❌ Failed to fetch proxies."
    fi
}

main_menu() {
    echo -e "\n📋 Choose an option:"
    echo "1) 📥 Install Installer"
    echo "2) ❌ Remove Installer"
    echo "3) 🌐 Show Telegram Proxies"
    echo "4) 🌍 Generate WARP IPs"
    echo "0) 🚪 Exit"
    read -p ">> " opt

    case "$opt" in
        1) setup_installer ;;
        2) remove_installer ;;
        3) fetch_proxies ;;
        4) generate_warp_ips ;;
        0) exit ;;
        *) echo "Invalid option." ;;
    esac

    read -p "Press Enter to return..." dummy
    main_menu
}

install_dependencies
main_menu
