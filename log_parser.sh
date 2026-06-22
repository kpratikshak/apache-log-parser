# 1. grep -oE: Extract only the strings matching the IP regex
# 2. sort: Sort them so duplicate IPs sit next to each other
# 3. uniq -c: Group duplicates and prefix them with a occurrence count (e.g., "   5 192.168.1.1")
# 4. awk: Format the "Count IP" text stream into clean "IP,Count" CSV lines

#!/bin/bash

# Default output file
OUTPUT_FILE="ip_count.csv"
LOG_FILE=""

# RegEx for matching IPv4 addresses
IP_REGEX="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"

# Function to show script usage
usage() {
    echo "Usage: $0 --l <logfile> [--o <outputfile>]"
    echo "  --l, --logfile    Logfile to parse (Required)"
    echo "  --o, --output     Output CSV file name (Default: ip_count.csv)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --l|--logfile) LOG_FILE="$2"; shift ;;
        --o|--output) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Validate that the required logfile argument was provided
if [ -z "$LOG_FILE" ]; then
    echo "Error: Missing required argument --l/--logfile"
    usage
fi

# Validate that the log file actually exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' does not exist."
    exit 1
fi

echo "IP_Address,Count" > "$OUTPUT_FILE"

grep -oE "$IP_REGEX" "$LOG_FILE" | \
    sort | \
    uniq -c | \
    awk '{print $2 "," $1}' >> "$OUTPUT_FILE"

echo "IP counts written to $OUTPUT_FILE"
