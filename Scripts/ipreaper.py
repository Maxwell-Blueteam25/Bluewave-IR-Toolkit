import requests
import json
import socket
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.style import Style

ABUSEIPDB_KEY = "[Replace]"
VT_API_KEY = "[Replace]"

console = Console()

category_names = {
    1: "DNS Compromise",
    2: "Bad Web Bot",
    3: "Spamming",
    4: "Port Scan",
    5: "Brute-Force",
    6: "Bad Web App Activity",
    7: "Exploit",
    8: "Hacking",
    9: "Malware",
    10: "Open Proxy",
    11: "Web App Attack",
    12: "SQL Injection",
    14: "Data Mining",
    15: "Fraud Orders",
    16: "DDoS Attack",
    17: "Credential Stuffing",
    18: "Email Abuse",
    19: "Blog Spam",
    20: "Comment Spam",
    21: "Forum Spam",
    22: "Guestbook Spam",
    23: "HTTP Spam",
    24: "Irc Spam",
    25: "Proxy Spam",
    26: "Referrer Spam",
    27: "Web Spam",
    28: "Custom Category",
    29: "CVE Exploit",
    30: "SSH",
    31: "IoT Targeted",
    32: "Phishing",
    33: "Machine Learning Abuse",
    34: "TOR Exit Node",
    35: "Ransomware",
    36: "Cryptojacking",
    37: "Abuse",
    38: "Mobile App Abuse",
    39: "Vulnerability Scan",
    40: "Spam Bot",
    41: "Content Delivery Network",
    42: "Attack Source",
    43: "Compromised Server",
    44: "Cloud Provider",
    45: "VPN",
    46: "Residential ISP",
    47: "Education",
    48: "Search Engine Bot",
    49: "Reverse Proxy",
    50: "DDOS",
    51: "Scanning",
    52: "Brute Force",
    53: "Malicious Host",
    54: "Malicious URL",
    55: "Compromised Website",
    56: "Malicious Activity",
    57: "Hosting Provider",
    58: "TOR",
    59: "Proxy",
    60: "VPN Service",
    61: "Hosting Service",
    62: "Cloud Service",
    63: "CDN Service",
    64: "Residential IP",
    65: "Education Network",
    66: "Search Engine",
    67: "Reverse Proxy Service",
    68: "DDOS Attack",
    69: "Scanning Activity",
    70: "Brute Force Attack",
    71: "Malicious Hosting",
    72: "Malicious Website",
    73: "Compromised Server",
    74: "Compromised Website",
    75: "Malicious Activity",
    76: "Hosting Provider",
    77: "TOR Exit Node",
    78: "Proxy Server",
    79: "VPN Server",
    80: "Hosting Server",
    81: "Cloud Server",
    82: "CDN Server",
    83: "Residential IP Address",
    84: "Education Network",
    85: "Search Engine Bot",
    86: "Reverse Proxy Server",
    87: "DDOS Attack",
    88: "Scanning Activity",
    89: "Brute Force Attack",
    90: "Malicious Hosting",
    91: "Malicious Website",
    92: "Compromised Server",
    93: "Compromised Website",
    94: "Malicious Activity",
    95: "Hosting Provider",
    96: "TOR Exit Node",
    97: "Proxy Server",
    98: "VPN Server",
    99: "Hosting Server",
    100: "Cloud Server",
    101: "CDN Server",
    102: "Residential IP Address",
    103: "Education Network",
    104: "Search Engine Bot",
    105: "Reverse Proxy Server",
    106: "DDOS Attack",
    107: "Scanning Activity",
    108: "Brute Force Attack",
    109: "Malicious Hosting",
    110: "Malicious Website",
    111: "Compromised Server",
    112: "Compromised Website",
    113: "Malicious Activity",
    114: "Hosting Provider",
    115: "TOR Exit Node",
    116: "Proxy Server",
    117: "VPN Server",
    118: "Hosting Server",
    119: "Cloud Server",
    120: "CDN Server",
    121: "Residential IP Address",
    122: "Education Network",
    123: "Search Engine Bot",
    124: "Reverse Proxy Server",
    125: "DDOS Attack",
    126: "Scanning Activity",
    127: "Brute Force Attack",
    128: "Malicious Hosting",
    129: "Malicious Website",
    130: "Compromised Server",
    131: "Compromised Website",
    132: "Malicious Activity",
    133: "Hosting Provider",
    134: "TOR Exit Node",
    135: "Proxy Server",
    136: "VPN Server",
    137: "Hosting Server",
    138: "Cloud Server",
    139: "CDN Server",
    140: "Residential IP Address",
    141: "Education Network",
    142: "Search Engine Bot",
    143: "Reverse Proxy Server",
    144: "DDOS Attack",
    145: "Scanning Activity",
    146: "Brute Force Attack",
    147: "Malicious Hosting",
    148: "Malicious Website",
    149: "Compromised Server",
    150: "Compromised Website",
    151: "Malicious Activity",
    152: "Hosting Provider",
    153: "TOR Exit Node",
    154: "Proxy Server",
    155: "VPN Server",
    156: "Hosting Server",
    157: "Cloud Server",
    158: "CDN Server",
    159: "Residential IP Address",
    160: "Education Network",
    161: "Search Engine Bot",
    162: "Reverse Proxy Server",
    163: "DDOS Attack",
    164: "Scanning Activity",
    165: "Brute Force Attack",
    166: "Malicious Hosting",
    167: "Malicious Website",
    168: "Compromised Server",
    169: "Compromised Website",
    170: "Malicious Activity",
    171: "Hosting Provider",
    172: "TOR Exit Node",
    173: "Proxy Server",
    174: "VPN Server",
    175: "Hosting Server",
    176: "Cloud Server",
    177: "CDN Server",
    178: "Residential IP Address",
    179: "Education Network",
    180: "Search Engine Bot",
    181: "Reverse Proxy Server",
    182: "DDOS Attack",
    183: "Scanning Activity",
    184: "Brute Force Attack",
    185: "Malicious Hosting",
    186: "Malicious Website",
    187: "Compromised Server",
    188: "Compromised Website",
    189: "Malicious Activity",
    190: "Hosting Provider",
    191: "TOR Exit Node",
    192: "Proxy Server",
    193: "VPN Server",
    194: "Hosting Server",
    195: "Cloud Server",
    196:"python CDN Server",
    197: "Residential IP Address",
    198: "Education Network",
    199: "Search Engine Bot",
    200: "Reverse Proxy Server",
    201: "DDOS Attack",
    202: "Scanning Activity",
    203: "Brute Force Attack",
    204: "Malicious Hosting",
    205: "Malicious Website",
    206: "Compromised Server",
    207: "Compromised Website",
    208: "Malicious Activity",
    209: "Hosting Provider",
    210: "TOR Exit Node",
    211: "Proxy Server",
    212: "VPN Server",
    213: "Hosting Server",
    214: "Cloud Server",
    215: "CDN Server",
    216: "Residential IP Address",
    217: "Education Network",
    218: "Search Engine Bot",
    219: "Reverse Proxy Server",
}

def check_abuseipdb(ip):
    url = "https://api.abuseipdb.com/api/v2/check"
    params = {
        'ipAddress': ip,
        'maxAgeInDays': '90',
        'verbose': True
    }
    headers = {
        'Accept': 'application/json',
        'Key': ABUSEIPDB_KEY
    }

    try:
        resp = requests.get(url, headers=headers, params=params)
        resp.raise_for_status()
        data = resp.json()

        if data['data']['totalReports'] > 0:
            table = Table(title="AbuseIPDB Info", title_style="bold white")
            table.add_column("Metric", style="cyan", justify="right")
            table.add_column("Value", style="magenta")

            table.add_row("Total Reports", str(data['data']['totalReports']))
            table.add_row("Abuse Score", str(data['data']['abuseConfidenceScore']))
            table.add_row("Country", data['data']['countryCode'])

            console.print(Panel(table, border_style="green"))

            if 'reports' in data['data']:
                report_table = Table(title="AbuseIPDB Reports", title_style="bold white")
                report_table.add_column("Reported At", style="cyan")
                report_table.add_column("Category", style="magenta")
                report_table.add_column("Comment", style="green")

                for report in data['data']['reports']:
                    category_names_list = [category_names.get(cat, "Unknown") for cat in report['categories']]
                    categories = ", ".join(category_names_list)
                    report_table.add_row(report['reportedAt'], categories, report['comment'])

                console.print(Panel(report_table, border_style="green"))
        else:
            console.print(Panel("[yellow]Nothing found on AbuseIPDB[/yellow]", title="AbuseIPDB", border_style="green"))

    except requests.exceptions.RequestException as e:
        console.print(Panel(f"[red]AbuseIPDB error: {e}[/red]", title="AbuseIPDB Error", border_style="red"))
    except (KeyError, TypeError) as e:
        console.print(Panel(f"[red]Problem with AbuseIPDB data: {e}[/red]", title="AbuseIPDB Error", border_style="red"))

def check_virustotal(ip):
    url = f"https://www.virustotal.com/api/v3/ip_addresses/{ip}"
    headers = {
        "Accept": "application/json",
        "x-apikey": VT_API_KEY
    }

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()

        if 'data' in data and 'attributes' in data['data'] and 'last_analysis_stats' in data['data']['attributes']:
            stats = data['data']['attributes']['last_analysis_stats']

            table = Table(title="VirusTotal Results", title_style="bold white")
            table.add_column("Metric", style="cyan", justify="right")
            table.add_column("Value", style="magenta")

            table.add_row("Malicious", str(stats['malicious']))
            table.add_row("Suspicious", str(stats['suspicious']))
            table.add_row("Harmless", str(stats['harmless']))
            table.add_row("Undetected", str(stats['undetected']))

            console.print(Panel(table, border_style="blue"))

            analysis_results = data['data']['attributes']['last_analysis_results']
            analysis_table = Table(title="VirusTotal Analysis", title_style="bold white")
            analysis_table.add_column("Engine", style="cyan")
            analysis_table.add_column("Category", style="magenta")
            analysis_table.add_column("Result", style="green")

            for engine, result in analysis_results.items():
                analysis_table.add_row(engine, result['category'], result['result'])

            console.print(Panel(analysis_table, border_style="blue"))

        else:
            console.print(Panel("[yellow]VirusTotal has nothing[/yellow]", title="VirusTotal", border_style="blue"))

    except requests.exceptions.RequestException as e:
        console.print(Panel(f"[red]VirusTotal error: {e}[/red]", title="VirusTotal Error", border_style="red"))
    except (KeyError, TypeError) as e:
        console.print(Panel(f"[red]Problem with VirusTotal data: {e}[/red]", title="VirusTotal Error", border_style="red"))

def get_domain(ip):
    try:
        domain = socket.getfqdn(ip)
        console.print(Panel(f"[green]Domain: {domain}[/green]", title="Domain Info", border_style="green"))

    except socket.herror:
        console.print(Panel("[yellow]No domain found[/yellow]", title="Domain Info", border_style="yellow"))

if __name__ == "__main__":
    console.print(Panel("[bold white on blue]IPReaper - IP Info Tool[/bold white on blue]", border_style="blue", padding=(1, 1)))
    ip_address = console.input("[cyan]Enter IP:[/cyan] ")

    try:
        socket.inet_aton(ip_address)
    except socket.error:
        console.print("[red]Bad IP address[/red]")
        exit()

    check_abuseipdb(ip_address)
    check_virustotal(ip_address)
    get_domain(ip_address)