#!/bin/bash

# ========= INFO =========
VERSION="1.3.1"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
ALIAS_NAME="Academivpn_warp"

# ========= COLORS =========
GREEN="\e[92m"
RED="\e[91m"
CYAN="\e[96m"
YELLOW="\e[93m"
RESET="\e[0m"

# ========= INSTALL DEPENDENCIES =========
install_deps() {
    echo -e "${CYAN}Installing dependencies...${RESET}"
    pkg update -y > /dev/null 2>&1 || apt update -y > /dev/null 2>&1
    pkg install curl wget jq coreutils -y > /dev/null 2>&1 || apt install curl wget jq coreutils -y > /dev/null 2>&1
}

# ========= HEADER =========
show_header() {
    clear
    echo -e "${YELLOW}=========================================="
    echo -e "  AcademiVPN Panel v$VERSION"
    echo -e "  Admin: $ADMIN"
    echo -e "  Channel: $CHANNEL"
    echo -e "==========================================${RESET}"
}

# ========= WARP IP SCANNER =========
warp_ranges=("162.159.192" "162.159.193" "188.114.96" "104.16.0" "104.17.0")

scan_warp_ips() {
    echo -e "${CYAN}Scanning WARP IPv4 IPs...${RESET}"
    count=0
    for range in "${warp_ranges[@]}"; do
        for i in $(shuf -i 1-254 -n 2); do
            ip="$range.$i"
            port=$(shuf -i 1-65535 -n 1)
            ping_result=$(ping -c 1 -W 1 $ip 2>/dev/null)
            if echo "$ping_result" | grep -q "time="; then
                ping_ms=$(echo "$ping_result" | grep 'time=' | awk -F"time=" '{print $2}' | cut -d' ' -f1)
                echo -e "${GREEN}$ip:$port  -> Ping: ${ping_ms}ms${RESET}"
                count=$((count+1))
                [[ $count -eq 10 ]] && return
            fi
        done
    done
    [[ $count -eq 0 ]] && echo -e "${RED}❌ No active IPs found.${RESET}"
}

# ========= TELEGRAM PROXIES =========
fetch_proxies() {
    echo -e "${CYAN}Fetching Telegram proxies...${RESET}"
    response=$(curl -s https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/tg.txt)
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to fetch proxies.${RESET}"
        return
    fi
    proxies=$(echo "$response" | shuf | head -n 10)
    echo -e "${GREEN}✅ Top 10 Telegram Proxies:${RESET}"
    echo "$proxies"
}

# ========= INSTALL LAUNCHER =========
install_installer() {
    echo -e "${CYAN}Installing launcher...${RESET}"
    chmod +x warp.sh
    cp warp.sh /data/data/com.termux/files/usr/bin/$ALIAS_NAME 2>/dev/null || sudo cp warp.sh /usr/local/bin/$ALIAS_NAME
    chmod +x /data/data/com.termux/files/usr/bin/$ALIAS_NAME 2>/dev/null || sudo chmod +x /usr/local/bin/$ALIAS_NAME
    echo -e "${GREEN}✅ Installed! Run with: ${YELLOW}$ALIAS_NAME${RESET}"
    exit 0
}

# ========= REMOVE INSTALLER =========
remove_installer() {
    echo -e "${CYAN}Removing launcher...${RESET}"
    rm -f /data/data/com.termux/files/usr/bin/$ALIAS_NAME 2>/dev/null || sudo rm -f /usr/local/bin/$ALIAS_NAME
    echo -e "${GREEN}✅ Removed launcher.${RESET}"
    exit 0
}

# ========= MAIN MENU =========
main_menu() {
    while true; do
        show_header
        echo -e "${CYAN}1) WARP IP Scanner"
        echo -e "2) Telegram Proxy Fetcher"
        echo -e "3) Install Launcher ($ALIAS_NAME)"
        echo -e "4) Remove Launcher"
        echo -e "5) Exit${RESET}"
        read -p $'\nChoose an option: ' opt

        case $opt in
            1) scan_warp_ips ;;
            2) fetch_proxies ;;
            3) install_installer ;;
            4) remove_installer ;;
            5) echo -e "${YELLOW}Bye.${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid option.${RESET}" ;;
        esac

        echo -e "\nPress Enter to return..."
        read
    done
}

# ========= RUN =========
install_deps
main_menu
