#!/bin/bash

# ─────────────────────────────
# AcademiVPN v1.7.2 by @MahdiAGM0
# ─────────────────────────────

# ░█▀▀░█▀▀░█▀▀░█▀▀░█░░░█▀▀░█▀▄░
# ░▀▀█░█▀▀░▀▀█░█░█░█░░░█▀▀░█▀▄░
# ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░

# Colors
BLUE="\e[34m"
GREEN="\e[32m"
PURPLE="\e[35m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

# Title
clear
echo -e "${CYAN}┌─────────────────────────────────────────────┐"
echo -e "${CYAN}│${BLUE}  Telegram: @Academi_vpn ${CYAN}"
echo -e "${CYAN}│${GREEN}  Admin: @MahdiAGM0         ${CYAN}"
echo -e "${CYAN}│${PURPLE}  Version: 1.7.2            ${CYAN}"
echo -e "${CYAN}└─────────────────────────────────────────────┘${NC}"
echo ""

# نصب خودکار ابزارهای مورد نیاز
install_requirements() {
    for pkg in curl jq ping awk; do
        if ! command -v $pkg >/dev/null 2>&1; then
            echo -e "${YELLOW}🔧 Installing $pkg...${NC}"
            pkg install -y $pkg > /dev/null 2>&1
        fi
    done
}

# اینستالر
installer_menu() {
    echo -e "${CYAN}🛠 Installer Options:${NC}"
    echo -e "1) Install warp.sh"
    echo -e "2) Remove warp.sh"
    echo -e "3) Back"
    read -p "Select: " opt
    case $opt in
        1)
            curl -o ~/warp.sh https://raw.githubusercontent.com/MahdiAGM0/AcademiVPN/main/warp.sh
            chmod +x ~/warp.sh
            echo -e "${GREEN}✅ Installed as ~/warp.sh${NC}"
            ;;
        2)
            rm -f ~/warp.sh
            echo -e "${RED}❌ Removed ~/warp.sh${NC}"
            ;;
        *)
            ;;
    esac
}

# اسکنر WARP
warp_scanner() {
    echo -e "${BLUE}🔍 Scanning IPs...${NC}"
    for i in {1..10}; do
        IP=$(shuf -i 1-255 -n 4 | paste -sd '.')
        PORT=$((RANDOM % 65535 + 1))
        PING=$(ping -c 1 -W 1 "$IP" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        [[ -n "$PING" ]] && echo -e "IP: ${CYAN}$IP:$PORT${NC}  Ping: ${GREEN}${PING}ms${NC}"
    done
}

# نمایش پروکسی‌های دستی
telegram_proxies() {
    echo -e "${BLUE}🔐 Telegram Proxies:${NC}"
    proxies=(
"https://t.me/proxy?server=ir.suggested.run.&port=8888&secret=eeNEgY..."
"https://t.me/proxy?server=iran.filters.yoga.&port=8888&secret=eeNEgY..."
"https://t.me/proxy?server=128.140.13.248&port=443&secret=3QAAAAAAAA..."
"https://t.me/proxy?server=62.60.176.141&port=443&secret=eed77db4..."
"https://t.me/proxy?server=91.99.235.43&port=8888&secret=7gAA8A8Pd..."
"https://t.me/proxy?server=basic.homayoon12.ir&port=443&secret=7gAA..."
"https://t.me/proxy?server=Focos-mokos.berlino-landcvixo.yokohama..."
"https://t.me/proxy?server=World-press.Online-shop.speeker-voice...."
"https://t.me/proxy?server=87.248.132.37&port=70&secret=eed77db43..."
"https://t.me/proxy?server=146.103.103.127&port=443&secret=eeNEgYd..."
    )
    i=1
    for proxy in "${proxies[@]}"; do
        echo -e "${YELLOW}Proxy $i:${NC}"
        echo -e "$proxy"
        ((i++))
    done
}

# منوی اصلی
main_menu() {
    while true; do
        echo -e "${CYAN}\n📋 Menu:${NC}"
        echo -e "1) WARP IP Scanner"
        echo -e "2) Telegram Proxies"
        echo -e "3) Installer"
        echo -e "4) Exit"
        read -p "Choose an option: " menu
        case $menu in
            1) warp_scanner ;;
            2) telegram_proxies ;;
            3) installer_menu ;;
            4) echo -e "${RED}👋 Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Invalid option!${NC}" ;;
        esac
    done
}

# اجرای برنامه
install_requirements
main_menu
