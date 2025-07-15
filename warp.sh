#!/bin/bash

# ========= Basic Info ========= #
VERSION="1.2.0"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"

# ========= Colors ========= #
GREEN="\e[92m"
RED="\e[91m"
CYAN="\e[96m"
YELLOW="\e[93m"
RESET="\e[0m"

# ========= Install Dependencies ========= #
install_dependencies() {
    echo -e "${CYAN}Installing required packages...${RESET}"
    pkg update -y > /dev/null 2>&1
    pkg install curl jq wget coreutils -y > /dev/null 2>&1
}

# ========= Show Header ========= #
show_header() {
    clear
    echo -e "${YELLOW}==============================="
    echo -e "   AcademiVPN Script v$VERSION"
    echo -e "   Support: $ADMIN"
    echo -e "   Channel: $CHANNEL"
    echo -e "===============================${RESET}"
}

# ========= Fetch Telegram Proxies ========= #
fetch_proxies() {
    echo -e "${CYAN}Fetching fresh Telegram proxies...${RESET}"
    proxy_list=$(curl -s https://api.openproxylist.xyz/tg | jq -r '.[] | "tg://proxy?server=\(.ip)&port=\(.port)&secret=\(.secret)"' | head -n 10)
    if [[ -z "$proxy_list" ]]; then
        echo -e "${RED}❌ Failed to fetch proxies.${RESET}"
    else
        echo -e "${GREEN}✅ Proxies Updated:${RESET}"
        echo "$proxy_list"
    fi
}

# ========= WARP IP Scanner ========= #
warp_ip_ranges=("162.159.192" "162.159.193" "162.159.195" "188.114.96" "188.114.97")

scan_warp_ips() {
    echo -e "${CYAN}Scanning best WARP IPv4 IPs...${RESET}"
    count=0
    for ip_range in "${warp_ip_ranges[@]}"; do
        for i in $(shuf -i 1-254 -n 20); do
            for port in 80 443 8080 2052 2082 2086 2095 8443 8880; do
                ip="$ip_range.$i"
                ping_result=$(ping -c 1 -W 1 $ip 2>/dev/null)
                if echo "$ping_result" | grep -q "time="; then
                    ping_ms=$(echo "$ping_result" | grep 'time=' | awk -F"time=" '{print $2}' | cut -d' ' -f1)
                    echo -e "${GREEN}$ip:$port  Ping: ${ping_ms}ms${RESET}"
                    count=$((count + 1))
                    [[ $count -ge 10 ]] && return
                fi
            done
        done
    done

    [[ $count -eq 0 ]] && echo -e "${RED}❌ No working IPs found.${RESET}"
}

# ========= Main Menu ========= #
main_menu() {
    while true; do
        show_header
        echo -e "${CYAN}1) WARP IP Scanner"
        echo -e "2) Telegram Proxy Fetcher"
        echo -e "3) Exit${RESET}"
        read -p $'\nChoose an option: ' opt

        case $opt in
            1) scan_warp_ips ;;
            2) fetch_proxies ;;
            3) echo -e "${YELLOW}Exiting...${RESET}"; exit 0 ;;
            *) echo -e "${RED}❌ Invalid option${RESET}" ;;
        esac
        echo -e "\nPress Enter to return to menu..."
        read
    done
}

# ========= Start Script ========= #
install_dependencies
main_menu
