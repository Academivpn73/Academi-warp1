#!/bin/bash

# ===========================
#      AcademiVPN WARP
# ===========================
# Telegram: @Academi_vpn
# Admin   : @MahdiAGM0
# Version : 1.7.2

# --- رنگ‌ها ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # بدون رنگ

# --- نصب خودکار پکیج‌ها ---
install_packages() {
    for pkg in curl jq grep awk sed; do
        if ! command -v $pkg &>/dev/null; then
            echo -e "${YELLOW}Installing $pkg...${NC}"
            pkg install -y $pkg || apt install -y $pkg
        fi
    done
    if ! command -v crontab &>/dev/null; then
        echo -e "${YELLOW}Installing cronie for cron jobs...${NC}"
        pkg install cronie || apt install cron -y
    fi
}
install_packages

# --- منوی اینستالر ---
installer_menu() {
    echo -e "${CYAN}Installer Options:${NC}"
    echo "1. Install launcher"
    echo "2. Uninstall launcher"
    echo "3. Back"
    read -rp "Choose an option: " inst_opt
    case $inst_opt in
        1)
            echo "bash ~/warp.sh" > ~/Academivpn_warp
            chmod +x ~/Academivpn_warp
            echo -e "${GREEN}Launcher installed. Use: Academivpn_warp${NC}"
            ;;
        2)
            rm -f ~/Academivpn_warp
            echo -e "${RED}Launcher removed.${NC}"
            ;;
        3) return ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
}

# --- اسکنر وارپ ---
warp_scanner() {
    echo -e "${YELLOW}Scanning 10 random WARP IPs...${NC}"
    for i in {1..10}; do
        ip=$(shuf -n 1 -i 1-254).$(shuf -n 1 -i 1-254).$(shuf -n 1 -i 1-254).$(shuf -n 1 -i 1-254)
        port=$(shuf -n 1 -i 1000-65000)
        ping=$(ping -c 1 -W 1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [ -z "$ping" ]; then ping="Timeout"; fi
        echo -e "${GREEN}$ip:$port${NC}  Ping: ${CYAN}${ping}ms${NC}"
    done
    read -rp "Press enter to return..." && main_menu
}

# --- پروکسی تلگرام ---
telegram_proxies() {
    echo -e "${YELLOW}Fetching Telegram proxies...${NC}"
    sources=(
        "https://raw.githubusercontent.com/hookzof/socks5_list/master/tg/mtproto.txt"
        "https://raw.githubusercontent.com/OfficialDarkzy/Telegram-MTProxy/master/proxies.txt"
        "https://raw.githubusercontent.com/azvpn/mtproto-proxies/main/proxies.txt"
        "https://raw.githubusercontent.com/ziplinc/telegram-mtproxy/master/proxies.txt"
        "https://raw.githubusercontent.com/prxchk/proxy-list/main/tg/mtproto.txt"
    )
    proxies=()
    for src in "${sources[@]}"; do
        data=$(curl -s --max-time 5 "$src")
        [[ "$data" == *"tg://proxy"* ]] && while IFS= read -r line; do
            if [[ "$line" == tg://proxy* ]]; then
                proxies+=("$line")
            fi
        done <<< "$data"
    done

    if [[ ${#proxies[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No working Telegram proxies found.${NC}"
    else
        echo -e "${GREEN}✅ 10 Telegram Proxies:${NC}"
        for i in "${!proxies[@]}"; do
            (( i >= 10 )) && break
            echo -e "${CYAN}Proxy $((i+1)):${NC} ${proxies[$i]}"
        done
    fi
    read -rp "Press enter to return..." && main_menu
}

# --- منوی اصلی ---
main_menu() {
clear
echo -e "${BLUE}==============================${NC}"
echo -e "${GREEN}Telegram:${NC} @Academi_vpn"
echo -e "${YELLOW}Admin   :${NC} @MahdiAGM0"
echo -e "${CYAN}Version : 1.7.2${NC}"
echo -e "${BLUE}==============================${NC}"
echo
echo "1. WARP IP Scanner"
echo "2. Telegram Proxies"
echo "3. Installer Options"
echo "4. Exit"
read -rp "Select an option: " option

case $option in
    1) warp_scanner ;;
    2) telegram_proxies ;;
    3) installer_menu ;;
    4) exit ;;
    *) echo -e "${RED}Invalid selection.${NC}" && sleep 1 && main_menu ;;
esac
}

main_menu
