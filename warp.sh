#!/bin/bash

# رنگ‌ها
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m' # بدون رنگ

# مسیر فایل پروکسی
PROXY_FILE="$(dirname "$0")/proxies.txt"

# تابع نمایش عنوان
show_title() {
    echo -e "${BLUE}Telegram: @Academi_vpn"
    echo -e "${GREEN}Admin: @MahdiAGM0"
    echo -e "${YELLOW}Version: 1.7.2${NC}"
    echo "--------------------------------------"
}

# تابع نمایش منو
show_menu() {
    echo -e "${CYAN}1) نمایش 10 پراکسی تلگرام"
    echo -e "2) نصب یا حذف اینستالر"
    echo -e "3) خروج${NC}"
    echo
}

# تابع نمایش پروکسی‌ها
show_proxies() {
    echo -e "${YELLOW}🔗 پروکسی‌های فعال: ${NC}"
    if [[ -f "$PROXY_FILE" ]]; then
        i=1
        grep -E "^https:\/\/t.me\/proxy\?" "$PROXY_FILE" | while read -r proxy; do
            echo -e "${CYAN}Proxy $i:${NC} $proxy"
            ((i++))
        done
    else
        echo -e "${RED}❌ فایل پروکسی پیدا نشد.${NC}"
    fi
}

# تابع نصب یا حذف اینستالر
installer_menu() {
    echo -e "${GREEN}🛠 نصب یا حذف اینستالر${NC}"
    echo "1) نصب"
    echo "2) حذف"
    read -p "گزینه مورد نظر را انتخاب کنید: " inst
    if [[ "$inst" == "1" ]]; then
        cp "$(realpath "$0")" /data/data/com.termux/files/home/warp.sh
        chmod +x /data/data/com.termux/files/home/warp.sh
        echo -e "${GREEN}✅ نصب شد.${NC}"
    elif [[ "$inst" == "2" ]]; then
        rm -f /data/data/com.termux/files/home/warp.sh
        echo -e "${RED}❌ حذف شد.${NC}"
    else
        echo -e "${YELLOW}دستور نامعتبر.${NC}"
    fi
}

# شروع اسکریپت
clear
show_title
show_menu

read -p "انتخاب کن: " opt

case $opt in
    1)
        show_proxies
        ;;
    2)
        installer_menu
        ;;
    3)
        echo -e "${CYAN}Bye 👋${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ گزینه نامعتبر${NC}"
        ;;
esac
