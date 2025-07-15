#!/bin/bash

# Academi VPN WARP Scanner v1.0.0
# Telegram Channel: @Academi_vpn
# Support: @MahdiAGM0

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"

echo -e "${CYAN}=============================="
echo -e "${YELLOW} Academi VPN WARP SCANNER v1.0.0"
echo -e "${CYAN}=============================="
echo -e "${GREEN}Channel: @Academi_vpn | Support: @MahdiAGM0${NC}"
echo ""

# نصب ابزارهای لازم
install_dependencies() {
    if ! command -v curl >/dev/null; then
        apt-get update -y && apt-get install curl -y
    fi
    if ! command -v ping >/dev/null; then
        apt-get install iputils-ping -y
    fi
    if ! command -v wg >/dev/null; then
        apt-get install wireguard-tools -y
    fi
    if ! command -v warp-cli >/dev/null; then
        curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ focal main" | tee /etc/apt/sources.list.d/cloudflare-client.list
        apt-get update && apt-get install cloudflare-warp -y
    fi
}

# فعال‌سازی WARP
activate_warp() {
    warp-cli --accept-tos register
    warp-cli --accept-tos set-mode warp
    warp-cli --accept-tos connect
    sleep 5
}

# تابع برای بررسی IP سالم
check_ip() {
    ip=$1
    port=$2
    ping_time=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ -n "$ping_time" ]]; then
        echo -e "${GREEN}${ip}:${port}  Ping: ${ping_time}ms${NC}"
    fi
}

# تولید IP تصادفی
random_ip() {
    echo "162.$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256))"
}

# اسکن WARP IPv4
scan_warp_ipv4() {
    echo -e "${CYAN}Scanning WARP IPv4 Servers...${NC}"
    count=0
    while [[ $count -lt 10 ]]; do
        ip=$(random_ip)
        port_list=(80 443 8080 8443 2082 2053 2086 2096 8880 2052)
        for port in "${port_list[@]}"; do
            check=$(timeout 1 bash -c "</dev/tcp/$ip/$port" 2>/dev/null && echo "open")
            if [[ "$check" == "open" ]]; then
                check_ip "$ip" "$port"
                ((count++))
                break
            fi
        done
        sleep 0.5
    done
}

# شروع اجرای اسکریپت
install_dependencies
activate_warp
scan_warp_ipv4
