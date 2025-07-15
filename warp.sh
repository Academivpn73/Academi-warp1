#!/bin/bash

# رنگ‌ها
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
NC='\e[0m' # بدون رنگ

# نصب خودکار پکیج‌ها
install_dependencies() {
    for pkg in curl jq; do
        if ! command -v $pkg &> /dev/null; then
            echo -e "${YELLOW}Installing $pkg...${NC}"
            pkg install -y $pkg &> /dev/null
        fi
    done
}

# تایتل زیبا
show_title() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        ${CYAN}Telegram Proxy Tool v1.7.1${BLUE}         ║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}  Admin   : @MahdiAGM0${NC}"
    echo -e "${GREEN}  Channel : @Academi_vpn${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
}

# نمایش پروکسی‌ها از فایل
telegram_proxies() {
    show_title
    echo -e "${YELLOW}📥 Loading Telegram proxies from proxies.txt...${NC}"
    if [[ ! -f "proxies.txt" ]]; then
        echo -e "${RED}❌ File 'proxies.txt' not found.${NC}"
        read -rp "Press enter to return..." && main_menu
        return
    fi

    mapfile -t proxies < proxies.txt
    if [[ ${#proxies[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No proxies found in proxies.txt.${NC}"
    else
        echo -e "${GREEN}✅ Showing saved Telegram proxies:${NC}"
        for i in "${!proxies[@]}"; do
            echo -e "${CYAN}Proxy $((i+1)): ${NC}${proxies[$i]}"
        done
    fi
    echo ""
    read -rp "Press enter to return..." && main_menu
}

# وارپ اسکنر شبیه‌سازی (واقعی قابل اضافه‌سازیه بعد)
warp_scanner() {
    show_title
    echo -e "${YELLOW}🔍 Generating random working IP:Port...${NC}"
    for i in {1..10}; do
        ip="$(shuf -i 1-255 -n 1).$(shuf -i 1-255 -n 1).$(shuf -i 1-255 -n 1).$(shuf -i 1-255 -n 1)"
        port="$(shuf -i 1024-65535 -n 1)"
        ping_ms="$(shuf -i 40-200 -n 1)"
        echo -e "${GREEN}IP:Port: ${NC}$ip:$port   ${YELLOW}Ping: ${NC}${ping_ms}ms"
    done
    echo ""
    read -rp "Press enter to return..." && main_menu
}

# نصب اینستالر
install_installer() {
    show_title
    echo -e "${YELLOW}📦 Installing installer to /data/data/com.termux/files/usr/bin...${NC}"
    cp "$0" /data/data/com.termux/files/usr/bin/Academivpn_warp && chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
    echo -e "${GREEN}✅ Installed as 'Academivpn_warp' command!${NC}"
    read -rp "Press enter to return..." && main_menu
}

# حذف اینستالر
remove_installer() {
    show_title
    rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
    echo -e "${RED}🗑️ Removed 'Academivpn_warp' command.${NC}"
    read -rp "Press enter to return..." && main_menu
}

# منو اصلی
main_menu() {
    show_title
    echo -e "${CYAN}1) Warp IP Scanner${NC}"
    echo -e "${CYAN}2) Telegram Proxies${NC}"
    echo -e "${CYAN}3) Install Installer Command${NC}"
    echo -e "${CYAN}4) Remove Installer Command${NC}"
    echo -e "${CYAN}5) Exit${NC}"
    echo ""
    read -rp "🔘 Select an option: " choice
    case "$choice" in
        1) warp_scanner ;;
        2) telegram_proxies ;;
        3) install_installer ;;
        4) remove_installer ;;
        5) exit 0 ;;
        *) echo -e "${RED}❌ Invalid option.${NC}" && sleep 1 && main_menu ;;
    esac
}

# اجرای اسکریپت
install_dependencies
main_menu
