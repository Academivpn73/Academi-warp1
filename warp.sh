#!/bin/bash

clear

# رنگ‌ها
green='\e[92m'
reset='\e[0m'

# هدر
echo -e "${green}"
echo -e "╔═════════════════════════════════════════════════════╗"
echo -e "║          Telegram: @Academi_vpn                    ║"
echo -e "║          Admin Support: @MahdiAGM0                 ║"
echo -e "╚═════════════════════════════════════════════════════╝"
echo -e "${reset}"

# تابع پروکسی
function telegram_proxy() {
    clear
    echo -e "${green}[+] Active Telegram Proxies:${reset}"
    proxies=(
"https://t.me/proxy?server=silvermantain.cinere.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=halftime.parsintalk.ir&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=daem.fsaremi.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=aval.fsaremi.info&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
"https://t.me/proxy?server=wait.fiziotr.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=phyzyk.nokande.info&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
"https://t.me/proxy?server=chernobill.technote.ir&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
    )
    for proxy in "${proxies[@]}"; do
        echo -e "${green}$proxy${reset}"
    done
    echo ""
}

# تابع اسکن IP
function scan_warp_ip() {
    clear
    echo -e "${green}Choose IP version:${reset}"
    echo "1) IPv4"
    echo "2) IPv6"
    read -p "Select (1/2): " ipver

    read -p "Number of IPs to scan: " ipcount
    echo ""

    echo -e "${green}[+] Scanning...${reset}"
    echo ""

    scanned=0
    while [ "$scanned" -lt "$ipcount" ]; do
        if [[ $ipver == "1" ]]; then
            ip="162.159.$((RANDOM % 256)).$((RANDOM % 256))"
        else
            ip="2606:4700:$((RANDOM % 1000))::$(printf '%x' $((RANDOM % 65535)))"
        fi
        port=$((RANDOM % 4000 + 900))
        ping_ms=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)

        if [ ! -z "$ping_ms" ]; then
            echo -e "${green}${ip}:${port}  ${ping_ms}ms${reset}"
            ((scanned++))
        fi
    done
    echo ""
}

# منو اصلی
while true; do
    echo -e "${green}Main Menu:${reset}"
    echo "1) Telegram Proxies"
    echo "2) Warp IP Scanner"
    echo "0) Exit"
    read -p "Select an option: " choice

    case $choice in
        1) telegram_proxy ;;
        2) scan_warp_ip ;;
        0) exit 0 ;;
        *) echo "Invalid option!" ;;
    esac
done
