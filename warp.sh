#!/bin/bash

===============[ Info Section ]===============

VERSION="1.6.1" ADMIN_ID="@AcademiVPN" CHANNEL_ID="@AcademiVPN"

===============[ File Paths ]===============

PROXY_FILE="/tmp/mtproxies.txt"

===============[ UI Functions ]===============

print_header() { clear echo "=====================================" echo "🚀 Telegram Proxy Auto-Updater v$VERSION" echo "🔰 Channel: $CHANNEL_ID" echo "👤 Admin: $ADMIN_ID" echo "=====================================" }

===============[ Proxy Fetcher ]===============

fetch_proxies() { echo -e "\n🔄 Fetching fresh Telegram proxies..." URL="https://raw.githubusercontent.com/ejabberd-contrib/proxy-list/main/mtproto.json" PROXIES=$(curl -s "$URL" | jq -r '.[] | "(.host):(.port)"' 2>/dev/null)

if [[ -z "$PROXIES" ]]; then
    echo "❌ No valid Telegram proxies found."
    return 1
fi

echo "$PROXIES" > "$PROXY_FILE"
echo "✅ Proxies updated successfully."

}

===============[ Proxy Viewer ]===============

show_proxies() { if [[ ! -f "$PROXY_FILE" ]]; then echo "🔍 No proxy file found. Fetching now..." fetch_proxies || return fi

echo -e "\n🌐 Top 10 Telegram Proxies:\n"
count=1
while IFS= read -r proxy && [[ $count -le 10 ]]; do
    ping_ms=$(ping -c 1 -W 1 "${proxy%%:*}" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
    echo "Proxy $count : $proxy 🕒 ${ping_ms:-N/A} ms"
    ((count++))
done < "$PROXY_FILE"

}

===============[ Auto-Updater ]===============

enable_auto_update() { echo -e "\n🛠 Enabling daily auto-update (via cron)..." (crontab -l 2>/dev/null; echo "0 6 * * * bash $PWD/$0 --update > /dev/null 2>&1") | crontab - echo "✅ Auto-update enabled." }

===============[ Main Menu ]===============

main_menu() { print_header echo "1) 🌐 Show Top 10 Telegram Proxies" echo "2) ♻️  Update Proxies Now" echo "3) 📅 Enable Daily Auto-Update" echo "0) ❌ Exit" echo -n ">> " read opt case $opt in 1) show_proxies;; 2) fetch_proxies;; 3) enable_auto_update;; 0) echo "👋 Goodbye!"; exit 0;; *) echo "❗ Invalid option.";; esac echo -e "\nPress enter to return to menu..." read main_menu }

===============[ CLI Mode ]===============

if [[ $1 == "--update" ]]; then fetch_proxies exit fi

===============[ Run ]===============

main_menu

