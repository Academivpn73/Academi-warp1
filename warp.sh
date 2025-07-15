#!/bin/bash

#==========[ INFO HEADER ]==========
TITLE="Academi VPN Panel"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
VERSION="1.6.7"
INSTALLER_NAME="Academivpn_warp"

#==========[ AUTO DEPENDENCIES INSTALL ]==========
install_dependencies() {
    echo -e "\n📦 Installing required packages..."
    for pkg in curl jq grep ping; do
        command -v $pkg >/dev/null 2>&1 || pkg install -y $pkg
    done
}

#==========[ INSTALLER ]==========
install_installer() {
    echo "#!/data/data/com.termux/files/usr/bin/bash
bash ~/warp.sh" > /data/data/com.termux/files/usr/bin/$INSTALLER_NAME
    chmod +x /data/data/com.termux/files/usr/bin/$INSTALLER_NAME
    echo -e "✅ Installer created. Run with: \033[1;32m$INSTALLER_NAME\033[0m"
}

remove_installer() {
    rm -f /data/data/com.termux/files/usr/bin/$INSTALLER_NAME
    echo "❌ Installer removed."
}

#==========[ HEADER DISPLAY ]==========
show_header() {
    clear
    echo -e "\e[1;34m╔══════════════════════════════════╗"
    echo -e "║   🌐 $TITLE"
    echo -e "║   👤 Admin: $ADMIN"
    echo -e "║   📢 Channel: $CHANNEL"
    echo -e "║   🛠️ Version: $VERSION"
    echo -e "╚══════════════════════════════════╝\e[0m"
}

#==========[ WARP SCANNER ]==========
warp_scanner() {
    echo -e "\n🔍 Scanning 10 random WARP IPs..."
    for i in {1..10}; do
        ip=$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1)
        port=$(shuf -i 1000-65535 -n1)
        ping_result=$(ping -c 1 -W 1 "$ip" 2>/dev/null | grep 'time=' | cut -d'=' -f4 | cut -d' ' -f1)
        if [[ -n "$ping_result" ]]; then
            echo -e "IP:$ip:$port  ➤  Ping: ${ping_result}ms"
        else
            echo -e "IP:$ip:$port  ➤  Ping: Timeout"
        fi
    done
}

#==========[ TELEGRAM PROXY FETCHER ]==========
fetch_telegram_proxies() {
    echo -e "\n🌐 Fetching fresh Telegram proxies..."

    SOURCES=(
      "https://raw.githubusercontent.com/roosterkid/openproxylist/main/Telegram.txt"
      "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/socks5.txt"
      "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
      "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/socks5.txt"
    )

    PROXIES=()
    for url in "${SOURCES[@]}"; do
        TMP=$(curl -s --max-time 5 "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+' | head -n 30)
        while read -r proxy; do
            [[ ! -z "$proxy" ]] && PROXIES+=("$proxy")
        done <<< "$TMP"
    done

    VALID=()
    for proxy in "${PROXIES[@]}"; do
        if timeout 2 curl -s -x socks5://$proxy https://core.telegram.org >/dev/null 2>&1; then
            VALID+=("$proxy")
        fi
        [[ ${#VALID[@]} -ge 10 ]] && break
    done

    if [ ${#VALID[@]} -eq 0 ]; then
        echo "❌ No working Telegram proxies found."
    else
        echo -e "\n✅ Top 10 Telegram Proxies:"
        count=1
        for proxy in "${VALID[@]}"; do
            echo "Proxy $count: $proxy"
            ((count++))
        done
    fi
}

#==========[ DAILY PROXY UPDATE VIA CRON ]==========
setup_daily_proxy_update() {
    cronjob="0 9 * * * bash ~/warp.sh --auto-proxy"
    crontab -l | grep -q 'warp.sh --auto-proxy' || (crontab -l 2>/dev/null; echo "$cronjob") | crontab -
}

#==========[ ARG HANDLER FOR AUTO PROXY ]==========
if [[ "$1" == "--auto-proxy" ]]; then
    fetch_telegram_proxies
    exit
fi

#==========[ MAIN MENU ]==========
main_menu() {
    while true; do
        show_header
        echo -e "\nChoose an option:"
        echo -e "1️⃣  WARP IP Scanner"
        echo -e "2️⃣  Telegram Proxies"
        echo -e "3️⃣  Install $INSTALLER_NAME"
        echo -e "4️⃣  Remove $INSTALLER_NAME"
        echo -e "5️⃣  Exit"

        read -p $'\nEnter choice [1-5]: ' choice

        case $choice in
            1) warp_scanner ;;
            2) fetch_telegram_proxies ;;
            3) install_installer ;;
            4) remove_installer ;;
            5) echo "👋 Exiting..."; exit 0 ;;
            *) echo "❌ Invalid choice." ;;
        esac
        read -p $'\nPress Enter to return to menu...'
    done
}

#==========[ INIT ]==========
install_dependencies
setup_daily_proxy_update
main_menu
