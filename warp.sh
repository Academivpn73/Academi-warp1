#!/bin/bash

# ====[ CONFIG ]====
VERSION="1.6.6"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
INSTALLER_NAME="Academivpn_warp"
INSTALL_PATH="/data/data/com.termux/files/usr/bin/$INSTALLER_NAME"

# ====[ COLORS ]====
RED='\e[31m'; GREEN='\e[32m'; CYAN='\e[36m'; NC='\e[0m'

# ====[ TITLE ]====
show_title() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║           ACADEMI VPN TOOL ${VERSION}                ║"
    echo "╠══════════════════════════════════════════════╣"
    echo -e "║ Telegram: ${CHANNEL}              "
    echo -e "║ Admin:    ${ADMIN}                      "
    echo -e "║ Version:  ${VERSION}                             "
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ====[ DEPENDENCIES ]====
install_requirements() {
    echo -e "${GREEN}Installing dependencies...${NC}"
    pkg update -y >/dev/null 2>&1
    pkg install curl jq -y >/dev/null 2>&1
}

# ====[ INSTALLER SETUP ]====
create_installer() {
    echo -e "${GREEN}Creating installer command: ${INSTALLER_NAME}${NC}"
    cat <<EOF > "$INSTALL_PATH"
#!/bin/bash
bash "$(realpath "$0")"
EOF
    chmod +x "$INSTALL_PATH"
    echo -e "${GREEN}Done. You can now run the script with: ${INSTALLER_NAME}${NC}"
}

remove_installer() {
    if [[ -f "$INSTALL_PATH" ]]; then
        rm "$INSTALL_PATH"
        echo -e "${GREEN}Installer removed successfully.${NC}"
    else
        echo -e "${RED}Installer is not installed.${NC}"
    fi
}

# ====[ WARP SCANNER ]====
generate_ips_ports() {
    for i in {1..10}; do
        IP=$(shuf -n 1 -i 1-255).$(shuf -n 1 -i 1-255).$(shuf -n 1 -i 1-255).$(shuf -n 1 -i 1-255)
        PORT=$(shuf -n 1 -i 1024-65535)
        PING=$(ping -c 1 -W 1 "$IP" 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | awk '{print $1}')
        PING=${PING:-"timeout"}
        echo -e "${CYAN}IP:PORT${NC} ${IP}:${PORT}   ${CYAN}Ping:${NC} ${PING} ms"
    done
}

# ====[ TELEGRAM PROXIES ]====
fetch_proxies() {
    echo -e "${GREEN}🔍 Fetching Telegram proxies...${NC}"

    sources=(
        "https://raw.githubusercontent.com/TheSpeedX/TG-Proxy-List/main/proxies.txt"
        "https://raw.githubusercontent.com/soroushmirzaei/Telegram-Proxies/main/proxies.txt"
        "https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt"
    )

    proxies=()
    for src in "${sources[@]}"; do
        res=$(curl -fsSL "$src" | grep -Eo 'tg://proxy\?server=[^&]+&port=[0-9]+' 2>/dev/null)
        for p in $res; do
            proxies+=("$p")
        done
    done

    if [ ${#proxies[@]} -eq 0 ]; then
        echo -e "${RED}❌ No working proxies found.${NC}"
        return
    fi

    echo -e "${GREEN}✅ Top 10 Telegram Proxies:${NC}"
    for i in "${!proxies[@]}"; do
        echo -e "${CYAN}Proxy $((i+1)):${NC} ${proxies[$i]}"
        [[ $i -ge 9 ]] && break
    done
}

# ====[ MAIN MENU ]====
main_menu() {
    show_title
    echo -e "${CYAN}1.${NC} Warp IP Scanner"
    echo -e "${CYAN}2.${NC} Telegram Proxies"
    echo -e "${CYAN}3.${NC} Install Installer (${INSTALLER_NAME})"
    echo -e "${CYAN}4.${NC} Remove Installer"
    echo -e "${CYAN}5.${NC} Exit"
    echo
    read -rp "Choose an option: " choice

    case "$choice" in
        1) generate_ips_ports ;;
        2) fetch_proxies ;;
        3) create_installer ;;
        4) remove_installer ;;
        5) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac

    echo
    read -rp "Press Enter to return to menu..."
    main_menu
}

# ====[ INIT ]====
install_requirements
main_menu
