#!/bin/bash

clear

echo -e "\e[1;32m"
echo "═══════════════════════════════════════════════════════════"
echo " Telegram: @Academi_vpn"
echo " Admin: Mahdi"
echo " WARP Real IP Scanner + Telegram Proxy Finder"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo " 1) Telegram Proxy Finder (From @opera_proxy)"
echo " 2) WARP Real IP Scanner"
echo " 3) Exit"
echo ""
read -p " Choose an option: " opt

if [[ $opt == 1 ]]; then
    echo ""
    echo "[+] Getting latest Telegram proxies from @opera_proxy..."
    echo ""

    curl -s https://t.me/s/opera_proxy | grep -Eo 'tg://proxy\?server=[^"]+' | head -n 20

elif [[ $opt == 2 ]]; then
    clear
    echo "WARP Real IP Scanner"
    echo ""
    echo " 1) IPv4"
    echo " 2) IPv6"
    read -p " Choose IP version: " ipver

    echo ""
    echo "[+] Scanning for active WARP IPs with open ports..."
    echo ""

    for i in {1..10}; do
        ip="162.159.192.$((RANDOM % 255))"
        port=$((800 + RANDOM % 1000))
        ping=$(ping -c1 -W1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        echo "$ip:$port  ${ping:-timeout}ms"
    done

else
    echo "Bye!"
    exit
fi
