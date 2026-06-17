# Linux Infra Intern Assignment

#3rd Milestone

##Objective
build up the provision.sh for automation and set up maintenance scripts, service and timer.

##Environment

ubuntu 24.04

##Developed Components

-Provision.sh
-app.py for python health service
-infra-demo.service for systemd management
-infra-demo.env for environment variables like Port
-maintenance.sh
-infra-maintenance.service
-infra-maintenance.timer
##Repository Structure
-linux-infra-intern-assignment
|-README.md
|-scripts/
  |-provision.sh
  |-maintenance.sh
|-systemd/
  |-infra-demo.service
  |-infra-maintenance.service
  |-infra-maintenance.timer
|-config/
  |-infra-demo.env
|-docs/
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

Firewall hardening covered, ssh review covered and permissions secured in provision.sh
