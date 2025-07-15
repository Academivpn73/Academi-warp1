#!/bin/bash

mkdir -p Academi_Configs

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_menu() {
  echo ""
  echo "========== Academi VPN Tool =========="
  echo "1. Warp IP Scanner"
  echo "2. WireGuard + V2Ray Config Generator"
  echo "0. Exit"
  echo "======================================"
  echo -n "Select an option: "
}

warp_scanner() {
  echo ""
  echo "🔍 Scanning Warp IPs..."
  count=0
  while [ $count -lt 10 ]; do
    ip="162.159.$((RANDOM % 256)).$((RANDOM % 256))"
    for port in 80 443 8080 8443; do
      (echo > /dev/tcp/$ip/$port) >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        ping_result=$(ping -c1 -W1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [ ! -z "$ping_result" ]; then
          echo -e "${GREEN}${ip}:${port}  Ping: ${ping_result}ms${NC}"
          ((count++))
          break
        fi
      fi
    done
  done
}

generate_wg_v2ray_config() {
  echo ""
  echo "🔧 Generating WireGuard + V2Ray Config..."
  
  # Sample WG config template (random IP and keys here for demo)
  private_key=$(wg genkey)
  public_key=$(echo "$private_key" | wg pubkey)
  ip="162.159.$((RANDOM % 256)).$((RANDOM % 256))"
  conf_name="wg_${ip//./_}.conf"
  conf_path="Academi_Configs/$conf_name"

  cat > $conf_path << EOF
[Interface]
PrivateKey = $private_key
Address = 172.16.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $(wg genkey | wg pubkey)
Endpoint = $ip:443
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

  # Mock Country Flag – can be replaced with real API later
  country_flag="🇺🇸"

  # V2Ray JSON Template
  v2ray_json="Academi_Configs/v2ray_${ip//./_}.json"
  cat > $v2ray_json << EOF
{
  "inbounds": [{
    "port": 10808,
    "protocol": "socks",
    "settings": {
      "auth": "noauth",
      "udp": true
    }
  }],
  "outbounds": [{
    "protocol": "wireguard",
    "settings": {
      "secretKey": "$private_key",
      "address": ["172.16.0.2/32"],
      "peers": [{
        "publicKey": "$(wg genkey | wg pubkey)",
        "endpoint": "$ip:443",
        "persistentKeepalive": 25
      }]
    }
  }],
  "tag": "AcademiVPN",
  "remarks": "Telegram:@Academi_vpn $country_flag"
}
EOF

  echo -e "${GREEN}✔ Saved: $conf_path"
  echo -e "✔ Saved: $v2ray_json${NC}"
}

while true; do
  print_menu
  read option
  case $option in
    1) warp_scanner ;;
    2) generate_wg_v2ray_config ;;
    0) echo "Goodbye!"; exit ;;
    *) echo -e "${RED}Invalid option!${NC}" ;;
  esac
done
