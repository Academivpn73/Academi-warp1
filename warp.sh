#!/data/data/com.termux/files/usr/bin/bash

VERSION="1.6.5"
ADMIN="@MahdiAGM0"
CHANNEL="@Academi_vpn"
INSTALLER="Academivpn_warp"
INSTALL_PATH="/data/data/com.termux/files/usr/bin/$INSTALLER"
PROXY_TMP="$HOME/.proxy_list.txt"

RED='\e[31m'; GREEN='\e[32m'; CYAN='\e[36m'; NC='\e[0m'

title(){
  clear
  echo -e "${CYAN}"
  echo    "╭──────────────────────────────────────╮"
  echo -e "│ Academi VPN Tool            v$VERSION │"
  echo -e "│ Telegram: $CHANNEL"
  echo -e "│ Admin:    $ADMIN"
  echo    "╰──────────────────────────────────────╯"
  echo -e "${NC}"
}

check_deps(){
  for cmd in curl jq grep ping; do
    command -v $cmd &>/dev/null || pkg install -y $cmd &>/dev/null
  done
}

create_installer(){
  echo -e "${GREEN}Created shortcut: $INSTALLER${NC}"
  echo -e "#!/bin/bash\nbash \"$(realpath "$0")\"" > "$INSTALL_PATH"
  chmod +x "$INSTALL_PATH"
}

remove_installer(){
  rm -f "$INSTALL_PATH" && echo -e "${GREEN}Removed shortcut.${NC}"
}

scan_warp(){
  echo -e "${CYAN}Generating 10 random IP:Port (with ping)...${NC}"
  count=0
  while [ $count -lt 10 ]; do
    ip=$(shuf -i 1-255 -n1).$(shuf -i1-255 -n1).$(shuf -i1-255 -n1).$(shuf -i1-255 -n1)
    port=$(shuf -i1000-65000 -n1)
    ping_ms=$(ping -c1 -W1 "$ip" 2>/dev/null|grep time=|awk -F'time=' '{print $2}'|cut -d' ' -f1)
    if [ -n "$ping_ms" ]; then
      echo -e "${GREEN}IP: $ip:$port${NC}  Ping: ${ping_ms}ms"
      ((count++))
    fi
  done
}

fetch_proxies(){
  echo -e "${GREEN}Fetching Telegram proxies...${NC}"
  > "$PROXY_TMP"

  # Source 1: MTPro.XYZ
  curl -fsSL "https://mtpro.xyz/mtproto" | grep -Eo 'tg://proxy\?server=[^&]+&port=[0-9]+' >> "$PROXY_TMP"

  # Source 2: GitHub raw
  curl -fsSL "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt" |
  grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{2,5}' |
  awk -F':' '{print "tg://proxy?server="$1"&port="$2}' >> "$PROXY_TMP"

  # Source 3: Custom (add more if needed)
  curl -fsSL "https://raw.githubusercontent.com/roosterkid/opml-browse/master/resources/mtproto.txt" |
  grep -E '^tg://' >> "$PROXY_TMP"

  sort -u "$PROXY_TMP" | grep -E '^tg://proxy\?server=' | head -n10 > "$PROXY_TMP"
}

show_proxies(){
  fetch_proxies
  if ! [[ -s $PROXY_TMP ]]; then
    echo -e "${RED}❌ No working Telegram proxies found.${NC}"
    return
  fi
  echo -e "${CYAN}Top 10 Telegram Proxies:${NC}"
  cat -n "$PROXY_TMP" | while read n p; do
    echo -e "${CYAN}Proxy $n:${NC} $p"
  done
}

main_menu(){
  title
  echo -e "${CYAN}1) Warp IP Scanner"
  echo -e "2) Telegram Proxies"
  echo -e "3) Install shortcut (${INSTALLER})"
  echo -e "4) Remove shortcut"
  echo -e "0) Exit${NC}"
  read -p "Choose: " c
  case $c in
    1) scan_warp ;;
    2) show_proxies ;;
    3) create_installer ;;
    4) remove_installer ;;
    0) exit ;;
    *) echo -e "${RED}Invalid option.${NC}" ;;
  esac
  read -p "Press Enter..." && main_menu
}

check_deps
main_menu
