#!/bin/bash

# ============ Config ============
SCRIPT_VERSION="1.0.7"
CHANNEL_ID="@AcademiVpn"
SUPPORT_ID="@MahdiAGM0"
INSTALLER_CMD="Academivpn_warp"
TMP_DIR="/tmp/academi"
mkdir -p "$TMP_DIR"

# ============ Colors ============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ============ Installer ============
setup_installer() {
  echo -e "${CYAN}Installing launcher command: ${INSTALLER_CMD}${RESET}"
  echo "#!/data/data/com.termux/files/usr/bin/bash" > /data/data/com.termux/files/usr/bin/${INSTALLER_CMD}
  echo "bash ~/warp.sh" >> /data/data/com.termux/files/usr/bin/${INSTALLER_CMD}
  chmod +x /data/data/com.termux/files/usr/bin/${INSTALLER_CMD}
  echo -e "${GREEN}✅ Installed. Use '${INSTALLER_CMD}' to launch.${RESET}"
}

remove_installer() {
  echo -e "${YELLOW}Removing installer...${RESET}"
  rm -f /data/data/com.termux/files/usr/bin/${INSTALLER_CMD}
  echo -e "${GREEN}✅ Removed.${RESET}"
}

# ============ Requirements ============
install_requirements() {
  echo -e "${CYAN}Installing required packages...${RESET}"
  pkg update -y
  pkg install -y curl jq unzip
  curl -fsSL https://github.com/ViRb3/wgcf/releases/latest/download/wgcf_1.0.5_linux_arm64 -o /data/data/com.termux/files/usr/bin/wgcf
  chmod +x /data/data/com.termux/files/usr/bin/wgcf
}

# ============ Proxy Fetch ============
fetch_proxies() {
  echo -e "${CYAN}🔄 Fetching Telegram MTProto proxies...${RESET}"
  proxies=$(curl -s https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt | grep -Eo 'tg://proxy\?server=[^&]+' | sort -u | head -n 10)
  if [[ -z "$proxies" ]]; then
    echo -e "${RED}❌ No valid Telegram proxies found.${RESET}"
  else
    echo -e "${GREEN}✅ Top 10 Telegram Proxies:${RESET}"
    echo "$proxies"
  fi
}

# ============ WARP IP Scanner ============
scan_warp_ips() {
  echo -e "${CYAN}🔍 Scanning WARP IPv4 IPs...${RESET}"
  for i in {1..10}; do
    ip="162.$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
    port=$((RANDOM % 65535 + 1))
    ping=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [[ ! -z "$ping" ]]; then
      echo -e "${GREEN}✔️ $ip:$port  ping=${ping}ms${RESET}"
    else
      echo -e "${RED}❌ $ip:$port  unreachable${RESET}"
    fi
  done
}

# ============ Main Menu ============
main_menu() {
  clear
  echo -e "${BLUE}╔══════════════════════════════════╗"
  echo -e "║     AcademiVPN WARP Script      ║"
  echo -e "║         Version: ${SCRIPT_VERSION}           ║"
  echo -e "╠══════════════════════════════════╣"
  echo -e "║ Support: ${SUPPORT_ID}           ║"
  echo -e "║ Channel: ${CHANNEL_ID}           ║"
  echo -e "╚══════════════════════════════════╝${RESET}"
  echo
  echo -e "${YELLOW}1) Scan WARP IPs"
  echo "2) Get Telegram Proxies"
  echo "3) Install Launcher Command (${INSTALLER_CMD})"
  echo "4) Remove Launcher Command"
  echo "0) Exit${RESET}"
  echo
  read -p "❯ Select: " option

  case $option in
    1) scan_warp_ips ;;
    2) fetch_proxies ;;
    3) setup_installer ;;
    4) remove_installer ;;
    0) exit ;;
    *) echo -e "${RED}❌ Invalid option${RESET}" ;;
  esac

  echo
  read -p "🔁 Press Enter to return to menu..."
  main_menu
}

# ============ First Run ============
install_requirements
main_menu
