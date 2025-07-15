#!/bin/bash

# Academi VPN Tool
# Telegram: @Academi_vpn
#Admin: @MahdiAGM0

# Colors
RED='\e[91m'
GRN='\e[92m'
YEL='\e[93m'
NC='\e[0m'

# Auto install dependencies
deps=(curl jq ping)
for dep in "${deps[@]}"; do
    if ! command -v $dep >/dev/null 2>&1; then
        echo -e "${YEL}Installing $dep...${NC}"
        pkg install -y $dep 2>/dev/null || apt install -y $dep
    fi
done

# Function: Scan 10 WARP IPs
scan_warp_ips() {
    echo -e "${YEL}Scanning WARP IPs (max 10)...${NC}"
    mkdir -p tmp_ips
    cd tmp_ips || exit

    count=0
    while [ $count -lt 10 ]; do
        ip=$(curl -s --connect-timeout 3 https://api64.ipify.org)
        port=$(shuf -n 1 -e 80 443 2086 8443 8080)
        ping_ms=$(ping -c 1 -W 1 "$ip" | grep time= | sed -E 's/.*time=([0-9.]+).*/\1/')
        nc -z -w1 "$ip" "$port" >/dev/null 2>&1

        if [[ $? -eq 0 && $ping_ms != "" ]]; then
            echo -e "${GRN}$ip:$port  Ping: ${ping_ms}ms${NC}"
            ((count++))
        fi
    done

    cd ..
    rm -rf tmp_ips
}

# Function: Show Telegram proxies
show_telegram_proxies() {
    echo -e "${YEL}Academi VPN Telegram Proxies:${NC}"

    # 👇 هر روز این لیست رو به‌روز کن:
    proxies=(
        "tg://proxy?server=proxy1.academi.ir&port=443&secret=ee00000000000000000000000000000000000000"
        "tg://proxy?server=proxy2.academi.ir&port=443&secret=ee00000000000000000000000000000000000000"
        "tg://proxy?server=proxy3.academi.ir&port=443&secret=ee00000000000000000000000000000000000000"
    )

    for proxy in "${proxies[@]}"; do
        echo -e "${GRN}$proxy${NC}"
    done
}

# Main menu
clear
echo -e "${GRN}Academi VPN Tool${NC}"
echo "=============================="
echo "1. WARP IP Scanner"
echo "2. Telegram Proxies"
echo "0. Exit"
echo "=============================="
read -p "Select option: " opt

case $opt in
  1) scan_warp_ips ;;
  2) show_telegram_proxies ;;
  0) exit ;;
  *) echo -e "${RED}Invalid option.${NC}" ;;
esac
