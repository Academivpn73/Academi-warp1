import os
import time
import requests
import random
from colorama import Fore, Style, init

init(autoreset=True)

VERSION = "1.0.2"
CHANNEL = "Telegram: @Academi_vpn"
SUPPORT = "Support: @MahdiAGM0"

def title():
    os.system("clear")
    print(Fore.CYAN + "═" * 50)
    print(Fore.GREEN + f"     Academi VPN Script  |  Version {VERSION}")
    print(Fore.YELLOW + f"     {CHANNEL}")
    print(Fore.MAGENTA + f"     {SUPPORT}")
    print(Fore.CYAN + "═" * 50)
    print()

def menu():
    print(Fore.BLUE + "[1] WARP IP Scanner (IPv4 only)")
    print(Fore.BLUE + "[2] Telegram Proxy Fetcher (auto-updated)")
    print(Fore.RED + "[0] Exit")
    print()

def scan_warp_ips():
    print(Fore.CYAN + "\nScanning best WARP IPv4 IPs...\n")
    working_ips = []

    for _ in range(50):  # افزایش تلاش برای پیدا کردن 10 ایپی
        ip = f"162.159.{random.randint(0,255)}.{random.randint(1,254)}"
        port = random.choice([80, 443, 8080, 2053, 2083, 2087, 2096, 8443])
        try:
            start = time.time()
            response = os.system(f"ping -c 1 -W 1 {ip} > /dev/null")
            delay = round((time.time() - start)*1000, 2)
            if response == 0:
                print(f"{Fore.GREEN}{ip}:{port}  {Fore.WHITE}Ping: {delay}ms")
                working_ips.append(f"{ip}:{port}  Ping: {delay}ms")
            if len(working_ips) >= 10:
                break
        except:
            continue
    if not working_ips:
        print(Fore.RED + "❌ No working IPv4 IPs found.\n")
    else:
        print(Fore.GREEN + f"\n✔ Found {len(working_ips)} working IPs.\n")

    input(Fore.YELLOW + "\nPress Enter to return to menu...")

def fetch_telegram_proxies():
    print(Fore.CYAN + "\nFetching free Telegram proxies...\n")
    try:
        res = requests.get("https://api.openproxy.space/tg", timeout=10)
        data = res.json()
        proxies = data.get("proxies", [])[:10]  # دریافت 10 عدد اول
        if not proxies:
            print(Fore.RED + "No proxies found.")
        for i, p in enumerate(proxies, 1):
            print(Fore.GREEN + f"[{i}] tg://proxy?server={p['host']}&port={p['port']}&secret={p['secret']}")
    except Exception as e:
        print(Fore.RED + "Error fetching proxies:", e)

    input(Fore.YELLOW + "\nPress Enter to return to menu...")

# اجرای اسکریپت
while True:
    title()
    menu()
    choice = input(Fore.CYAN + "\nSelect an option: ")

    if choice == "1":
        scan_warp_ips()
    elif choice == "2":
        fetch_telegram_proxies()
    elif choice == "0":
        print(Fore.YELLOW + "Exiting. Goodbye!")
        break
    else:
        print(Fore.RED + "Invalid input!")
        time.sleep(1)
