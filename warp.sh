#!/bin/bash

# ╔═╗┌─┐┬─┐┬ ┬┌┬┐┌─┐┬
# ║  ├┤ ├┬┘└┬┘ │ ├┤ │
# ╚═╝└─┘┴└─ ┴  ┴ └─┘┴─┘

# ▶ Version and Info
VERSION="1.0.0"
CHANNEL="Telegram: @Academi_vpn"
SUPPORT="Admin: @MahdiAGM0"

# ▶ Color Codes
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
RED='\e[1;31m'
NC='\e[0m'

# ▶ Check & install dependencies
install_dependencies() {
    for pkg in curl jq; do
        if ! command -v $pkg &>/dev/null; then
            echo -e "${YELLOW}Installing $pkg...${NC}"
            apt update -y >/dev/null 2>&1
            apt install -y $pkg >/dev/null 2>&1
        fi
    done
}

# ▶ Header
show_header() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "${GREEN}    Academi Multi Tool"
    echo -e "${YELLOW}        Version: $VERSION"
    echo -e "${BLUE}=============================="
    echo -e "${GREEN}$CHANNEL"
    echo -e "${GREEN}$SUPPORT"
    echo -e "${BLUE}==============================${NC}"
}

# ▶ WARP IP Scanner (IPv4 only)
warp_scanner() {
    echo -e "${YELLOW}Scanning best WARP IPv4 IPs...${NC}"

    mkdir -p Academi_Configs
    > live_ips.txt

    COUNT=0
    while [ $COUNT -lt 10 ]; do
        IP=$(curl -s --connect-timeout 2 https://api64.ipify.org)
        [ -z "$IP" ] && continue

        for PORT in 80 443 8080 8443; do
            ping_result=$(ping -c1 -W1 $IP 2>/dev/null)
            if echo "$ping_result" | grep -q 'time='; then
                LATENCY=$(echo "$ping_result" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
                echo "$IP:$PORT  Ping: ${LATENCY}ms" | tee -a live_ips.txt
                ((COUNT++))
                break
            fi
        done
    done

    echo -e "\n${GREEN}✔ Done. Total working IPs: $COUNT${NC}"
}

# ▶ Proxy Updater
update_proxies() {
    echo -e "${BLUE}Updating Telegram MTProto proxies...${NC}"
    curl -s "https://raw.githubusercontent.com/aliilapro/mtproto-proxies/main/mtproto.txt" -o proxies.txt
    [[ -s proxies.txt ]] && echo -e "${GREEN}✔ Updated successfully.${NC}" || echo -e "${RED}❌ Failed to update.${NC}"
}

# ▶ Proxy Viewer
show_proxies() {
    [[ ! -f proxies.txt ]] && update_proxies
    echo -e "${YELLOW}\n📡 Telegram Proxies (Top 10):${NC}"
    nl proxies.txt | head -n 10
    echo -e "${BLUE}\nLast Updated: $(date)${NC}"
}

# ▶ Main Menu
main_menu() {
    show_header
    echo -e "${YELLOW}1) WARP IPv4 Scanner"
    echo -e "2) Telegram Proxy List"
    echo -e "0) Exit${NC}"
    echo -ne "${BLUE}Choose an option: ${NC}"
    read opt

    case $opt in
        1) warp_scanner ;;
        2) show_proxies ;;
        0) exit ;;
        *) echo -e "${RED}❌ Invalid option${NC}"; sleep 1 ;;
    esac
}

# ▶ Main Loop
install_dependencies
while true; do
    main_menu
    echo -ne "${BLUE}\nPress enter to return to menu...${NC}"
    read
done
