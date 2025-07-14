#!/bin/bash

GREEN="\e[92m"
RESET="\e[0m"

clear
echo -e "$GREEN"
echo "═════════════════════════════════════════════════════════════════"
echo "           Telegram: @Academi_vpn"
echo "           Admin Support: @MahdiAGM0"
echo "           WARP IP SCANNER + Telegram Proxy"
echo "═════════════════════════════════════════════════════════════════"
echo -e "$RESET"

echo -e "$GREEN"
echo "1) WARP IP Scanner"
echo "2) Telegram Proxy List"
read -p "Select an option: " choice
echo -e "$RESET"

# ------------------- [1] WARP SCANNER -------------------
if [[ $choice == "1" ]]; then
    echo -e "$GREEN"
    echo "Choose IP Version:"
    echo "1) IPv4"
    echo "2) IPv6"
    read -p "Select: " ipver
    read -p "How many working IPs to scan? " ip_count
    echo -e "$RESET"

    if [[ $ipver == "1" ]]; then
        ip_range="162.159"
        ports=(443 80 8080 8443)
    elif [[ $ipver == "2" ]]; then
        ipv6_prefixes=(
            "2606:4700:100::"
            "2606:4700:d0::"
            "2606:4700:3000::"
            "2606:4700:4000::"
        )
        ports=(443 80 8080 8443)
    else
        echo "Invalid selection."
        exit 1
    fi

    check_ip() {
        ip=$1
        for port in "${ports[@]}"; do
            timeout 1 bash -c "</dev/tcp/$ip/$port" &>/dev/null
            if [ $? -eq 0 ]; then
                ping_result=$(ping -c1 -W1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
                if [[ ! -z "$ping_result" ]]; then
                    echo -e "$GREEN$ip:$port  ${ping_result}ms$RESET"
                    return 0
                fi
            fi
        done
        return 1
    }

    echo -e "$GREEN\nScanning for WARP IPs... Please wait.\n$RESET"
    found=0
    while [[ $found -lt $ip_count ]]; do
        if [[ $ipver == "1" ]]; then
            ip="$ip_range.$((RANDOM%256)).$((RANDOM%256))"
        else
            prefix=${ipv6_prefixes[$((RANDOM % ${#ipv6_prefixes[@]}))]}
            hex1=$(printf "%x" $((RANDOM%65536)))
            hex2=$(printf "%x" $((RANDOM%65536)))
            ip="${prefix}${hex1}:${hex2}"
        fi

        result=$(check_ip $ip)
        if [[ $? -eq 0 ]]; then
            ((found++))
        fi
    done

    echo -e "\n$GREEN══════════════  Done [$found IPs Found]  ══════════════$RESET"

# ------------------- [2] PROXY LIST -------------------
elif [[ $choice == "2" ]]; then
    echo -e "$GREEN\nAvailable Telegram Proxies:\n$RESET"

    proxies=(
        "silvermantain.cinere.info:443"
        "halftime.parsintalk.ir:443"
        "leveldaemi.fiziotr.info:443"
        "algortim.sayaair.ir:443"
        "daem.fsaremi.info:443"
        "sadra.mygrade.ir:443"
        "iran-vatan.magalaiash.info:443"
        "aval.fsaremi.info:443"
        "wait.fiziotr.info:443"
        "daemi-pr.shesh-station.ir:443"
        "sibilkoloft.technote.ir:443"
        "response.cinere.info:443"
        "systemfull.gjesus.info:443"
        "sebro.sheshko.info:443"
        "syczleck.itemag.ir:443"
        "phyzyk.nokande.info:443"
        "chernobill.technote.ir:443"
        "ryzen-gold.shesh-station.ir:443"
    )

    for proxy in "${proxies[@]}"; do
        echo -e "$GREEN$proxy$RESET"
    done

    echo -e "\nUse these proxies in Telegram settings > Data & Storage > Proxy.\n"

else
    echo "Invalid choice."
    exit 1
fi
