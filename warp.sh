#!/bin/bash

#────────────────────────────#
#     Academi WARP Tools     #
#     Telegram: @Academi_vpn #
#────────────────────────────#

GREEN='\e[32m'
BLUE='\e[34m'
RED='\e[31m'
RESET='\e[0m'

show_menu() {
    echo -e "${BLUE}┌────────────────────────────┐${RESET}"
    echo -e "${BLUE}│  Academi VPN Main Menu     │${RESET}"
    echo -e "${BLUE}├────────────────────────────┤${RESET}"
    echo -e "  [1] WARP IPv4 Scanner"
    echo -e "  [2] Telegram Proxy Viewer"
    echo -e "  [0] Exit"
    echo -e "${BLUE}└────────────────────────────┘${RESET}"
}

warp_scanner() {
    echo -e "\n${BLUE}🔍 Scanning best WARP IPv4 IPs...${RESET}"

    PORTS=(80 443 8080 8443)
    MAX_IPS=10
    > good_ips.txt

    count=0

    while [[ $count -lt $MAX_IPS ]]; do
        IP=$(curl -s https://cloudflare.com/cdn-cgi/trace | grep ip= | cut -d= -f2 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
        
        if [[ -z "$IP" ]]; then
            continue
        fi

        for PORT in "${PORTS[@]}"; do
            timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                PING_MS=$(ping -c 1 -W 1 $IP | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
                if [[ -n "$PING_MS" ]]; then
                    echo "$IP:$PORT  $PING_MS ms" >> good_ips.txt
                    ((count++))
                    break
                fi
            fi
        done
    done

    echo -e "${GREEN}\n✅ Top $MAX_IPS Working WARP IPs:${RESET}"
    cat good_ips.txt
    echo ""
}

telegram_proxy_viewer() {
    echo -e "\n${BLUE}📢 Telegram Proxy List:${RESET}"

    # 📝 این لیست رو خودت می‌تونی روزانه ویرایش کنی:
    proxies=(
        "tg://proxy?server=proxy1.academi.ir&port=443&secret=ee00000000000000000000000000000000000000"
        "tg://proxy?server=proxy2.academi.ir&port=443&secret=ee00000000000000000000000000000000000000"
        "tg://proxy?server=proxy3.academi.ir&port=443&secret=ee00000000000000000000000000000000000000"
    )

    for proxy in "${proxies[@]}"; do
        echo -e "${GREEN}- $proxy${RESET}"
    done

    echo ""
}

# Start
clear
while true; do
    show_menu
    read -p $'\nChoose an option: ' choice
    case "$choice" in
        1) warp_scanner ;;
        2) telegram_proxy_viewer ;;
        0) echo -e "${RED}Exiting...${RESET}"; exit ;;
        *) echo -e "${RED}❌ Invalid option!${RESET}" ;;
    esac
done
