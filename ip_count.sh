#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ip_count.sh --l <logfile> [--o <output.csv>]
  ip_count.sh --logfile <logfile> [--output <output.csv>]

Options:
  --l, --logfile   Log file to parse (required)
  --o, --output    Output CSV file name (default: ip_count.csv)
EOF
}

logfile=""
outputfile="ip_count.csv"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --l|--logfile)
      [[ $# -ge 2 ]] || { echo "Error: missing value for $1" >&2; usage; exit 2; }
      logfile="$2"
      shift 2
      ;;
    --o|--output)
      [[ $# -ge 2 ]] || { echo "Error: missing value for $1" >&2; usage; exit 2; }
      outputfile="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

[[ -n "$logfile" ]] || { echo "Error: --logfile/--l is required" >&2; usage; exit 2; }
[[ -r "$logfile" ]] || { echo "Error: cannot read logfile: $logfile" >&2; exit 1; }

# Extract IPs, count, write CSV
# - grep -oE prints only matches, one per line
# - sort + uniq -c counts occurrences
# - awk formats CSV and writes header
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' -- "$logfile" \
  | sort \
  | uniq -c \
  | awk -v out="$outputfile" '
      BEGIN {
        print "IP_Address,Count" > out
      }
      {
        # uniq -c output: <count> <ip>
        count=$1
        ip=$2
        print ip "," count >> out
      }
    '

echo "IP counts written to $outputfile"
