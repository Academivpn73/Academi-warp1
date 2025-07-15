#!/bin/bash

VERSION="1.2.0"
ALIAS_PATH="/data/data/com.termux/files/usr/bin/Academi_warp"

# رنگ‌ها
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

install_requirements() {
    echo -e "${YELLOW}🔧 Installing requirements...${NC}"
    pkg update -y > /dev/null
    pkg install curl wget jq bash -y > /dev/null
}

install_alias() {
    cp "$0" "$ALIAS_PATH"
    chmod +x "$ALIAS_PATH"
    echo -e "${GREEN}✔ Installed! Now you can run: ${CYAN}Academi_warp${NC}"
}

remove_alias() {
    rm -f "$ALIAS_PATH"
    echo -e "${RED}✖ Alias removed!${NC}"
}

fetch_proxies() {
    echo -e "${CYAN}🌐 Fetching fresh Telegram proxies...${NC}"
    proxies=$(curl -s https://raw.githubusercontent.com/officialputuid/KangProxies/main/tg.txt | head -n 10)
    if [[ -z "$proxies" ]]; then
        echo -e "${RED}✘ Failed to fetch proxies.${NC}"
    else
        echo -e "${GREEN}✔ Proxies:${NC}"
        echo "$proxies"
    fi
}

scan_warp_ips() {
    echo -e "${CYAN}🌍 Scanning active WARP IPs...${NC}"
    count=0
    for i in {1..500}; do
        ip="162.159.$((RANDOM % 256)).$((RANDOM % 256))"
        port=$((RANDOM % 65535 + 1))
        ping_result=$(ping -c1 -W1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [[ ! -z "$ping_result" ]]; then
            echo -e "${GREEN}✔ IP:$ip:$port  ${NC}| Ping: ${ping_result}ms"
            count=$((count + 1))
        fi
        [[ $count -eq 10 ]] && break
    done

    [[ $count -eq 0 ]] && echo -e "${RED}✘ No active WARP IPs found.${NC}"
}

generate_wireguard_config() {
    echo -e "${CYAN}⚙ Generating real WireGuard config (WARP)...${NC}"
    curl -s -X POST "https://api.cloudflareclient.com/v0a745/reg" \
        -H "Content-Type: application/json" \
        --data '{"install_id":"","key":"","tos":"2023-01-01T00:00:00.000Z","fcm_token":""}' > wgdata.json

    PRIVATE_KEY=$(jq -r .private_key wgdata.json)
    PUBLIC_KEY=$(jq -r .peer_public_key wgdata.json)
    ENDPOINT=$(jq -r .endpoint wgdata.json)

    if [[ -z "$PRIVATE_KEY" || -z "$PUBLIC_KEY" || -z "$ENDPOINT" ]]; then
        echo -e "${RED}✘ Failed to fetch WireGuard config.${NC}"
        return
    fi

    cat <<EOF > wgcf.conf
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 172.16.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $PUBLIC_KEY
Endpoint = $ENDPOINT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

    echo -e "${GREEN}✔ WireGuard config saved to: ${CYAN}wgcf.conf${NC}"
}

main_menu() {
    clear
    echo -e "${CYAN}┌──────────────────────────────────────┐"
    echo -e "│      ${GREEN}Academi WARP Toolkit v$VERSION${CYAN}     │"
    echo -e "│  Channel: @Academi_vpn  Support: @MahdiAGMO │"
    echo -e "└──────────────────────────────────────┘${NC}"
    echo ""
    echo "1. 🔍 Scan WARP IPs"
    echo "2. 🌐 Get Telegram Proxies"
    echo "3. ⚙ Generate WireGuard Config (WARP)"
    echo "4. 📥 Install as command (Academi_warp)"
    echo "5. 🗑 Remove command (Academi_warp)"
    echo "6. ❌ Exit"
    echo ""
    read -p "Select: " choice
    case $choice in
        1) scan_warp_ips ;;
        2) fetch_proxies ;;
        3) generate_wireguard_config ;;
        4) install_alias ;;
        5) remove_alias ;;
        6) exit 0 ;;
        *) echo -e "${RED}[!] Invalid choice.${NC}" ;;
    esac
    echo ""
    read -p "Press Enter to return to menu..."
    main_menu
}

install_requirements
main_menu
