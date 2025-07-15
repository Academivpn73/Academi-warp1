#!/bin/bash

# ───────────── Title Info ─────────────
VERSION="1.2.1"
ADMIN="@MahdiAGM0"
CHANNEL="@AcademiVPN"
TITLE="AcademiVPN WARP Tool v$VERSION"

# ───────────── Colors ─────────────
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# ───────────── Install Requirements ─────────────
install_requirements() {
    echo -e "${CYAN}[+] Installing required packages...${RESET}"
    pkg update -y > /dev/null 2>&1
    pkg install curl wget jq -y > /dev/null 2>&1
    echo -e "${GREEN}[✓] Requirements installed.${RESET}"
}

# ───────────── Enhanced Proxy Fetcher ─────────────
fetch_proxies() {
    echo -e "${CYAN}Fetching Telegram proxies from global sources...${RESET}"

    sources=(
        "https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks5.txt"
        "https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/txt/proxy-list-socks5.txt"
        "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
        "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/socks5.txt"
        "https://raw.githubusercontent.com/roosterkid/openproxylist/main/SOCKS5_RAW.txt"
        "https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt"
        "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/socks5.txt"
        "https://raw.githubusercontent.com/rdavydov/proxy-list/main/proxies/socks5.txt"
        "https://raw.githubusercontent.com/mmpx12/proxy-list/master/socks5.txt"
        "https://raw.githubusercontent.com/Zaeem20/FREE_PROXIES_LIST/master/socks5.txt"
        # اضافه کن هر تعداد دیگه‌ای که خواستی...
    )

    all_proxies=""
    for src in "${sources[@]}"; do
        temp=$(curl -s --max-time 10 "$src" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{2,5}')
        [[ -n "$temp" ]] && all_proxies+=$'\n'"$temp"
    done

    unique_proxies=$(echo "$all_proxies" | grep -v '^$' | sort -u | shuf | head -n 10)

    if [[ -z "$unique_proxies" ]]; then
        echo -e "${RED}❌ No proxies found.${RESET}"
    else
        echo -e "${GREEN}✅ Top 10 Telegram Proxies:${RESET}"
        echo "$unique_proxies"
    fi
}

# ───────────── Warp Scanner ─────────────
scan_warp_ips() {
    echo -e "${CYAN}Scanning WARP IPs from Cloudflare ranges...${RESET}"

    ipv4_ranges=(
        "162.159.192.0"
        "188.114.96.0"
        "104.28.0.0"
        "198.41.192.0"
    )

    for i in {1..10}; do
        base_ip=${ipv4_ranges[$((RANDOM % ${#ipv4_ranges[@]}))]}
        ip=$(echo $base_ip | awk -F. -v r=$((RANDOM % 255)) '{$4=r; print $1"."$2"."$3"."$4}')
        port=$((RANDOM % 65535 + 1))

        ping -c 1 -W 1 "$ip" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✓ $ip:$port is responsive${RESET}"
        else
            echo -e "${YELLOW}- $ip:$port is not responsive${RESET}"
        fi
    done
}

# ───────────── Installer Shortcut ─────────────
install_installer() {
    echo -e "${CYAN}Installing launcher command...${RESET}"
    echo "bash $(realpath $0)" > $PREFIX/bin/Academivpn_warp
    chmod +x $PREFIX/bin/Academivpn_warp
    echo -e "${GREEN}✓ Now you can run with: ${YELLOW}Academivpn_warp${RESET}"
}

remove_installer() {
    rm -f $PREFIX/bin/Academivpn_warp
    echo -e "${RED}✘ Launcher removed. Use bash warp.sh to run manually.${RESET}"
}

# ───────────── Main Menu ─────────────
main_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════╗"
    echo -e "║   ${TITLE}   ║"
    echo -e "╠══════════════════════════════════════╣"
    echo -e "║ Admin:  ${YELLOW}${ADMIN}${CYAN}               ║"
    echo -e "║ Channel:${YELLOW}${CHANNEL}${CYAN}              ║"
    echo -e "╚══════════════════════════════════════╝${RESET}"

    echo -e "
1) Install Requirements
2) Show Telegram Proxies
3) Scan WARP IPs
4) Install Shortcut (Academivpn_warp)
5) Remove Shortcut
0) Exit
"

    read -p "Select an option: " opt
    case "$opt" in
        1) install_requirements ;;
        2) fetch_proxies ;;
        3) scan_warp_ips ;;
        4) install_installer ;;
        5) remove_installer ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option.${RESET}";;
    esac

    read -p "Press Enter to return..." && main_menu
}

# ───────────── Run ─────────────
main_menu
