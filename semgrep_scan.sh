#!/bin/bash

# Variables
ORGANIZATION="razorpay"
OUTPUT_DIRECTORY="scan_results"
SECRET_SCAN_DIRECTORY="secret_scan_results"
CLONE_DIRECTORY="cloned_repos"

# Create output and clone directories if they don't exist
mkdir -p "$OUTPUT_DIRECTORY"
mkdir -p "$SECRET_SCAN_DIRECTORY"
mkdir -p "$CLONE_DIRECTORY"

# Function to scan a repository using Semgrep
scan_repository() {
    local repo_url=$1
    local repo_name=$(basename "$repo_url")
    local semgrep_output="$OUTPUT_DIRECTORY/semgrep_$repo_name.json"
    local secret_scan_output="$SECRET_SCAN_DIRECTORY/semgrep_$repo_name.json"
    local clone_path="$CLONE_DIRECTORY/$repo_name"

    echo "Scanning: $repo_url"

    # Clone the repository
    if git clone --depth 1 "$repo_url" "$clone_path" >/dev/null 2>&1; then
        # Semgrep scan with default rules
        semgrep --config=auto --json -o "$semgrep_output" "$clone_path"

        # Semgrep scan with "p/secrets" configuration
        semgrep --config=p/secrets --json -o "$secret_scan_output" "$clone_path"

        echo "Scan completed: $repo_url"
        echo ""
    else
        echo "Failed to clone: $repo_url"
        return 1
    fi
}

# Main script  
page=1
while true; do
    api_url="https://api.github.com/orgs/$ORGANIZATION/repos?page=$page&per_page=100"
    response=$(curl -s "$api_url")

    if [ "$(echo "$response" | jq 'length')" -eq 0 ]; then
        break
    fi

    echo "$response" | jq -r '.[] | .html_url' |
    while IFS= read -r repo_url; do
        scan_repository "$repo_url" || continue
    done

    page=$((page+1))

    # Sleep for a few seconds to avoid rate limits
    sleep 2
done

echo "Scan completed. Results stored in $OUTPUT_DIRECTORY and $SECRET_SCAN_DIRECTORY."
