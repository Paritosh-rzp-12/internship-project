#!/bin/bash
domain="razorpay.com"
dir="allSubdomainsFiles"
output_file="${dir}/domains_${domain}_final.txt"
[ -d "$dir" ] || mkdir "$dir"
amass enum --passive -d "$domain" -o "${dir}/amass_domains.txt"
subfinder -d "$domain" -o "${dir}/subfinder_domains.txt"
cat "${dir}/subfinder_domains.txt" | tee -a "${dir}/amass_domains.txt"
sort -u "${dir}/amass_domains.txt" -o "${dir}/amass_domains.txt"
# Python script for resolving domains
python_script=$(cat <<END_SCRIPT
import socket
import os
input_file = os.path.join("${dir}", "amass_domains.txt")
output_file = "${output_file}"
def resolve_domains(domains):
    resolved_domains = []
    for domain in domains:
        try:
            ip_address = socket.gethostbyname(domain)
            resolved_domains.append(domain)
        except socket.error:
            pass
    return resolved_domains
# Read subdomains from input file
with open(input_file, 'r') as file:
    subdomains = [line.strip() for line in file]
# Resolve subdomains
resolved_domains = resolve_domains(subdomains)
# Write resolved domains to output file
with open(output_file, 'w') as file:
    for domain in resolved_domains:
        file.write(f"{domain}\n")
END_SCRIPT
)
# Execute the Python script
echo "$python_script" | python3