# Linux Infra Intern Assignment

# Final Submission
## Overview
- This project implements an automated infrasructure by provisioning and validating the system.
- uses scripts in bash to provision the local vm into a server for a python health service with security hardening and idempotency.
- uses a python health service that is run by a service managed in systemd.
- there is a maintenance script that is run with an hourly timer for te health service, it cleans up the log and snapshot the health service.
- it is reboot resistant made possible by the provisioning script and checked by the validating script.
-  it is structured like any production style linux server infrastructure implementation.


##Environment

ubuntu 24.04


## Pre-Requisites
Ubuntu 24.04 LTS (or compatible release) these are also the supported OS
User account with sudo privilege
git installed
internet connectivity for package installation

## SETUP
1. Clone the repository: https://gitghub.com/ParthMatta-9921/Linux-Infra-Intern-Assignment.git
-  `git clone <repo>`
-  cd <repo> or wherever the dir is where the files are copied
2. Run Provisioning
-  `sudo <repo>/scripts/provision.sh`
3. Verify Service Status
-  just run the validation script
- `sudo <repo>/scripts/validate.sh
4. check for service
- ` systemctl status infra-demo.service`
5. check for timer
- `systemctl status infra-maintenance.timer~
6. check the health service
- ` curl -i http://localhost:8080/health
7. test reboot persistance
- `sudo reboot`
- after reboot, run `sudo <repo>/scripts/validate.sh`


## demo link: 
##Developed Components

-Provision.sh
  - automates system setup
  - does:
    - os validation(ubuntu only)
    - dependency install
    - user creation(infraadmin)
    - directory structure setup
    - file copy to standard dirs
    - permission enforcement on those dirs/files
    - systemd service installation and start
    - firwall config and acivation
    - timer activation
  - idempotent
  - fails fast on missing dependencies
  - system consistency
-app.py for python health service
  - basic app that uses http.server to start a health service on localhost
-infra-demo.service for systemd management
  - runs the main application app.py as a health service
  - managed by systemd
  - auto start on boot
-infra-demo.env for environment variables like Port
-maintenance.sh
  - the actual script that does the maintenance for the logs and takes health snapshots and stores to log file located where logs are stored in linux.
-infra-maintenance.service
  - uses maintenance.sh
  - does log cleanup and health snapshot
  - controlled via systemd timer
-infra-maintenance.timer
  - executes periodic maintenance tasks
  - hourly
  - made via systemd timer
-validaton.sh
  - validates the system after provisioning or reprovisioning
  - ensures health service is active
  - ensures maintenance.timer is active
  - ensures infra-demo is active
  - ensures app port is listening
  - checks firewall is active and has the correct rules in terms of hardening-checklist.md
  - ensures user `infraadmin` exists
  - ensures files have secure and correct permissions
  - ensures log file exists for the maintenance task
  - confirms services and timers actually survive reboot
-hardening-checklist.md
-test-plan.md
-troubleshooting.md
-local-vm-reprovisioning.md

## System Architecture
provision.sh(setup automation) --> System Config -->systemd services-->validate.sh(health verification)
				  |Users        |  |infra-demo       |
				  |Files        |  |maintenance.timer|
                                  |Permissions  |  
				  |Firewall(ufw)|  

##Repository Structure
-linux-infra-intern-assignment
|-README.md
|-scripts/
  |-provision.sh
  |-maintenance.sh
  |-validate.sh
|-systemd/
  |-infra-demo.service
  |-infra-maintenance.service
  |-infra-maintenance.timer
|-config/
  |-infra-demo.env
|-docs/
  |-hardening-checklist.md
  |-local-vm-reprovisioning.md
  |-test-plan.md
  |-troubleshooting.md
|-evidence/
|-app
  |-app.py

## Planned Packages

|Package | Purpose           |
|--------|-------------------|
|python3 |Demo Health Service|
|curl    |Service Validation |
|git     |Version Control    |
ufw      |Firewall Management|

##AI Assistance
- took help in the coming up of the documentation, only what to write
- took help when some persistant errors were there
