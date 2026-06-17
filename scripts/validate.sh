#!/bin/bash

set -euo pipefail

SERVICE_NAME="infra-demo"
MAINT_SERVICE="infra-maintenance.service"
MAINT_TIMER="infra-maintenance.timer"
USER="infraadmin"
PORT=8080
ERRORS=0


##helper functions


check_perm()
{
  local path=$1
  local expected_owner=$2
  local expected_perms=$3

  if [[ ! -e $path ]]; then
    echo "[FAIL]: path $path doesn't exist."
    return 1
  fi

  local curr_owner
  local curr_perms
  curr_owner=$(stat -c "%U:%G" "$path")
  curr_perms=$(stat -c "%a" "$path")

  if [[ "$curr_owner" != "$expected_owner" ]] || [[ "$curr_perms" != "$expected_perms" ]]; then
    echo "[FAIL]: $path (Got $curr_owner $curr_perms, expected $expected_owner $expected_perms)"
    return 1
  else
    echo "[PASS]: $path matches config ($expected_owner $expected_perms)."
    return 0
  fi
}


echo "**********************"
echo "Infra Validation start"
echo "**********************"

##service health

if systemctl is-active --quiet "$SERVICE_NAME"; then
  echo "[OK]: $SERVICE_NAME active"
# checking if active and not want to disturb the continuation of script. if not then the second part triggers and echo part then status printed then exit
else
  systemctl status $SERVICE_NAME
  ERRORS=$((ERRORS+1))
  echo "[FAIL]: Service is not active."
fi

##Timer health

echo "[CHECK]: Maintenance Timer"

if systemctl is-active --quiet "$MAINT_TIMER"; then
   echo "[OK]: timer active"
else
  systemctl status $MAINT_TIMER
  ERRORS=$((ERRORS+1))
  echo "[OK]: timer active"
fi


##HTTP health check

echo "[CHECK]: http response..."

if ! curl -sf "http://localhost:${PORT}/health" >/dev/null; then
  # ! symbolises not
  echo "[FAIL]: http endpoint not responding."
  ERRORS=$((ERRORS+1))
else
  echo "[OK]: http responding."
fi

##port check

echo "[CHECK]: port listening..."

if ss -tulnp | grep -q ":${PORT}"; then
  echo "[OK]: Port $PORT open."

else
  ERRORS=$((ERRORS+1))
  echo "[FAIL]: port $PORT not open."
fi


##firewall check

echo "[CHECK] firewall rules..."
if ufw status | grep -q "Status: active"; then
  # rules are actually there
  if ufw status | grep -q "$PORT/tcp" && (ufw status | grep -q "22/tcp" || ufw status | grep -q "OpenSSH"); then
    echo "[OK]: firewall is ACTIVE; access rules for health service &PORT and ssh are enforced."
  else
    echo "[FAIL]: Firewall active; missing rules."
    ERRORS=$((ERRORS+1))
  fi
else
  echo "[FAIL]: Firewall INACTIVE."
  ERRORS=$((ERRORS+1))
fi

##user check

echo "[CHECK]: Service user..."

if id "$USER" >/dev/null 2>&1; then
 echo "[OK]: user $USER exists."
else
  ERRORS=$((ERRORS+1))
  echo "[FAIL]: user does not exist."
fi


##file permissions check

echo "[CHECK]: file permissions..."

check_perm "/opt/infra-demo/app.py" "infraadmin:infraadmin" "640"  || ERRORS=$((ERRORS+1))
check_perm "/opt/infra-demo/maintenance.sh" "infraadmin:infraadmin" "750"  || ERRORS=$((ERRORS+1))
check_perm "/etc/infra-demo/infra-demo.env" "infraadmin:infraadmin" "600"  || ERRORS=$((ERRORS+1))
check_perm "/etc/systemd/system/infra-demo.service" "root:root" "640"  || ERRORS=$((ERRORS+1))
check_perm "/etc/systemd/system/infra-maintenance.service" "root:root" "640"  || ERRORS=$((ERRORS+1))
check_perm "/etc/systemd/system/infra-maintenance.timer" "root:root" "640"  || ERRORS=$((ERRORS+1))


## reboot survival check
echo "[CHECK]: reboot survivability."

IS_ENABLED=$(systemctl is-enabled "${SERVICE_NAME}.service" || echo "disabled")
IS_TIMER_ENABLED=$(systemctl is-enabled "$MAINT_TIMER" || echo "disabled")
if [[ "$IS_ENABLED" == "enabled" ]] && [[ "$IS_TIMER_ENABLED" == "enabled" ]]; then
  echo "[OK]: Both ${SERVICE_NAME}.service and $MAINT_TIMER will survive a reboot."
else
  echo "[FAIL]: Reboot survival compromised. service:$IS_ENABLED timer: $IS_TIMER_ENABLED."
  ERRORS=$((ERRORS+1))
fi


##log validation

echo  "[CHECK]: logs..."

LOG_FILE="/var/log/infra-demo-health.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "[FAIL] log file missing"
  ERRORS=$((ERRORS+1))
fi
if [[ ! -s "$LOG_FILE" ]]; then
  echo "[WARN]: log file empty(might be a new system)"
fi

echo "[OK]: logs are there."



##final result
if [[ $ERRORS -eq 0 ]]; then
  echo -e "\n[SUCCESS]: system matches target operational thresholds."
else
  echo -e "\n[ERROR]: validation failed with $ERRORS critical anomalies. review logs above. "
  exit 1
fi





































