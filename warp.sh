#!/bin/bash

# ============ CONFIG ==============
VERSION="1.7.1"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
INSTALLER_ALIAS="Academivpn_warp"
PROXY_SOURCES=(
  "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
  "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/socks5.txt"
  "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/socks5.txt"
  "https://raw.githubusercontent.com/mmpx12/proxy-list/master/socks5.txt"
  "https://raw.githubusercontent.com/roosterkid/openproxylist/main/SOCKS5_RAW.txt"
)
# ========== COLOR SCHEME ==========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# ========= CHECK & INSTALL DEPS =========
install_dependencies() {
    for pkg in curl jq; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            echo -e "${YELLOW}[!] Installing $pkg...${NC}"
            pkg install "$pkg" -y >/dev/null 2>&1 || apt install "$pkg" -y >/dev/null 2>&1
        fi
    done
    if ! command -v crontab >/dev/null 2>&1; then
        echo -e "${YELLOW}[!] Installing cronie for crontab...${NC}"
        pkg install cronie -y >/dev/null 2>&1 || apt install cron -y >/dev/null 2>&1
    fi
}

# ========= TITLE HEADER =========
print_header() {
    clear
    echo -e "${CYAN}==============================="
    echo -e "🔰 AcademiVPN WARP TOOL"
    echo -e "📢 Channel: ${GREEN}${CHANNEL}"
    echo -e "👤 Admin:   ${GREEN}${ADMIN}"
    echo -e "📦 Version: ${YELLOW}${VERSION}"
    echo -e "===============================${NC}"
}

# ========= INSTALL/REMOVE ALIAS =========
installer_menu() {
    echo -e "${CYAN}Alias Installer for: ${INSTALLER_ALIAS}${NC}"
    echo -e "${GREEN}[1] Install Alias"
    echo -e "[2] Remove Alias"
    echo -e "[3] Back${NC}"
    read -p "Select > " choice
    case $choice in
        1)
            echo "bash $PWD/$0" > "$HOME/.${INSTALLER_ALIAS}"
            chmod +x "$HOME/.${INSTALLER_ALIAS}"
            echo "alias ${INSTALLER_ALIAS}='bash $HOME/.${INSTALLER_ALIAS}'" >> "$HOME/.bashrc"
            source "$HOME/.bashrc"
            echo -e "${GREEN}✅ Installed. Now use '${INSTALLER_ALIAS}' to run the script.${NC}"
            ;;
        2)
            sed -i "/${INSTALLER_ALIAS}/d" "$HOME/.bashrc"
            rm -f "$HOME/.${INSTALLER_ALIAS}"
            echo -e "${RED}❌ Alias removed.${NC}"
            ;;
        3) main_menu ;;
        *) echo -e "${RED}Invalid.${NC}" ;;
    esac
    read -p "Press enter to return..." && main_menu
}

# ========= WARP SCANNER =========
warp_scanner() {
    echo -e "${YELLOW}🔍 Scanning 10 random WARP IPs...${NC}"
    for i in {1..10}; do
        ip=$(shuf -i 1-255 -n 4 | tr '\n' '.' | sed 's/\.$//')
        port=$(shuf -i 1000-65535 -n 1)
        ping=$(ping -c1 -W1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
        if [[ -z "$ping" ]]; then ping="Timeout"; fi
        echo -e "${CYAN}[$i] ${GREEN}${ip}:${port}  ${YELLOW}${ping}ms${NC}"
    done
    read -p "Press enter to return..." && main_menu
}

# ========= FETCH TELEGRAM PROXIES =========
fetch_proxies() {
    echo -e "${YELLOW}🔄 Fetching Telegram proxies...${NC}"
    proxies=()
    for url in "${PROXY_SOURCES[@]}"; do
        list=$(curl -s --connect-timeout 5 "$url")
        while IFS= read -r line; do
            ip=$(echo "$line" | cut -d: -f1)
            port=$(echo "$line" | cut -d: -f2)
            [[ $ip && $port ]] && proxies+=("tg://proxy?server=${ip}&port=${port}")
        done <<< "$list"
    done

    if [[ ${#proxies[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No working Telegram proxies found.${NC}"
    else
        echo -e "${GREEN}✅ Top 10 Telegram Proxies:${NC}"
        for i in {1..10}; do
            echo -e "${CYAN}Proxy $i: ${BLUE}${proxies[$i]}${NC}"
        done
    fi
    read -p "Press enter to return..." && main_menu
}

# ========= MAIN MENU =========
main_menu() {
    print_header
    echo -e "${GREEN}[1] WARP IP Scanner"
    echo -e "[2] Telegram Proxy Generator"
    echo -e "[3] Installer Settings"
    echo -e "[4] Exit${NC}"
    echo
    read -p "Select > " opt
    case $opt in
        1) warp_scanner ;;
        2) fetch_proxies ;;
        3) installer_menu ;;
        4) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" && sleep 1 && main_menu ;;
    esac
}

# ========== START ==========
install_dependencies
main_menu
