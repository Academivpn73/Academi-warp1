#!/data/data/com.termux/files/usr/bin/bash

# ─── Info ────────────────────────────────
VERSION="1.1.0"
SUPPORT="@MahdiAGM0"
CMD_NAME="Academivpn_warp"
BIN_PATH="/data/data/com.termux/files/usr/bin/$CMD_NAME"

# ─── Color ───────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
CYA='\033[0;36m'
RST='\033[0m'

# ─── Install Requirements ────────────────
install_requirements() {
    echo -e "${CYA}Installing required packages...${RST}"
    pkg update -y > /dev/null 2>&1
    pkg install -y curl jq unzip inetutils-ping > /dev/null 2>&1
    chmod +x $0
}

# ─── WARP IP Scanner ─────────────────────
warp_ip_scanner() {
    echo -e "\n${YEL}🔍 Scanning WARP IPs (Random)...${RST}"
    for i in {1..10}; do
        ip="162.$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
        port=$((RANDOM % 65535 + 1))
        ping_result=$(ping -c 1 -W 1 "$ip" | grep "time=" | cut -d'=' -f4 | cut -d' ' -f1)
        if [ -n "$ping_result" ]; then
            echo -e "${GRN}[+] $ip:$port - ping ${ping_result}ms${RST}"
        else
            echo -e "${RED}[-] $ip:$port - unreachable${RST}"
        fi
    done
}

# ─── Telegram Proxy Fetcher ──────────────
telegram_proxy() {
    echo -e "\n${CYA}🌐 Fetching Telegram Proxies...${RST}"
    proxies=$(curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt | grep -Eo 'tg://proxy\?server=[^&]+' | sort -u | head -n 10)
    if [[ -z "$proxies" ]]; then
        echo -e "${RED}❌ No proxies found.${RST}"
    else
        echo -e "${GRN}✅ Proxies:${RST}"
        echo "$proxies"
    fi
}

# ─── Installer Setup ─────────────────────
install_launcher() {
    echo -e "${CYA}📌 Installing launcher command...${RST}"
    echo "#!/data/data/com.termux/files/usr/bin/bash" > $BIN_PATH
    echo "bash ~/warp.sh" >> $BIN_PATH
    chmod +x $BIN_PATH
    echo -e "${GRN}✅ Installed. Run with: ${CMD_NAME}${RST}"
}

remove_launcher() {
    rm -f "$BIN_PATH"
    echo -e "${YEL}🗑️ Launcher removed.${RST}"
}

# ─── Main Menu ───────────────────────────
main_menu() {
    clear
    echo -e "${CYA}┌────────────────────────────────────┐"
    echo -e "│   AcademiVPN WARP Script v$VERSION   │"
    echo -e "└────────────────────────────────────┘${RST}"
    echo -e "${YEL}Support:${RST} ${SUPPORT}"
    echo
    echo -e "${YEL}1) WARP IP Scanner"
    echo "2) Telegram Proxy Fetcher"
    echo "3) Install Launcher (${CMD_NAME})"
    echo "4) Remove Launcher"
    echo "0) Exit${RST}"
    echo
    read -p "➤ Choose option: " opt
    case $opt in
        1) warp_ip_scanner ;;
        2) telegram_proxy ;;
        3) install_launcher ;;
        4) remove_launcher ;;
        0) exit ;;
        *) echo -e "${RED}❌ Invalid Option${RST}" ;;
    esac
    echo
    read -p "Press Enter to return..."
    main_menu
}

# ─── Start ───────────────────────────────
install_requirements
main_menu
