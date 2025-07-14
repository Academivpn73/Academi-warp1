#!/bin/bash

light_green='\033[1;32m'
reset_color='\033[0m'

clear
echo -e "${light_green}"
echo -e "╔═══════════════════════════════════════════════╗"
echo -e "║           Telegram: @Academi_vpn / Admin:Mahdi║"
echo -e "║           WARP IP Scanner + Proxy Tool        ║"
echo -e "╚═══════════════════════════════════════════════╝"
echo -e "${reset_color}"
echo ""
echo -e "${light_green}1) WARP Real IP Scanner${reset_color}"
echo -e "${light_green}2) Telegram Proxy List${reset_color}"
echo ""
read -p "Choose an option [1-2]: " choice

if [[ "$choice" == "2" ]]; then
    clear
    echo -e "${light_green}==> Telegram Proxy List:${reset_color}"
    echo ""

    proxies=(
    "https://t.me/proxy?server=silvermantain.cinere.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    "https://t.me/proxy?server=halftime.parsintalk.ir&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    "https://t.me/proxy?server=leveldaemi.fiziotr.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    # ... (ادامه پروکسی‌ها)
    )

    for proxy in "${proxies[@]}"; do
        echo -e "${light_green}$proxy${reset_color}"
    done
