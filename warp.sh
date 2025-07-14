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
echo -e "${GREEN}[2] IPv6${NC}"
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

# Function to generate WARP IP
generate_warp_ip() {
  if [[ "$version" == "IPv4" ]]; then
    echo "$(shuf -i 1-223 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1)"
  else
    printf "2606:4700:%x:%x:%x:%x:%x:%x\n" $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM))
  fi
}

# Function to test WARP IP
test_ip() {
  IP=$1
  if [[ "$version" == "IPv4" ]]; then
    RESULT=$(timeout 3 curl -4 --connect-to ::$IP --max-time 4 -s https://www.cloudflare.com/cdn-cgi/trace)
  else
    RESULT=$(timeout 3 curl -6 --connect-to ::$IP --max-time 4 -s https://www.cloudflare.com/cdn-cgi/trace)
  fi

  if [[ $RESULT == *"warp=on"* ]]; then
    echo -e "${GREEN}[+] WARP IP Found: $IP${NC}"
    echo -e "${CYAN}    Status: Active with ${port_status}${NC}"
    echo "$RESULT" | while read line; do
      if [[ $line == ip=* || $line == loc=* || $line == colo=* ]]; then
        echo -e "    ${CYAN}${line}${NC}"
      fi
    done
  else
    echo -e "${YELLOW}[-] Not a WARP IP: $IP${NC}"
  fi
}

# Scan 10 IPs
for i in {1..10}; do
  IP=$(generate_warp_ip)
  test_ip $IP
done

echo -e "\n${GREEN}✔ Scan complete.${NC}"#!/bin/bash

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
echo -e "${GREEN}[2] IPv6${NC}"
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

# Function to generate WARP IP
generate_warp_ip() {
  if [[ "$version" == "IPv4" ]]; then
    echo "$(shuf -i 1-223 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1)"
  else
    printf "2606:4700:%x:%x:%x:%x:%x:%x\n" $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM))
  fi
}

# Function to test WARP IP
test_ip() {
  IP=$1
  if [[ "$version" == "IPv4" ]]; then
    RESULT=$(timeout 3 curl -4 --connect-to ::$IP --max-time 4 -s https://www.cloudflare.com/cdn-cgi/trace)
  else
    RESULT=$(timeout 3 curl -6 --connect-to ::$IP --max-time 4 -s https://www.cloudflare.com/cdn-cgi/trace)
  fi

  if [[ $RESULT == *"warp=on"* ]]; then
    echo -e "${GREEN}[+] WARP IP Found: $IP${NC}"
    echo -e "${CYAN}    Status: Active with ${port_status}${NC}"
    echo "$RESULT" | while read line; do
      if [[ $line == ip=* || $line == loc=* || $line == colo=* ]]; then
        echo -e "    ${CYAN}${line}${NC}"
      fi
    done
  else
    echo -e "${YELLOW}[-] Not a WARP IP: $IP${NC}"
  fi
}

# Scan 10 IPs
for i in {1..10}; do
  IP=$(generate_warp_ip)
  test_ip $IP
done

echo -e "\n${GREEN}✔ Scan complete.${NC}"
