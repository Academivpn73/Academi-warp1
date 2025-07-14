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
echo "║      Made for Termux - by You      ║"
echo "╚═════════════════════════════════════╝"
echo -e "${NC}"

# Check dependencies
for cmd in curl jq timeout; do
  if ! command -v $cmd &>/dev/null; then
    echo -e "${YELLOW}Installing missing dependency: $cmd${NC}"
    pkg install $cmd -y >/dev/null
  fi
done

# Function to generate WARP IP
generate_warp_ip() {
  IP_VERSION=$1
  if [[ "$IP_VERSION" == "4" ]]; then
    echo "$(shuf -i 1-223 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1)"
  else
    printf "2606:4700:%x:%x:%x:%x:%x:%x\n" $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM))
  fi
}

# Function to test IP
test_ip() {
  IP=$1
  IP_VERSION=$2

  if [[ "$IP_VERSION" == "4" ]]; then
    RESULT=$(timeout 3 curl -4 --connect-to ::$IP --max-time 4 -s https://www.cloudflare.com/cdn-cgi/trace)
  else
    RESULT=$(timeout 3 curl -6 --connect-to ::$IP --max-time 4 -s https://www.cloudflare.com/cdn-cgi/trace)
  fi

  if [[ $RESULT == *"warp=on"* ]]; then
    echo -e "${GREEN}[+] WARP IP Found: $IP${NC}"
    echo "$RESULT" | while read line; do
      if [[ $line == ip=* || $line == loc=* || $line == colo=* ]]; then
        echo -e "    ${CYAN}${line}${NC}"
      fi
    done
  else
    echo -e "${YELLOW}[-] Not a WARP IP: $IP${NC}"
  fi
}

# Scan IPs
for version in 4 6; do
  echo -e "\n${CYAN}>> Scanning IPv${version} WARP addresses...${NC}"
  for i in {1..10}; do
    IP=$(generate_warp_ip $version)
    test_ip $IP $version
  done
done

echo -e "\n${GREEN}✔ Scan complete.${NC}"
