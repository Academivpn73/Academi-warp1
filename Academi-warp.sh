#!/bin/bash
# Telegram: @Academi_vpn
# Admin: @MahdiAGM0
# Project: Academi_vpn WARP Installer (based on fscarmen/warp menu.sh)

start=$(date +%s)

# تابع‌های رنگ
red(){ echo -e "\033[31m\033[01m$1\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1\033[0m"; }

# بررسی root
[[ $(id -u) != 0 ]] && red "اسکریپت باید با root اجرا شود." && exit 1

green "شروع نصب WARP با برند Academi_vpn..."

# چک curl و نصب در صورت نبودن
if ! command -v curl >/dev/null 2>&1; then
  yellow "در حال نصب curl..."
  if command -v apt >/dev/null 2>&1; then apt update -y && apt install curl -y
  elif command -v yum >/dev/null 2>&1; then yum install curl -y
  fi
fi

# دانلود نسخه اصلی منو و اجرای آن
bash <(curl -fsSL https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)

# اگر مایل باشی می‌تونی تمام گزینه‌های منو (install, wg4, wg6, d, a, i, e, b, uninstall و...) رو توسط نام برندت **Academi_vpn** توی منو یا متن‌ها تغییر بدی

end=$(date +%s)
duration=$((end - start))

green "نصب برای برند Academi_vpn با موفقیت انجام شد! زمان صرف‌شده: ${duration} ثانیه."
green "برای پشتیبانی: @Academi_vpn یا ادمین: @MahdiAGM0"
