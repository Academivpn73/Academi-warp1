#!/bin/bash

clear
echo "╔═════════════════════════════════════╗"
echo "║       WARP Real IP Scanner         ║"
echo "╠═════════════════════════════════════╣"
echo "║      Telegram: @Academi_vpn        ║"
echo "║          Admin: Mahdi              ║"
echo "╚═════════════════════════════════════╝"

echo -e "\nChoose IP type:"
echo "1. IPv4 (with port)"
echo "2. IPv6 (no port)"
read -p "Select [1/2]: " choice

generate_ip() {
  if [[ "$choice" == "1" ]]; then
    ip=$(shuf -i 1-223 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1).$(shuf -i 0-255 -n 1)
    port=$(shuf -i 800-1000 -n 1)
    echo "$ip:$port"
  else
    ip="2606:4700:$((RANDOM)):$((RANDOM)):$((RANDOM)):$((RANDOM)):$((RANDOM)):$((RANDOM))"
    echo "$ip"
  fi
}

for i in {1..10}; do
  data=$(generate_ip)
  ip=$(echo $data | cut -d':' -f1)
  port=$(echo $data | cut -d':' -f2)
  
  if [[ "$choice" == "1" ]]; then
    ping_time=$(ping -c 1 -W 1 $ip | grep time= | awk -F 'time=' '{print $2}' | cut -d ' ' -f1)
    echo "$ip:$port  ${ping_time:-timeout}ms"
  else
    ping_time=$(ping6 -c 1 -W 1 $ip | grep time= | awk -F 'time=' '{print $2}' | cut -d ' ' -f1)
    echo "$ip  ${ping_time:-timeout}ms"
  fi
done
