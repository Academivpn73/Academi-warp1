#!/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ #
#        Academi Warp Tool         #
#   Version: 1.0.1 | @Academi_vpn  #
#    Support: @MahdiAGM0           #
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ #

# ─────────── Colors ──────────── #
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROXY_FILE="academi_proxies.txt"
IP_FILE="academi_ips.txt"

# ──────── Banner ───────── #
banner() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}      Academi Warp Scanner Tool"
    echo -e "${YELLOW}        Version: 1.0.1"
    echo -e "${CYAN}   Channel: @Academi_vpn"
    echo -e "${CYAN}   Admin:   @MahdiAGM0"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ─────── Install Dependencies ─────── #
install_deps() {
    for pkg in curl jq; do
        if ! command -v $pkg &> /dev/null; then
            echo -e "${YELLOW}Installing $pkg...${NC}"
            apt update -y &>/dev/null
            apt install -y $pkg &>/dev/null
        fi
    done
}

# ────── Telegram Proxy Updater ───── #
update_proxies() {
    echo -e "${YELLOW}\nUpdating Telegram proxies...${NC}"
    curl -s https://api.proxyscrape.com/?request=displayproxies&proxytype=socks5&timeout=1000&country=all > $PROXY_FILE
    head -n 10 $PROXY_FILE > temp && mv temp $PROXY_FILE
    echo -e "${GREEN}✔ Updated proxies saved to ${PROXY_FILE}${NC}"
    echo -e "\nTop 10 Proxies:\n"
    nl -w2 -s'. ' $PROXY_FILE
    echo -e "\n${CYAN}Proxies will auto-update every 5 hours...${NC}"
}

# Auto-update proxies every 5 hours (background)
schedule_proxy_updates() {
    (while true; do
        update_proxies
        sleep 18000  # 5 hours
    done) &
}

# ────── Warp IPv4 IP Scanner ─────── #
scan_warp_ips() {
    echo -e "${YELLOW}\nScanning best WARP IPv4 IPs...${NC}"
    > $IP_FILE
    local count=0
    IP_RANGE="162.159.192"

    while [[ $count -lt 10 ]]; do
        LAST_OCTET=$((RANDOM % 255))
        IP="$IP_RANGE.$LAST_OCTET"

        PORTS=(80 443 8080 8443)
        for port in "${PORTS[@]}"; do
            timeout 1 bash -c "echo >/dev/tcp/$IP/$port" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                PING=$(ping -c1 -W1 $IP 2>/dev/null | grep time= | cut -d= -f4 | cut -d' ' -f1)
                [[ -z "$PING" ]] && continue
                echo -e "${GREEN}$IP:$port  Ping: ${PING}ms${NC}"
                echo "$IP:$port  Ping: ${PING}ms" >> $IP_FILE
                ((count++))
                break
            fi
        done
    done

    echo -e "\n${CYAN}✔ Saved to $IP_FILE${NC}"
    read -p "Press Enter to return to menu..."
}

# ─────── Main Menu ──────── #
main_menu() {
    while true; do
        banner
        echo -e "${YELLOW}1) WARP IPv4 IP Scanner"
        echo -e "2) Telegram Proxy List"
        echo -e "3) Exit${NC}"
        echo
        read -p "Select an option: " opt
        case $opt in
            1) scan_warp_ips ;;
            2) cat $PROXY_FILE; echo -e "\n${CYAN}Auto-update every 5h is running...${NC}"; read -p "Press Enter to return..." ;;
            3) echo -e "${RED}Exiting...${NC}"; exit ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}

# ─────── Start Script ─────── #
install_deps
schedule_proxy_updates
main_menu
