#!/bin/bash

light_green='\033[1;32m'
reset_color='\033[0m'

clear
echo -e "${light_green}"
echo -e "╔═══════════════════════════════════════════════╗"
echo -e "║           Telegram: @Academi_vpn              ║"
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

    echo ""
    echo -e "${light_green}Copy a link and open it in Telegram.${reset_color}"
    exit 0
fi

# ───────────────────────────────
# بخش انتخاب نوع IP (IPv4 یا IPv6)
# ───────────────────────────────
clear
echo -e "${light_green}Choose IP type to scan:${reset_color}"
echo -e "${light_green}1) IPv4${reset_color}"
echo -e "${light_green}2) IPv6${reset_color}"
read -p "Enter choice [1-2]: " iptype

# لیست IP و PORT
if [[ "$iptype" == "1" ]]; then
    echo -e "${light_green}Scanning IPv4 ...${reset_color}"
    ip_list=(
    "162.159.192.222:443"
    "188.114.97.2:2086"
    "104.16.0.1:8443"
    "104.18.5.6:2087"
    "162.159.193.123:80"
    "188.114.96.7:443"
    "104.18.10.2:2053"
    "104.19.25.3:2096"
    "104.26.3.2:2083"
    "104.21.50.1:2052"
    )
elif [[ "$iptype" == "2" ]]; then
    echo -e "${light_green}Scanning IPv6 ...${reset_color}"
    ip_list=(
    "[2606:4700:4700::1111]:443"
    "[2606:4700:4700::1001]:443"
    "[2001:4860:4860::8888]:443"
    "[2001:4860:4860::8844]:443"
    "[2a00:1450:4001:801::200e]:443"
    "[2606:4700::6810:1215]:443"
    "[2606:4700::6810:1115]:443"
    "[2400:cb00:2049:1::a29f:8c]:443"
    "[2606:4700:3034::ac43:d879]:443"
    "[2a00:1450:4001:824::200e]:443"
    )
else
    echo -e "Invalid choice."
    exit 1
fi

# ───────────────────────────────
# اسکن 10 IP فعال با پینگ
# ───────────────────────────────

found=0
for ip_port in "${ip_list[@]}"; do
    ip=$(echo "$ip_port" | cut -d: -f1 | sed 's/\[//;s/\]//')
    port=$(echo "$ip_port" | cut -d: -f2)

    # انتخاب نوع پینگ
    if [[ "$iptype" == "1" ]]; then
        ping_time=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    else
        ping_time=$(ping6 -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    fi

    if [[ -n "$ping_time" ]]; then
        echo -e "${light_green}${ip}:${port}  ${ping_time}ms${reset_color}"
        ((found++))
    fi

    # فقط 10 آی‌پی موفق نشون بده
    if [[ "$found" -ge 10 ]]; then
        break
    fi
done

if [[ "$found" -eq 0 ]]; then
    echo -e "${light_green}No working IPs found.${reset_color}"
fi
