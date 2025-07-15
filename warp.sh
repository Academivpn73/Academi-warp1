#!/data/data/com.termux/files/usr/bin/bash

#========[ INFO HEADER ]========#
clear
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

VERSION="1.6.5"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"

title() {
    echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "${CYAN}┃  ${GREEN}Academi VPN Panel           ${CYAN}┃"
    echo -e "${CYAN}┃  ${NC}Telegram: ${CHANNEL}         ${CYAN}┃"
    echo -e "${CYAN}┃  ${NC}Admin: ${ADMIN}             ${CYAN}┃"
    echo -e "${CYAN}┃  ${NC}Version: ${VERSION}              ${CYAN}┃"
    echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

#========[ DEPENDENCIES ]========#
install_requirements() {
    for pkg in curl wget jq grep ping; do
        if ! command -v $pkg &> /dev/null; then
            echo -e "${CYAN}Installing missing package: $pkg...${NC}"
            pkg install -y $pkg > /dev/null 2>&1
        fi
    done
}

#========[ TELEGRAM PROXIES ]========#
fetch_proxies() {
    echo -e "${GREEN}🔍 Fetching Telegram proxies...${NC}"
    sources=(
        "https://raw.githubusercontent.com/hamid-gh/Telegram-Proxies/main/tg.txt"
        "https://raw.githubusercontent.com/officialputuid/KangProxies/main/tg.txt"
        "https://raw.githubusercontent.com/prxchk/proxy-list/main/http.txt"
        "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt"
        "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/tg.txt"
    )

    proxies=()
    for src in "${sources[@]}"; do
        res=$(curl -fsSL "$src" | grep -Eo 'tg://proxy\?server=[^&]+&port=[0-9]+' | head -n 10)
        for p in $res; do
            proxies+=("$p")
        done
    done

    if [ ${#proxies[@]} -eq 0 ]; then
        echo -e "${RED}❌ No working proxies found.${NC}"
        return
    fi

    echo -e "${GREEN}✅ Found ${#proxies[@]} proxies:${NC}"
    idx=1
    for proxy in "${proxies[@]:0:10}"; do
        echo -e "${CYAN}Proxy $idx:${NC} $proxy"
        ((idx++))
    done
}

#========[ WARP IP SCANNER ]========#
generate_warp_ips() {
    echo -e "${GREEN}⚡ Generating WARP IPs with Port and Ping...${NC}"
    count=0
    while [ $count -lt 10 ]; do
        ip=$(printf "162.%d.%d.%d" $((RANDOM%255)) $((RANDOM%255)) $((RANDOM%255)))
        port=$((RANDOM % 65535 + 1))
        ping_ms=$(ping -c1 -W1 "$ip" 2>/dev/null | grep 'time=' | sed -n 's/.*time=\(.*\) ms/\1/p')

        if [ -n "$ping_ms" ]; then
            echo -e "${CYAN}[$((count+1))] ${GREEN}$ip:$port${NC}  ${CYAN}Ping:${NC} ${ping_ms}ms"
            ((count++))
        fi
    done
}

#========[ INSTALLER HANDLER ]========#
create_installer() {
    echo -e "${GREEN}✅ Creating shortcut command: Academivpn_warp${NC}"
    termux_path="/data/data/com.termux/files/usr/bin/Academivpn_warp"
    cp warp.sh "$termux_path"
    chmod +x "$termux_path"
    echo -e "${GREEN}🎉 Done! Now you can run the panel with: ${CYAN}Academivpn_warp${NC}"
}

remove_installer() {
    rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
    echo -e "${RED}❌ Installer removed. Use ./warp.sh to run manually.${NC}"
}

#========[ MENU ]========#
main_menu() {
    while true; do
        clear
        title
        echo ""
        echo -e "${CYAN}1.${NC} Generate WARP IP:Port"
        echo -e "${CYAN}2.${NC} Get Telegram Proxies"
        echo -e "${CYAN}3.${NC} Create Installer Shortcut"
        echo -e "${CYAN}4.${NC} Remove Installer Shortcut"
        echo -e "${CYAN}0.${NC} Exit"
        echo ""
        read -p "👉 Select option: " opt
        case $opt in
            1) generate_warp_ips ;;
            2) fetch_proxies ;;
            3) create_installer ;;
            4) remove_installer ;;
            0) echo -e "${RED}Bye!${NC}"; exit ;;
            *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
        esac
        echo -e "${CYAN}\n[ Press Enter to return to menu ]${NC}"
        read
    done
}

#========[ INIT ]========#
install_requirements
main_menu
