#!/bin/bash

clear
echo -e "\e[1;35m╔══════════════════════════════════════╗"
echo -e "║     Telegram: @Academi_vpn           ║"
echo -e "║     Admin: Mahdi                     ║"
echo -e "║     WARP Real IP Scanner & Proxy     ║"
echo -e "╚══════════════════════════════════════╝\e[0m"
echo ""
echo -e "\e[1;36m1) WARP Real IP Scanner"
echo -e "2) Telegram Proxy List\e[0m"
echo ""
read -p "Choose an option [1-2]: " choice

if [[ "$choice" == "2" ]]; then
    clear
    echo -e "\e[1;32m===> Telegram Proxies:\e[0m"
    echo ""
    
    proxies=(
    "https://t.me/proxy?server=silvermantain.cinere.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    "https://t.me/proxy?server=halftime.parsintalk.ir&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    "https://t.me/proxy?server=leveldaemi.fiziotr.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    "https://t.me/proxy?server=algortim.sayaair.ir&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
    "https://t.me/proxy?server=daem.fsaremi.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    # (ادامه لیست پروکسی‌ها...)
    )

    for proxy in "${proxies[@]}"; do
        echo -e "\e[1;34m$proxy\e[0m"
    done

    echo ""
    echo -e "\e[1;36mCopy one of the above links and open in Telegram.\e[0m"
    exit 0
fi

# ادامه اسکریپت WARP اسکنر اصلی اینجاست
# ...
