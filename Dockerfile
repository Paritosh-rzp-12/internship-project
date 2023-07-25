# Use the latest stable golang-alpine image as the base
FROM golang:alpine

# Install necessary dependencies
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache git build-base libpcap-dev openssl curl jq bash python3-dev py3-pip nmap unzip libxml2-dev libxslt-dev

# Install pip for Python package management
RUN pip3 install --upgrade pip

# Install Semgrep
RUN pip3 install semgrep

# git-hound
RUN git clone https://github.com/tillson/git-hound.git && \
    cd git-hound && \
    go build -o /usr/local/bin/git-hound

# Install Nuclei
RUN go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Install naabu
RUN go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

# Install gobuster
RUN go install -v github.com/OJ/gobuster/v3@latest

# Install hakrawler
RUN go install github.com/hakluke/hakrawler@latest

# Install Gospider
RUN go install github.com/jaeles-project/gospider@latest

# Install ffuf
RUN go install github.com/ffuf/ffuf/v2@latest

# Install feroxbuster
RUN wget -qO feroxbuster.zip "https://github.com/epi052/feroxbuster/releases/latest/download/x86_64-linux-feroxbuster.zip" && \
    unzip -d /tmp/ feroxbuster.zip feroxbuster && \
    chmod +x /tmp/feroxbuster && \
    wget -O /tmp/raft-medium-directories.txt "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-medium-directories.txt"

# Install amass
RUN go install -v github.com/owasp-amass/amass/v3/...@master

# Install subfinder
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Install gau
RUN go install github.com/lc/gau/v2/cmd/gau@latest

# Set the working directory
WORKDIR /app

# Install SpiderFoot
RUN git clone https://github.com/smicallef/spiderfoot.git && \
    cd spiderfoot && \
    pip3 install -r requirements.txt

# Copy scripts
COPY semgrep_scan.sh .
COPY subdomain_enum.sh .
COPY parse_json.sh .
COPY run_scripts.sh .

# Set permissions
RUN chmod +x semgrep_scan.sh subdomain_enum.sh parse_json.sh run_scripts.sh

CMD ["bash", "run_scripts.sh"]
