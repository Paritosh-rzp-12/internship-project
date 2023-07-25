#!/bin/bash

# Check if the input folder is provided
if [ $# -eq 0 ]; then
  echo "Error: JSON files folder path is missing."
  exit 1
fi

# Check if the `jq` command is installed
if ! command -v jq >/dev/null; then
  echo "Error: 'jq' is required but not installed. Please install 'jq' to run this script."
  exit 1
fi

# Read JSON files folder path from command line argument
json_folder=$1

# Check if the folder exists
if [ ! -d "$json_folder" ]; then
  echo "Error: Folder '$json_folder' not found."
  exit 1
fi

# Create a directory for parsed JSON files
parsed_folder=$2
mkdir -p "$parsed_folder"

# Loop through each JSON file in the folder
for json_file in "$json_folder"/*.json; do
  # Get the base name of the file without extension
  base_name=$(basename "$json_file" .json)

  # Parse JSON and extract the values of the keys "message", "lines", and "severity"
  messages=$(jq -r '.results[].extra.message' "$json_file")
  lines=$(jq -r '.results[].extra.lines' "$json_file")
  severities=$(jq -r '.results[].extra.severity' "$json_file")

  # Create a text file with the same name as the JSON file in the parsed folder
  output_file="$parsed_folder/$base_name.txt"

  # Combine the values and write them to the output file
  paste -d'|' <(echo "$messages") <(echo "$lines") <(echo "$severities") > "$output_file"

  echo "Parsed file: $output_file"
done
