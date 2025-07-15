#!/bin/bash

────────────────[ Metadata ]────────────────

VERSION="1.0.0" CHANNEL_ID="@Academi_vpn" ADMIN_ID="@MahdiAGM0"

────────────────[ Colors ]────────────────

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[1;34m' NC='\033[0m'

────────────────[ Install Dependencies ]────────────────

install_deps() { echo -e "${YELLOW}[*] Installing dependencies...${NC}" pkg update -y >/dev/null 2>&1 || apt update -y >/dev/null 2>&1 pkg install -y curl wget jq bash coreutils > /dev/null 2>&1 || apt install -y curl wget jq bash coreutils > /dev/null 2>&1 echo -e "${GREEN}[+] All dependencies installed.${NC}" }

────────────────[ Ping Check ]────────────────

check_ping() { local ip=$1 ping_result=$(ping -c 1 -W 1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}') echo "$ping_result" }

────────────────[ Country IP Ranges (WARP)]────────────────

get_ip_ranges() { case $1 in "Germany") echo "162.159.192.0/24";; "France") echo "162.159.44.0/24";; "Iran") echo "188.114.96.0/24";; "Sweden") echo "172.64.0.0/24";; "USA") echo "104.28.0.0/24";; "UK") echo "198.41.192.0/24";; esac }

────────────────[ Generate Random Ports ]────────────────

random_port() { echo $(( ( RANDOM % 9000 )  + 1000 )) }

────────────────[ WARP IP Scanner ]────────────────

warp_ip_scanner() { echo -e "\n${BLUE}==> Select Country:${NC}" options=("Germany" "France" "Iran" "Sweden" "USA" "UK") select country in "${options[@]}"; do [[ -n "$country" ]] && break done echo -e "\n${YELLOW}Scanning WARP IPs for $country...${NC}" ip_range=$(get_ip_ranges "$country") count=0 for i in $(seq 1 255); do ip=$(echo $ip_range | sed "s|0/24|$i|") port=$(random_port) ping_ms=$(check_ping "$ip") if [[ -n "$ping_ms" ]]; then flag=$(echo "$country" | awk '{ print tolower($0) }') emoji="🇫🇷" case $country in Germany) emoji="🇩🇪";; France) emoji="🇫🇷";; Iran) emoji="🇮🇷";; Sweden) emoji="🇸🇪";; USA) emoji="🇺🇸";; UK) emoji="🇬🇧";; esac echo -e "${GREEN}$ip:$port  | $emoji $country | Ping: ${ping_ms}ms${NC}" ((count++)) fi [[ $count -ge 10 ]] && break done [[ $count -eq 0 ]] && echo -e "${RED}❌ No working IPs found.${NC}" }

────────────────[ Telegram Proxy Scraper ]────────────────

proxy_fetch() { echo -e "${YELLOW}[*] Fetching fresh Telegram proxies...${NC}" proxies=$(curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/tg.txt | head -n 10) if [[ -z "$proxies" ]]; then echo -e "${RED}❌ Failed to fetch proxies.${NC}" else echo -e "${GREEN}[+] Showing 10 Telegram proxies:${NC}\n" echo "$proxies" fi }

────────────────[ Main Menu ]────────────────

main_menu() { clear echo -e "${BLUE}Academi WARP Utility  |  Version: ${VERSION}${NC}" echo -e "${GREEN}Channel: ${CHANNEL_ID}   |   Admin: ${ADMIN_ID}${NC}\n" echo -e "${YELLOW}Choose an option:${NC}" echo "1) 📡 WARP IP Scanner" echo "2) 🔐 Telegram Proxy" echo "3) 🚪 Exit" read -p $'\n>> ' choice case $choice in 1) warp_ip_scanner;; 2) proxy_fetch;; 3) exit;; *) echo "Invalid option"; sleep 1; main_menu;; esac echo -e "\n${BLUE}Returning to menu in 5 seconds...${NC}" sleep 5 main_menu }

────────────────[ Auto Installer Setup ]────────────────

installer_setup() { echo -e "${YELLOW}[*] Creating alias 'Academi_warp'...${NC}" curl -s -o /data/data/com.termux/files/usr/bin/Academi_warp https://raw.githubusercontent.com/Academivpn73/Academi-warp1/main/warp.sh chmod +x /data/data/com.termux/files/usr/bin/Academi_warp echo -e "${GREEN}[+] You can now use 'Academi_warp' anywhere in Termux!${NC}" }

────────────────[ Script Entry Point ]────────────────

install_deps main_menu

