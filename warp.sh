#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}"
echo "╔═════════════════════════════════════╗"
echo "║       WARP Real IP Scanner         ║"
echo "╠═════════════════════════════════════╣"
echo "║        Telegram: @Academi_vpn      ║"
echo "╠═════════════════════════════════════╣"
echo "║          Admin: Mahdi              ║"
echo "╚═════════════════════════════════════╝"
echo -e "${NC}"

# Ask for IP version
echo -e "${YELLOW}Choose the IP version you want to use:${NC}"
echo -e "${GREEN}[1] IPv4 (Ports enabled)${NC}"
echo -e "${GREEN}[2] IPv6 (No ports)${NC}"
read -p "➤ Enter 1 for IPv4 or 2 for IPv6: " iptype

if [[ "$iptype" == "1" ]]; then
    version="IPv4"
    port_status="Ports enabled"
elif [[ "$iptype" == "2" ]]; then
    version="IPv6"
    port_status="No ports"
else
    echo -e "${RED}Invalid selection! Exiting...${NC}"
    exit 1
fi

echo -e "\n${CYAN}>> Scanning $version WARP IP addresses...${NC}"

# Function to generate WARP IP with port
generate_warp_ip() {
  if [[ "$version" == "IPv4" ]]; then
    ip=$(shuf -i 1-223 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1)
    port=$(shuf -i 1024-65535 -n 1)  # Random port for IPv4
    echo "$ip:$port"
  else
    ip="2606:4700:$((RANDOM)):$((RANDOM)):$((RANDOM)):$((RANDOM)):$((RANDOM)):$((RANDOM))"
    port="No port"
    echo "$ip:$port"
  fi
}

# Function to test WARP IP with port
test_ip() {
  IP=$1
  PORT=$2

  echo "Testing IP: $IP with port: $PORT"

  if [[ "$PORT" != "No port" ]]; then
    # Test the IP with a port
    timeout 5 bash -c "</dev/tcp/$IP/$PORT" 2>/dev/null && echo -e "${GREEN}[+] WARP IP Found with port: $IP:$PORT${NC}" || echo -e "${YELLOW}[-] Port is not open for: $IP:$PORT${NC}"
    ping_time=$(ping -c 1 $IP | grep time= | awk -F 'time=' '{print $2}' | cut -d ' ' -f1)
    echo "$IP:$PORT  $ping_time ms"
  else
    echo -e "${YELLOW}[-] IPv6 does not have ports${NC}"
    ping_time=$(ping -c 1 $IP | grep time= | awk -F 'time=' '{print $2}' | cut -d ' ' -f1)
    echo "$IP  $ping_time ms"
  fi
}

# Scan 10 IPs with ports
for i in {1..10}; do
  result=$(generate_warp_ip)
  IP=$(echo $result | cut -d':' -f1)
  PORT=$(echo $result | cut -d':' -f2)

  test_ip $IP $PORT
done

echo -e "\n${GREEN}✔ Scan complete.${NC}"
