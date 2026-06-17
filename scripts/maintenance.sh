#!/bin/bash


set -euo pipefail

LOG_FILE="/var/log/infra-demo-health.log" #putting a log for the health service here
HEALTH_URL="http://localhost:8080/health"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

## now we will collect the health snapshots/logs

if RESPONSE=$(curl -fsS "$HEALTH_URL" 2>/dev/null); then # -s hides progress meter and -S will still let it show errors, -f is for if request fails then
# then it fails fast with no output
  echo "[$TIMESTAMP] Health check status: $RESPONSE" >> "$LOG_FILE"
else
  echo "[$TIMESTAMP] Health check failed: $RESPONSE" >> "$LOG_FILE"
fi


#log cleaup- keeping the only latest 50 lines, can always change it, i went with a  number that i think would be fine for this kind of work

if [[ -f "$LOG_FILE" ]]; then #means if it exists or not
  tail -n 50 "$LOG_FILE" > "${LOG_FILE}.tmp"
  mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi
echo "Maintenance task completed at [$TIMESTAMP]."
