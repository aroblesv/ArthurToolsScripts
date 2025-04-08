#!/bin/bash

# Set the column number to check (e.g., 3 for the third column)
column_number=9

# Set the threshold value
threshold="2.88"

# Set the highlight color (e.g., "1;31" for bold red)
highlight_color="1;32"

# Check if a filename is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 report_pdu_information-highlight"
  exit 1
fi

filename="$1"

# Check if the file exists
if [ ! -f "$filename" ]; then
  echo "Error: File '$filename' not found."
  exit 1
fi

awk -v col="$column_number" -v thresh="$threshold" -v color="$highlight_color" '
{
  if ($col > thresh) {
    printf "\033[%sm%s\033[0m\n", color, $0;
  } else {
    print $0;
  }
}' "$filename"
