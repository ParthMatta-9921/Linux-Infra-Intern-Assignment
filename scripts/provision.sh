#!/bin/bash


set -euo pipefail #for not letting the errors be masked


SERVICE_USER="infraadmin" # creating a user that would have the permissions to run the service
SERVICE_NAME="infra-demo" # useful for putting service name here so only need to write once

REPO_ROOT="$(pwd)"


echo "************************"
echo "Starting Infra Demo provisioning..."
echo "************************"


## verify if user is using sudo or running from root, as we need sudo to work with systemd

if [[ "$EUID"  -ne 0 ]]; then
  echo "[ERROR]: Run script with sudo"
  exit 1
fi




##OS Detection

if [[ -f /etc/os-release ]]; then # checking if the dir exists or not
  source /etc/os-release  # executes /etc/os-release thereby  loading environment variables from os-release
  echo "[INFO]: Detected OS: $NAME $VERSION_ID"
  # checking if  ubuntu os or not, if not then exit 
  if [[ "$ID" != "ubuntu" ]]; then
    echo "[ERROR]: This script only for ubuntu."
  exit 1 # failure
  fi

else
  echo "[ERROR]: No OS Detected"
  exit 1 #exiting with failure
fi


## ssh review and backup

echo "[INFO]: Reviewing and backing up ssh defaults"
if [[ -f /etc/ssh/ssh_config ]]; then
  if [[ ! -f/etc/ssh/ssh_config.bak ]]; then #no backup 
    cp /etc/ssh/ssh_config /etc/ssh/ssh_config.bak
    echo "[INFO]: Created Original SSH Backup at /etc/ssh/ssh_config.bak"
  else
  echo "[INFO]: Backup file already exists."
  fi

  #logging the default port
  SSH_PORT=$(grep -E "^#?Port " /etc/ssh/ssh_config | awk '{print $2'} || echo) # grep pattern means start at the line,#? means it should match # 0 or 1 time.
  # so line that has # at the start  or not then immediately following should be Port. awk just prints the second field separated by space
  echo "[INFO]: Default SSH port detected: ${SSH_PORT:-22}" # 22 is default
else
  echo "[Warning]: /etc/ssh/ssh_config not found. is SSH server installed?"
fi




## check if repo files successfully cloned

required_files=("app/app.py" "config/infra-demo.env" "scripts/provision.sh" "scripts/maintenance.sh" "systemd/infra-demo.service" "systemd/infra-maintenance.service" "systemd/infra-maintenance.timer")

for file in "${required_files[@]}"; do
  echo $REPO_ROOT/$file;echo;
  [[ -f $REPO_ROOT/$file ]] || { echo "[ERROR]: Missing $file"; exit 1; }
done

#we are in a linux environment as /etc/os-release  is present
##package  management

# package update

echo "[INFO]: Updating packages..."

apt-get update #no need for sudo as already run by user with sudo permission

#package installation
  #already idempotent

echo "[INFO]: installing reqired packages..."

apt-get install -y python3 curl ufw # python3 for healths ervice curl for validation and ufw fro firewall




##creating the operational user
 #idempotent
if id "$SERVICE_USER"  >/dev/null 2>&1; then
  echo "[INFO]: User $SERVICE_USER already exists"


else

  echo "[INFO]: Creating User $SERVICE_USER"
  useradd -m -s /bin/bash "$SERVICE_USER"
  usermod -aG sudo  "$SERVICE_USER" # adding user to sudo and making a  new group for more users to be added in future
fi


##creating install directories as i saw in labex it is linux conventions to do this, to make it standard
echo "[INFO]: creating directories as to linux standards"
mkdir -p /opt/infra-demo
mkdir -p /etc/infra-demo




##instaliing files to their rightful place, not the strcuture that came with the repo
echo "[INFO]: copying files as to linux standards..."
cp app/app.py /opt/infra-demo/app.py
cp config/infra-demo.env /etc/infra-demo/infra-demo.env
cp systemd/infra-demo.service /etc/systemd/system/infra-demo.service
cp scripts/maintenance.sh /opt/infra-demo/maintenance.sh
cp systemd/infra-maintenance.service /etc/systemd/system/infra-maintenance.service
cp systemd/infra-maintenance.timer /etc/systemd/system/infra-maintenance.timer


##read environment variables

source /etc/infra-demo/infra-demo.env # getting the environment variables from the config file
PORT="${PORT:-8080}"
echo "[INFO]: Service port: $PORT"




## Assigning Permissions for security

echo "[INFO]: Applying Permissions..."
# just wrote infraadmin here as it was easy to write than the global variable i chose

chown infraadmin:infraadmin /opt/infra-demo/app.py
chmod 640 /opt/infra-demo/app.py # only onwer can read and write, they dont even need execution permission as python will do it for them

chown infraadmin:infraadmin /etc/infra-demo/infra-demo.env
chmod 600 /etc/infra-demo/infra-demo.env # only owner can read and write, it should be only read by them as they will work on the service

chown -R infraadmin:infraadmin /opt/infra-demo # from root to infraadmin
chmod 750 /opt/infra-demo # giving permission to owner and group  users to roam around the directory

chown -R infraadmin:infraadmin /etc/infra-demo
chmod 750 /etc/infra-demo # same as /opt/infra-demo

chown root:root /etc/systemd/system/*.service #for both infra-demo and maintenance
chmod 640 /etc/systemd/system/*.service

chown root:root /etc/systemd/system/infra-maintenance.timer
chmod 640 /etc/systemd/system/infra-maintenance.timer

chown infraadmin:infraadmin /opt/infra-demo/maintenance.sh
chmod 750 /opt/infra-demo/maintenance.sh # as i am doing the shebang line in the file and not the service

##install systemd service

echo "[INFO]: installing systemd service..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable "$SERVICE_NAME" # enable for future boots
systemctl restart "$SERVICE_NAME" || true

sleep 2
if ! systemctl is-active --quiet "$SERVICE_NAME";then
  echo "[ERROR]:  service failed to start."
  exit 1
fi


##Firewall config

echo "[INFO]: Configuring firewall..."
ufw default deny incoming #just baseline deny everything else
ufw default allow outgoing #need that baseline for outgoing requests
ufw status | grep -q "22/tcp" || ufw allow 22/tcp # getting the status of the firewall,checking if rule already exists with no standard output only exit code  so it would run the 2nd command depending on the exit code.
# so if 0 then exists then no running ufw allow, if 1 then run ufw allow
ufw status | grep -q "${PORT}/tcp" || ufw allow "${PORT}/tcp" # same as above
ufw status | grep -q "active" || ufw --force enable #starting the firewall and avoid breaking ssh on rerun


##Maintenance timer
echo "[INFO]: Installing maintenance timer..."
touch /var/log/infra-demo-health.log # for maintenance.sh just to be sure
chown infraadmin:infraadmin /var/log/infra-demo-health.log
chmod 640 /var/log/infra-demo-health.log
systemctl daemon-reload
systemctl enable infra-maintenance.timer
systemctl restart infra-maintenance.timer


## final status

echo
echo "[INFO]: Service state:"
systemctl is-active "$SERVICE_NAME"
echo
echo "[INFO]: Provisioning completed successfully."

