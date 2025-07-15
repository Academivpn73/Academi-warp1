#!/bin/bash

# رنگ‌ها
GREEN='\033[0;32m'
NC='\033[0m' # بدون رنگ

echo -e "${GREEN}Telegram:@Academi_vpn${NC}"
echo -e "اسکن IP های سالم و تولید کانفیگ WireGuard..."

# مسیر ذخیره کانفیگ‌ها
CONFIG_DIR="Academi_Configs"
mkdir -p "$CONFIG_DIR"

# تعداد آی‌پی مورد نظر برای تست
COUNT=20

# پورت‌هایی که می‌خوای تست کنی
PORTS=(80 443 8080 8443 2052 2082 2086 2095 8880)

# تابع برای دریافت پینگ از آی‌پی
function get_ping() {
    ip=$1
    ping -c 1 -W 1 "$ip" | grep 'time=' | sed -E 's/.*time=([0-9.]+) ms/\1/'
}

# تابع برای گرفتن کشور با IP
function get_country_flag() {
    ip=$1
    country_code=$(curl -sL "https://ipinfo.io/$ip/country")
    flag=$(echo "$country_code" | tr 'A-Z' '🇦🇦')
    echo "$flag"
}

# تابع تست پورت باز
function is_port_open() {
    ip=$1
    port=$2
    timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null && echo "open" || echo "closed"
}

# تابع ساخت کانفیگ وایرگارد
function generate_wg_config() {
    ip=$1
    port=$2
    private_key=$(wg genkey)
    public_key=$(echo "$private_key" | wg pubkey)
    endpoint="$ip:$port"
    config_file="$CONFIG_DIR/wg_$ip.conf"
    country_flag=$(get_country_flag "$ip")

    cat > "$config_file" <<EOF
# Telegram:@Academi_vpn $country_flag
[Interface]
PrivateKey = $private_key
Address = 172.16.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $(curl -sL https://raw.githubusercontent.com/mishakorzik/WARP-WireGuard/main/warp.pub)
AllowedIPs = 0.0.0.0/0
Endpoint = $endpoint
PersistentKeepalive = 25
EOF
    echo -e "${GREEN}✔ کانفیگ ساخته شد: $config_file${NC}"
}

# تولید IP‌های تصادفی (بهینه‌تر: محدوده Cloudflare)
for ((i = 0; i < COUNT; i++)); do
    ip="162.159.$((RANDOM % 255)).$((RANDOM % 255))"
    ping_time=$(get_ping "$ip")

    if [[ -n "$ping_time" ]]; then
        for port in "${PORTS[@]}"; do
            status=$(is_port_open "$ip" "$port")
            if [[ "$status" == "open" ]]; then
                echo -e "$ip:$port  ${GREEN}Ping:${ping_time}ms${NC}"
                generate_wg_config "$ip" "$port"
                break
            fi
        done
    fi
done

echo -e "${GREEN}تمام شد! کانفیگ‌ها در پوشه $CONFIG_DIR ذخیره شدند.${NC}"
