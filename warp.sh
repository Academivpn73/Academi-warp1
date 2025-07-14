#!/bin/bash

green='\e[92m'
reset='\e[0m'

clear
echo -e "${green}"
echo -e "╔══════════════════════════════════════════════════╗"
echo -e "║              Telegram: @Academi_vpn             ║"
echo -e "║            Admin Support: @MahdiAGM0            ║"
echo -e "╚══════════════════════════════════════════════════╝"
echo -e "${reset}"

echo -e "${green}1) Warp IP Scanner"
echo "2) Telegram Proxy"
echo -e "${reset}"
read -p "Choose an option (1 or 2): " option

if [[ $option == "1" ]]; then
    echo -e "${green}IPv4 or IPv6?${reset}"
    echo "1) IPv4"
    echo "2) IPv6"
    read -p "Select: " ipver
    read -p "How many IPs to scan? " count

    iplist=()
    if [[ $ipver == "1" ]]; then
        base="162.159"
        for ((i=0; i<$count; i++)); do
            ip="$base.$((RANDOM % 255)).$((RANDOM % 255))"
            port=$((800 + RANDOM % 200))  # پورت بین 800 تا 1000
            ping_result=$(ping -c1 -W1 $ip | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
            if [[ -n $ping_result ]]; then
                echo -e "${green}${ip}:$port  ${ping_result}ms${reset}"
            fi
        done
    else
        for ((i=0; i<$count; i++)); do
            segment1=$(printf "%x" $((RANDOM%65536)))
            segment2=$(printf "%x" $((RANDOM%65536)))
            ip="2606:4700:$segment1::$segment2"
            port=$((800 + RANDOM % 200))
            ping6_result=$(ping6 -c1 -W1 $ip | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
            if [[ -n $ping6_result ]]; then
                echo -e "${green}${ip}:$port  ${ping6_result}ms${reset}"
            fi
        done
    fi

elif [[ $option == "2" ]]; then
    echo -e "${green}Fetching Telegram Proxies...${reset}"
    proxies=(
"https://t.me/proxy?server=silvermantain.cinere.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=halftime.parsintalk.ir&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=leveldaemi.fiziotr.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=algortim.sayaair.ir&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
"https://t.me/proxy?server=daem.fsaremi.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=sadra.mygrade.ir&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=aval.fsaremi.info&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
"https://t.me/proxy?server=wait.fiziotr.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
"https://t.me/proxy?server=daemi-pr.shesh-station.ir&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
"https://t.me/proxy?server=sibilkoloft.technote.ir&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
)

    for p in "${proxies[@]}"; do
        echo -e "${green}$p${reset}"
    done

else
    echo -e "${green}Invalid option selected.${reset}"
fi
