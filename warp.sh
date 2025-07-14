#!/bin/bash

light_green='\033[1;32m'
reset_color='\033[0m'

clear
echo -e "${light_green}"
echo -e "╔═══════════════════════════════════════════════╗"
echo -e "║           Telegram: @Academi_vpn              ║"
echo -e "║           Admin: Mahdi                        ║"
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
    "https://t.me/proxy?server=algortim.sayaair.ir&port=443&secret=ee1603010200010001fc030386e24c3add6d656469612e737465616d706f77657265642e636f6d"
    "https://t.me/proxy?server=daem.fsaremi.info&port=443&secret=7hYDAQIAAQAB_AMDhuJMOt1tZWRpYS5zdGVhbXBvd2VyZWQuY29t"
    # بقیه پروکسی‌هایی که دادی رو هم همینجا اضافه کن
    )

    for proxy in "${proxies[@]}"; do
        echo -e "${light_green}$proxy${reset_color}"
    done

    echo ""
    echo -e "${light_green}Copy a link and open it in Telegram.${reset_color}"
    exit 0
fi

# ───────────────────────────────
# بخش اسکنر WARP
# ───────────────────────────────

clear
echo -e "${light_green}[+] Starting WARP IP Scanner...${reset_color}"
echo ""

# لیست چندین IP و پورت برای اسکن
ips=(
"162.159.192.222:443"
"162.159.193.123:80"
"188.114.96.7:443"
"188.114.97.2:2086"
"104.16.0.1:8443"
"104.18.5.6:2087"
)

# تابع اسکنر ساده با پینگ و خروجی
for ip in "${ips[@]}"; do
    ip_only=$(echo "$ip" | cut -d: -f1)
    port_only=$(echo "$ip" | cut -d: -f2)
    ping=$(ping -c 1 -W 1 $ip_only | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    
    if [[ -n "$ping" ]]; then
        echo -e "${light_green}$ip  ${ping}ms${reset_color}"
    else
        echo -e "${light_green}$ip  timeout${reset_color}"
    fi
done

echo ""
echo -e "${light_green}Scan completed.${reset_color}"
