#!/bin/bash

# Academi WARP Scanner v1.0.3
# Channel: @Academi_vpn | Support: @MahdiAGM0

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# لیست رنج آی‌پی Cloudflare WARP (IPv4)
RANGES=(
  "162.159.192.0/24"
  "162.159.193.0/24"
  "162.159.195.0/24"
  "188.114.96.0/24"
  "188.114.97.0/24"
  "188.114.98.0/24"
  "188.114.99.0/24"
)

# بررسی و نصب ابزارهای لازم
install_requirements() {
  echo -e "${YELLOW}Checking and installing required tools...${NC}"
  for pkg in curl timeout ping shuf; do
    if ! command -v $pkg >/dev/null 2>&1; then
      echo -e "${RED}Installing $pkg...${NC}"
      apt update >/dev/null && apt install -y $pkg >/dev/null
    fi
  done
}

# تابع تست اتصال
test_ip() {
  ip=$1
  for port in $(seq 1 65535); do
    timeout 1 bash -c "</dev/tcp/$ip/$port" 2>/dev/null
    if [ $? -eq 0 ]; then
      ping_ms=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
      if [ -n "$ping_ms" ]; then
        echo -e "${GREEN}${ip}:${port}${NC}  Ping: ${ping_ms}ms"
        echo "${ip}:${port}  Ping: ${ping_ms}ms" >> results.txt
        return 0
      fi
    fi
  done
  return 1
}

# تابع ساخت لیست IP از رنج
generate_ips() {
  range=$1
  IFS=/ read ip prefix <<< "$range"
  base=$(echo $ip | awk -F. '{print $1"."$2"."$3}')
  for i in {1..254}; do
    echo "$base.$i"
  done | shuf -n 30  # حداکثر 30 تا از هر رنج
}

# اجرای کلی اسکنر
run_scanner() {
  echo -e "${YELLOW}🔍 Scanning best WARP IPv4 IPs... (This may take time)${NC}"
  > results.txt
  count=0

  for range in "${RANGES[@]}"; do
    ips=$(generate_ips "$range")
    for ip in $ips; do
      test_ip "$ip" &
      sleep 0.2
      ((count++))
      if [ $(wc -l < results.txt) -ge 10 ]; then
        break 2
      fi
    done
  done

  echo -e "\n${GREEN}✔ Done. Working IPs:${NC}"
  cat results.txt | head -n 10
  rm results.txt
}

clear
echo -e "${YELLOW}╔═══════════════════════════════════════╗"
echo -e "║   WARP IPv4 Scanner - Version 1.0.3   ║"
echo -e "║   Channel: @Academi_vpn               ║"
echo -e "║   Support: @MahdiAGM0                 ║"
echo -e "╚═══════════════════════════════════════╝${NC}\n"

install_requirements
run_scanner
