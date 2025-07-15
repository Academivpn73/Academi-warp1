#!/bin/bash

CONFIG_DIR="Academi_Configs"
mkdir -p "$CONFIG_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Cloudflare Warp public key
WARP_PUBLIC_KEY="ziJrVCgPNg9g9bCIs7paGVaI3azH/Nz6DCQE/3nXyU8="

# Ports to test
PORTS=(80 443 8080 8443 2052 2082 2086 2095 8880)

function main_menu() {
  clear
  echo -e "${YELLOW}Academi VPN - Warp Toolkit${NC}"
  echo "1) WARP IP Scanner"
  echo "2) WireGuard + V2Ray Config Generator"
  echo "0) Exit"
  echo -n "Choose an option: "
  read choice

  case "$choice" in
    1) warp_ip_scanner ;;
    2) wireguard_v2ray_config ;;
    0) exit ;;
    *) echo "Invalid choice."; sleep 1; main_menu ;;
  esac
}

function get_ping() {
  ip=$1
  ping -c 1 -W 1 "$ip" | grep 'time=' | sed -E 's/.*time=([0-9.]+) ms/\1/'
}

function get_country_flag() {
  ip=$1
  code=$(curl -sL "https://ipinfo.io/$ip/country")
  if [[ ${#code} -eq 2 ]]; then
    for ((i=0; i<${#code}; i++)); do
      flag+=$(echo ${code:$i:1} | tr 'A-Z' '\U1F1E6-\U1F1FF')
    done
    echo "$flag"
  else
    echo "🏳️"
  fi
}

function is_port_open() {
  ip=$1
  port=$2
  timeout 1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null && echo "open" || echo "closed"
}

function generate_wg_config() {
  ip=$1
  port=$2
  private_key=$(wg genkey)
  public_key=$(echo "$private_key" | wg pubkey)
  endpoint="$ip:$port"
  country_flag=$(get_country_flag "$ip")

  config_file="$CONFIG_DIR/wg_${ip//./_}.conf"

  cat > "$config_file" <<EOF
# Telegram:@Academi_vpn $country_flag
[Interface]
PrivateKey = $private_key
Address = 172.16.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $WARP_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = $endpoint
PersistentKeepalive = 25
EOF

  echo -e "${GREEN}✔ Saved: $config_file${NC}"
}

function warp_ip_scanner() {
  echo -e "\n${YELLOW}Starting WARP IP scan for 10 IPs...${NC}"
  count=0

  while [[ $count -lt 10 ]]; do
    ip="162.159.$((RANDOM % 255)).$((RANDOM % 255))"
    ping_time=$(get_ping "$ip")

    if [[ -n "$ping_time" ]]; then
      for port in "${PORTS[@]}"; do
        status=$(is_port_open "$ip" "$port")
        if [[ "$status" == "open" ]]; then
          echo -e "$ip:$port  Ping: ${GREEN}${ping_time}ms${NC}"
          generate_wg_config "$ip" "$port"
          ((count++))
          break
        fi
      done
    fi
  done

  echo -e "${YELLOW}Scan complete. 10 IPs processed.${NC}"
  read -p "Press Enter to return to main menu..." temp
  main_menu
}

function wireguard_v2ray_config() {
  echo -e "\n${YELLOW}WireGuard + V2Ray Config Generator${NC}"
  read -p "How many configs do you want? (1 or 2): " howmany

  for ((i = 1; i <= howmany; i++)); do
    echo -e "\nConfig #$i"
    read -p "Enter endpoint IP:Port (e.g. 1.1.1.1:443): " endpoint
    read -p "Enter Country Code (e.g. US): " cc

    private_key=$(wg genkey)
    public_key=$(echo "$private_key" | wg pubkey)
    flag=$(echo "$cc" | tr 'A-Z' '🇦🇦')
    config_file="$CONFIG_DIR/v2ray_wg_${cc}_$i.conf"

    cat > "$config_file" <<EOF
# Telegram:@Academi_vpn $flag
[Interface]
PrivateKey = $private_key
Address = 172.16.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $WARP_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = $endpoint
PersistentKeepalive = 25
EOF

    echo -e "${GREEN}✔ WireGuard config $i saved: $config_file${NC}"
  done

  echo -e "${YELLOW}Done generating $howmany config(s).${NC}"
  read -p "Press Enter to return to main menu..." temp
  main_menu
}

main_menu
