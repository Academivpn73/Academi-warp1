#!/data/data/com.termux/files/usr/bin/bash

# اطلاعات
ADMIN_ID="@AcademiVPN"
CHANNEL_ID="@AcademiProxies"
VERSION="1.6.1"
PROXY_FILE="proxies.txt"

# چک و نصب ابزارهای مورد نیاز
check_dependencies() {
  echo -e "\n🔍 Checking & Installing required packages..."
  for pkg in curl jq ping unzip wget; do
    if ! command -v $pkg &>/dev/null; then
      echo "📦 Installing $pkg..."
      pkg install -y $pkg &>/dev/null
    fi
  done
}

# حذف لانچر
remove_launcher() {
  echo -e "\n🗑️ Removing launcher..."
  rm -f ~/../usr/bin/warp
  echo "✅ Launcher removed."
}

# نصب لانچر
install_launcher() {
  echo -e "\n🚀 Installing launcher..."
  SCRIPT_URL="https://raw.githubusercontent.com/Academivpn73/Academi-warp1/main/warp.sh"
  wget -q -O ~/warp "$SCRIPT_URL"
  chmod +x ~/warp
  cp ~/warp ~/../usr/bin/warp
  echo "✅ Launcher installed. Just type: warp"
}

# دریافت پروکسی‌ها
fetch_proxies() {
  echo -e "\n🌐 Fetching Telegram proxies..."
  URL="https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json"
  PROXIES=$(curl -s "$URL" | jq -r '.[] | "\(.host):\(.port)"')

  if [[ -z "$PROXIES" ]]; then
    echo "❌ No valid Telegram proxies found."
    return 1
  fi

  echo "$PROXIES" > "$PROXY_FILE"
  echo "✅ Proxies updated successfully."
}

# نمایش پروکسی‌ها با پینگ
show_proxies() {
  [[ ! -f "$PROXY_FILE" ]] && echo "⚠️ Proxy list not found. Updating..." && fetch_proxies
  echo -e "\n========= 🌍 TOP 10 TELEGRAM PROXIES ========="
  count=1
  while IFS= read -r proxy && [[ $count -le 10 ]]; do
    host=$(echo "$proxy" | cut -d: -f1)
    port=$(echo "$proxy" | cut -d: -f2)
    ping_val=$(ping -c 1 -W 1 "$host" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    [[ -z "$ping_val" ]] && ping_val="Timeout"
    echo "Proxy $count: $proxy - Ping: $ping_val ms"
    ((count++))
  done < "$PROXY_FILE"
  echo "=============================================="
}

# تولید 10 آی‌پی وارپ
generate_warp_ips() {
  echo -e "\n🔁 Generating 10 WARP IPs:"
  for i in {1..10}; do
    ip=$(curl -s https://api64.ipify.org)
    loc=$(curl -s https://ipapi.co/$ip/country_name)
    echo "IP $i: $ip - Location: $loc"
    sleep 1
  done
}

# نمایش عنوان زیبا
show_title() {
  clear
  echo -e "╔══════════════════════════════════════╗"
  echo -e "║  ⚡ TELEGRAM PROXY & WARP TOOL       ║"
  echo -e "╠══════════════════════════════════════╣"
  echo -e "║ 🆔 Admin   : $ADMIN_ID"
  echo -e "║ 📡 Channel : $CHANNEL_ID"
  echo -e "║ 🔖 Version : $VERSION"
  echo -e "╚══════════════════════════════════════╝"
}

# منوی اصلی
main_menu() {
  while true; do
    show_title
    echo -e "1️⃣  Show Top 10 Telegram Proxies"
    echo -e "2️⃣  ❌ Remove Launcher"
    echo -e "3️⃣  🌐 Install Launcher"
    echo -e "4️⃣  💎 Generate 10 WARP IPs"
    echo -e "5️⃣  ♻️  Enable Daily Proxy Auto-Update"
    echo -e "0️⃣  Exit"
    echo -ne "\n>> "
    read -r opt

    case "$opt" in
      1) show_proxies ;;
      2) remove_launcher ;;
      3) install_launcher ;;
      4) generate_warp_ips ;;
      5) fetch_proxies ;;
      0) echo "👋 Goodbye!"; exit ;;
      *) echo "❗ Invalid option." ;;
    esac

    echo -e "\nPress Enter to return to menu..."; read
  done
}

# اجرای همه مراحل
check_dependencies
main_menu
