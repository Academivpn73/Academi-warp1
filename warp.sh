#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Show Title
show_title() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e "        ${YELLOW}AcademiVPN MultiTool Script${NC}"
    echo -e "  ${GREEN}Telegram:${NC} @Academi_vpn   ${GREEN}Admin:${NC} @MahdiAGM0"
    echo -e "                ${CYAN}Version: 1.6.9.2${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# Install Dependencies
install_dependencies() {
    pkgs=(curl jq ping grep cron)
    for pkg in "${pkgs[@]}"; do
        command -v $pkg >/dev/null 2>&1 || sudo apt install -y $pkg >/dev/null 2>&1
    done
}

# Warp Scanner
scan_warp() {
    echo -e "${CYAN}🔍 Scanning WARP IPs...${NC}"
    for i in {1..10}; do
        ip="104.$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
        port=$((10000 + RANDOM % 50000))
        ping_result=$(ping -c1 -W1 "$ip" | grep "time=" | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [[ -n "$ping_result" ]]; then
            echo -e "${GREEN}IP:$ip:$port  Ping:${ping_result}ms${NC}"
        else
            echo -e "${RED}IP:$ip:$port  Ping: Timeout${NC}"
        fi
    done
}

# Fetch Telegram Proxies
fetch_proxies() {
    echo -e "${CYAN}🔄 Fetching Telegram proxies...${NC}"
    proxies=$(curl -s https://raw.githubusercontent.com/TheSpeedX/TGramProxy/main/proxy.json | jq -r '.[] | "\(.ip):\(.port)"' | head -n 10)
    if [[ -z "$proxies" ]]; then
        echo -e "${RED}❌ No working Telegram proxies found.${NC}"
        return
    fi

    i=1
    > /etc/academivpn_proxies.txt
    while read -r proxy; do
        ip=$(echo "$proxy" | cut -d: -f1)
        port=$(echo "$proxy" | cut -d: -f2)
        tg_link="tg://proxy?server=$ip&port=$port&secret=ee00000000000000000000000000000000000000000000000000000000000000"
        echo "Proxy $i: $tg_link" | tee -a /etc/academivpn_proxies.txt
        ((i++))
    done <<< "$proxies"
}

# Setup Cron Job for Daily Proxy Update
setup_cron_job() {
    cron_path="/usr/local/bin/update_proxies_academi.sh"
    echo "#!/bin/bash" > "$cron_path"
    echo "$(declare -f fetch_proxies)" >> "$cron_path"
    echo "fetch_proxies" >> "$cron_path"
    chmod +x "$cron_path"
    (crontab -l 2>/dev/null; echo "0 7 * * * bash $cron_path >/dev/null 2>&1") | crontab -
}

# Install launcher
install_launcher() {
    echo -e "${CYAN}⚙️ Installing launcher...${NC}"
    echo "#!/bin/bash
bash $(realpath "$0")" | sudo tee /usr/bin/Academivpn_warp >/dev/null
    sudo chmod +x /usr/bin/Academivpn_warp
    echo -e "${GREEN}✅ Launcher installed. Use: ${YELLOW}Academivpn_warp${NC}"
}

# Remove launcher
remove_launcher() {
    sudo rm -f /usr/bin/Academivpn_warp
    echo -e "${RED}❌ Launcher removed.${NC}"
}

# Installer Menu
installer_menu() {
    echo -e "\n${YELLOW}🔧 Installer Options:${NC}"
    echo "1) Install launcher"
    echo "2) Remove launcher"
    echo "0) Back to Main Menu"
    read -rp "Choose: " opt
    case $opt in
        1) install_launcher ;;
        2) remove_launcher ;;
        0) main_menu ;;
        *) echo -e "${RED}Invalid option!";;
    esac
    read -rp "Press Enter to return..."
    main_menu
}

# Main Menu
main_menu() {
    show_title
    echo -e "${YELLOW}1) WARP IP Scanner"
    echo "2) Telegram Proxy"
    echo "3) Installer Options"
    echo "0) Exit${NC}"
    echo
    read -rp "Select option: " choice
    case $choice in
        1) scan_warp ;;
        2) fetch_proxies ;;
        3) installer_menu ;;
        0) echo -e "${GREEN}👋 Exiting..."; exit ;;
        *) echo -e "${RED}❌ Invalid selection!${NC}";;
    esac
    echo
    read -rp "Press Enter to return..."
    main_menu
}

# Execution
install_dependencies
setup_cron_job
main_menu
