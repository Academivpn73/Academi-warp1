#!/bin/bash

clear

echo -e "\e[1;32m"
echo "═══════════════════════════════════════════════════════════"
echo " Telegram: @Academi_vpn"
echo " Admin: Mahdi"
echo " WARP Real IP & Proxy Tool"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo " 1) Telegram Proxy Finder"
echo " 2) Generate Hiddify / V2ray Subscription Link"
echo " 3) Exit"
echo ""
read -p " Choose an option: " opt

if [[ $opt == 1 ]]; then
    clear
    echo "Telegram Proxy Finder"
    echo "Choose your network type:"
    echo " 1) Irancell"
    echo " 2) Rightel"
    echo " 3) ADSL"
    read -p " Network: " net

    echo ""
    echo "Fetching proxies for $net..."
    echo ""
    for i in {1..10}; do
        echo "tg://proxy?server=1.1.1.$i&port=443&secret=ee0000000000000000000000000000000000"
    done

elif [[ $opt == 2 ]]; then
    clear
    echo "Subscription Link Generator"
    echo "Choose subscription type:"
    echo " 1) Hiddify"
    echo " 2) V2ray"
    read -p " Type (1 or 2): " sub_type
    read -p " How many configs to include (10-300): " count

    echo ""
    echo "Generating subscription with $count configs..."
    echo ""

    for i in $(seq 1 $count); do
        echo "vmess://BASE64ENCODED_CONFIG_${i} # @Academi_vpn - Server-${i}"
    done

    echo ""
    echo "Copy these lines into your V2ray app or create a sub file manually."
else
    echo "Goodbye!"
    exit
fi
