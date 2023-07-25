#!/bin/sh

./subdomain_enum.sh 

./semgrep_scan.sh 

./parse_json.sh secret_scan_results secret_scan_parsed_files

./parse_json.sh scan_results scan_parsed_files

nuclei -up

nuclei

nuclei -rl 10 -l /app/allSubdomainsFiles/domains_razorpay.com_final.txt -j -o nucleiScanResults

tail -f /dev/null