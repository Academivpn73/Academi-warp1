#!/bin/bash

clear
echo "========================================"
echo "     WARP Tools by @Academi_vpn"
echo "========================================"
echo "[1] WARP Best IP Scanner"
echo "[2] Generate WireGuard Config"
echo "========================================"
read -p "Select an option [1-2]: " opt

# بررسی پیش‌نیازها
function check_requirements() {
  for pkg in curl jq ping wgcf; do
    if ! command -v $pkg &>/dev/null; then
      echo "[*] Installing $pkg..."
      pkg install $pkg -y >/dev/null 2>&1 || apt install $pkg -y >/dev/null 2>&1
    fi
  done
}

# گزینه 1: اسکن آی‌پی‌های وارپ
function scan_ips() {
  echo -e "\n🔍 Scanning WARP IPs (max 10)...\n"
  ips=(
    162.159.192.1 162.159.193.1 188.114.96.3 188.114.97.3
    162.159.195.1 162.159.223.1 162.159.192.3 162.159.193.3
    162.159.195.3 188.114.96.1 188.114.97.1 162.159.49.100
  )

  count=0
  for ip in "${ips[@]}"; do
    ping_ms=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d ' ' -f1)
    nc -z -w1 $ip 443 &>/dev/null
    if [[ $? -eq 0 && -n "$ping_ms" ]]; then
      echo "$ip:443  Ping: ${ping_ms}ms"
      ((count++))
    fi
    [[ $count -ge 10 ]] && break
  done

  [[ $count -eq 0 ]] && echo "❌ No working IPs found."
}

# گزینه 2: ساخت کانفیگ وایرگارد واقعی
function generate_wireguard_config() {
  echo -e "\n🔧 Creating WireGuard Config via WARP..."

  rm -f wgcf-account.toml wgcf-profile.conf

  wgcf register --accept-tos >/dev/null 2>&1
  wgcf generate >/dev/null 2>&1

  wg-quick up wgcf-profile.conf >/dev/null 2>&1

  IP=$(curl -s --max-time 5 ifconfig.me)
  PING=$(ping -c 1 1.1.1.1 | grep 'time=' | cut -d '=' -f 4 | cut -d ' ' -f 1)

  wg-quick down wgcf-profile.conf >/dev/null 2>&1

  if [[ -n "$IP" ]]; then
    echo ""
    echo "✅ WireGuard Config (WARP) - Ready to Use"
    echo "=============================================="
    echo "[🇺🇸] Telegram:@Academi_vpn"
    echo "IP: $IP     Ping: ${PING}ms"
    echo "=============================================="
    echo ""
    sed "s/engage.cloudflareclient.com/$IP/" wgcf-profile.conf
  else
    echo "❌ Could not retrieve WARP IP."
  fi
}

# اجرای بخش انتخابی
check_requirements

case $opt in
  1) scan_ips ;;
  2) generate_wireguard_config ;;
  *) echo "Invalid option!" ;;
esac
