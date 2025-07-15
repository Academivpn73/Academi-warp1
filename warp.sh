#!/bin/bash

#──────────────────────────────────────#
#   Academi VPN - WARP Activator       #
#   Telegram: @Academi_vpn / Admin: Mahdi  #
#──────────────────────────────────────#

# رنگ‌ها
GREEN='\e[32m'
BLUE='\e[34m'
RED='\e[31m'
RESET='\e[0m'

clear
echo -e "${GREEN}📡 Academi VPN - Auto WARP Setup (WireGuard)"
echo -e "${BLUE}🔗 Telegram: @Academi_vpn${RESET}\n"

# بررسی دسترسی روت (در termux لازم نیست)
if [[ "$(id -u)" != "0" ]] && [[ "$PREFIX" == "" ]]; then
  echo -e "${RED}❌ Please run as root.${RESET}"
  exit 1
fi

# نصب ابزارهای مورد نیاز
echo -e "${BLUE}[*] Installing dependencies...${RESET}"
pkg update -y && pkg install -y curl wget unzip wireguard-tools resolv-conf

# بررسی معماری دستگاه
ARCH=$(uname -m)
WGCF_URL=""
if [[ $ARCH == "aarch64" ]]; then
  WGCF_URL="https://github.com/ViRb3/wgcf/releases/download/v2.2.20/wgcf_2.2.20_linux_arm64"
elif [[ $ARCH == "armv7l" ]]; then
  WGCF_URL="https://github.com/ViRb3/wgcf/releases/download/v2.2.20/wgcf_2.2.20_linux_arm"
elif [[ $ARCH == "x86_64" ]]; then
  WGCF_URL="https://github.com/ViRb3/wgcf/releases/download/v2.2.20/wgcf_2.2.20_linux_amd64"
else
  echo -e "${RED}❌ Unsupported architecture: $ARCH${RESET}"
  exit 1
fi

# دانلود و نصب wgcf
echo -e "${BLUE}[*] Downloading wgcf binary...${RESET}"
wget -q "$WGCF_URL" -O wgcf && chmod +x wgcf
mv wgcf /data/data/com.termux/files/usr/bin/ 2>/dev/null || mv wgcf /usr/local/bin/

# ثبت حساب Cloudflare
echo -e "${BLUE}[*] Registering WARP account...${RESET}"
wgcf delete >/dev/null 2>&1
wgcf register --accept-tos >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo -e "${RED}❌ Failed to register with Cloudflare.${RESET}"
  exit 1
fi

# ساخت فایل کانفیگ
echo -e "${BLUE}[*] Generating WireGuard config...${RESET}"
wgcf generate >/dev/null 2>&1
mkdir -p ~/academi-warp
mv wgcf-profile.conf ~/academi-warp/wgcf.conf
CONFIG=~/academi-warp/wgcf.conf

# تنظیم DNS
echo -e "nameserver 1.1.1.1" > $PREFIX/etc/resolv.conf

# فعال‌سازی WARP
echo -e "${BLUE}[*] Starting WARP...${RESET}"
wg-quick down wgcf >/dev/null 2>&1
wg-quick up $CONFIG >/dev/null 2>&1

if [[ $? -eq 0 ]]; then
  echo -e "${GREEN}\n✅ WARP is now active!${RESET}"
else
  echo -e "${RED}\n❌ Failed to activate WARP.${RESET}"
  exit 1
fi

# تست نهایی اتصال
echo -e "${BLUE}\n🌐 Checking WARP status...${RESET}"
curl -s https://www.cloudflare.com/cdn-cgi/trace | grep -E 'ip=|warp='

# پایان
echo -e "\n${GREEN}🎉 Done! Your connection is now routed through WARP.${RESET}"
