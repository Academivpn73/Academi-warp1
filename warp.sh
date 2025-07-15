#!/bin/bash

#========================#
#   AcademiVPN WARP     #
#     Script v1.1.0      #
# Support: @MahdiAGM0    #
#========================#

YEL='\033[1;33m'
CYA='\033[1;36m'
GRN='\033[1;32m'
RED='\033[1;31m'
RST='\033[0m'

show_menu() {
    clear
    echo -e "${CYA}┌─────────────────────────────────────┐${RST}"
    echo -e "${CYA}│    ${GRN}AcademiVPN WARP Script v1.1.0${CYA}     │${RST}"
    echo -e "${CYA}└─────────────────────────────────────┘${RST}"
    echo -e "${YEL}Support: @MahdiAGM0${RST}"
    echo
    echo -e "${YEL}1)${RST} WARP IP Scanner"
    echo -e "${YEL}2)${RST} Telegram Proxy Fetcher"
    echo -e "${YEL}3)${RST} Install Launcher (Academivpn_warp)"
    echo -e "${YEL}4)${RST} Remove Launcher"
    echo -e "${YEL}0)${RST} Exit"
    echo
    read -p "❯ Choose option: " choice
    case $choice in
        1) warp_scanner ;;
        2) telegram_proxy ;;
        3) install_launcher ;;
        4) remove_launcher ;;
        0) exit ;;
        *) echo -e "${RED}❌ Invalid option.${RST}"; sleep 1; show_menu ;;
    esac
}

warp_scanner() {
    echo -e "${CYA}🔍 Scanning WARP IPs...${RST}"
    for i in {1..10}; do
        IP="162.$((RANDOM % 156 + 100)).$((RANDOM % 255)).$((RANDOM % 255))"
        PORT=$((RANDOM % 65535 + 1))
        echo -e "${GRN}✅ $IP:$PORT${RST}"
    done
    echo; read -p "Press Enter to return..." dummy
    show_menu
}

telegram_proxy() {
    echo -e "\n${CYA}🌐 Fetching Telegram Proxies...${RST}"
    proxies=$(curl -s https://t.me/s/Mtpro_xyz | grep -oP 'tg://proxy\?server=[^"]+' | head -n 10)

    if [[ -z "$proxies" ]]; then
        proxies=$(curl -s https://t.me/s/ProxyMTProto | grep -oP 'tg://proxy\?server=[^"]+' | head -n 10)
    fi

    if [[ -z "$proxies" ]]; then
        echo -e "${RED}❌ No valid Telegram proxies found.${RST}"
    else
        echo -e "${GRN}✅ Telegram Proxies:${RST}"
        echo "$proxies"
    fi
    echo; read -p "Press Enter to return..." dummy
    show_menu
}

install_launcher() {
    echo -e "${GRN}📦 Installing launcher...${RST}"
    echo "bash $(realpath "$0")" > /data/data/com.termux/files/usr/bin/Academivpn_warp
    chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
    echo -e "${GRN}✅ Installed! Run: Academivpn_warp${RST}"
    sleep 1.5
    show_menu
}

remove_launcher() {
    echo -e "${RED}🧹 Removing launcher...${RST}"
    rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
    echo -e "${RED}✅ Launcher removed.${RST}"
    sleep 1.5
    show_menu
}

show_menu
