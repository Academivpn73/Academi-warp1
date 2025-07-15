#!/data/data/com.termux/files/usr/bin/bash

# 🔧 اطلاعات اسکریپت
title="Academi VPN WARP Toolkit"
version="v2.0.0"
admin="@MahdiAGM0"

# 🌐 نصب پیش‌نیازها
install_requirements() {
  echo -e "\n🔧 Installing requirements...\n"
  pkg update -y &>/dev/null
  pkg install -y curl wget grep sed awk coreutils util-linux &>/dev/null
  echo -e "✔️ Requirements installed.\n"
}

# 🚀 نصب اینستالر
install_installer() {
  cat <<EOF > /data/data/com.termux/files/usr/bin/Academivpn_warp
#!/data/data/com.termux/files/usr/bin/bash
bash \$HOME/warp.sh
EOF
  chmod +x /data/data/com.termux/files/usr/bin/Academivpn_warp
  echo -e "\n✅ Installer installed. Run with: Academivpn_warp"
}

# ❌ حذف اینستالر
remove_installer() {
  rm -f /data/data/com.termux/files/usr/bin/Academivpn_warp
  echo -e "\n🗑️ Installer removed."
}

# 🌍 اسکن آی‌پی‌های WARP
warp_scan() {
  echo -e "\n[+] Scanning best WARP IPv4 IPs..."

  base_ip="162.159"
  scanned=0
  found=0

  while [[ $scanned -lt 50 && $found -lt 10 ]]; do
    o3=$((RANDOM % 64 + 192))  # 192-255
    o4=$((RANDOM % 256))       # 0-255
    ip="$base_ip.$o3.$o4"

    for port in 443 80; do
      ping_ms=$(ping -c 1 -W 1 "$ip" 2>/dev/null | grep -oP 'time=\K[0-9.]+')
      if [[ -n "$ping_ms" ]]; then
        echo "[✔] $ip:$port → Ping: ${ping_ms} ms"
        ((found++))
        break
      fi
    done

    ((scanned++))
  done

  [[ $found -eq 0 ]] && echo "[!] No working IPs found."
}

# 🎛️ منوی اصلی
main_menu() {
  clear
  echo -e "┌──────────────────────────────────────────┐"
  echo -e "│   ${title} ${version}"
  echo -e "│   Admin: ${admin}"
  echo -e "└──────────────────────────────────────────┘"

  echo -e "\n1️⃣ نصب اینستالر (Academivpn_warp)"
  echo -e "2️⃣ حذف اینستالر"
  echo -e "3️⃣ اسکن آی‌پی‌های WARP"
  echo -e "0️⃣ خروج"
  echo -ne "\n📥 انتخاب شما: "; read choice

  case "$choice" in
    1) install_installer ;;
    2) remove_installer ;;
    3) warp_scan ;;
    0) exit 0 ;;
    *) echo -e "\n❗ گزینه نامعتبر."; sleep 1 ;;
  esac

  echo -e "\n↩️ بازگشت به منو..."; sleep 2
  main_menu
}

# ▶️ شروع برنامه
install_requirements
main_menu
